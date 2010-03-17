<?php
// $Id$

/**
 * Return a description of the profile for the initial installation screen.
 *
 * @return
 *   A keyed array describing this profile.
 */
function calla_profile_details() {
  return array(
    'name' => 'Calla',
    'description' => 'Calla by Affinity Bridge'
  );
}

/**
 * Return an array of modules to be enabled
 *
 * @return
 *  An array of modules to be enabled.
 */
function calla_profile_modules() {
  return array(
     // Core
    'block', 'comment', 'dblog', 'filter', 'help', 'menu', 'node', 'path',
    'system', 'taxonomy', 'user',
    // Contrib
    'admin', 'backup_migrate', 'boxes', 'features', 'content_profile',
    'context', 'context_ui', 'ctools', 'install_profile_api', 'pathauto',
    'purl', 'spaces', 'token', 'views', 'wysiwyg',
  );
}

function pr($var) {
  echo "<pre>";
  print_r($var);
  echo "</pre>";
}

function _pr($var) {
  print_r(error_log($var,0),1);
}

/**
 * Return an array of features and supporting modules to be enabled.
 *
 * @return
 *  An array of features and supporting modules to be enabled.
 */
function _calla_config_modules() {
  return array(
    // Features
    'calla_core', 'calla_blog', 'calla_team',
    // Other contrib
    'content', 'content_permissions', 'nodereference', 'number', 'optionwidgets', 'text',
    // Diff
    'diff',
    // Formats
    'codefilter', 'markdown', 'typogrify',
    // Strongarm
    'strongarm',
    // Wysiwyg Features
    'wysiwyg_features',
  );
}

/**
 * Implementation of hook_profile_task_list().
 */
function calla_profile_task_list() {
  return array(
    'calla-modules-batch' => st('Install Calla'),
    'calla-configure-batch' => st('Configure Calla'),
  );
}

/**
 * Implementation of hook_profile_tasks().
 */
function calla_profile_tasks(&$task, $url) {
  // In case future tasks add output
  $output = '';
  
  if ($task == 'profile') {
    $task = 'calla-modules';
  }

  // We are running a batch task for this profile so basically do nothing and return page
  if (in_array($task, array('calla-modules-batch', 'calla-configure-batch'))) {
    include_once 'includes/batch.inc';
    $output = _batch_page();
  }
  
  // Install some more modules
  if ($task == 'calla-modules') {
    $modules = _calla_config_modules();
    $files = module_rebuild_cache();
    // Create batch
    foreach ($modules as $module) {
      $batch['operations'][] = array('_install_module_batch', array($module, $files[$module]->info['name']));
    }    
    $batch['finished'] = '_calla_profile_batch_finished';
    $batch['title'] = st('Installing @drupal', array('@drupal' => drupal_install_profile_name()));
    $batch['error_message'] = st('The installation has encountered an error.');

    // Start a batch, switch to 'calla-modules-batch' task. We need to
    // set the variable here, because batch_process() redirects.
    variable_set('install_task', 'calla-modules-batch');
    batch_set($batch);
    batch_process($url, $url);
    // Jut for cli installs. We'll never reach here on interactive installs.
    return;
  }

  // Run additional configuration tasks
  // @todo Review all the cache/rebuild options at the end, some of them may not be needed
  // @todo Review for localization, the time zone cannot be set that way either
  if ($task == 'calla-configure') {
    $batch['title'] = st('Configuring @drupal', array('@drupal' => drupal_install_profile_name()));
    $batch['operations'][] = array('_calla_configure', array());
    $batch['operations'][] = array('_calla_configure_check', array());
    $batch['finished'] = '_calla_configure_finished';
    variable_set('install_task', 'calla-configure-batch');
    batch_set($batch);
    batch_process($url, $url);
    // Jut for cli installs. We'll never reach here on interactive installs.
    return;
  }  

  return $output;
}

/**
 * Configuration. First stage.
 */
function _calla_configure() {

  // Remove default input filter formats
  $result = db_query("SELECT * FROM {filter_formats} WHERE name IN ('%s', '%s')", 'Filtered HTML', 'Full HTML');
  while ($row = db_fetch_object($result)) {
    db_query("DELETE FROM {filter_formats} WHERE format = %d", $row->format);
    db_query("DELETE FROM {filters} WHERE format = %d", $row->format);
  }
  
  // Create freetagging vocab
  $vocab = array(
    'name' => 'Keywords',
    'multiple' => 0,
    'required' => 0,
    'hierarchy' => 0,
    'relations' => 0,
    'module' => 'taxonomy',
    'weight' => 0,
    'nodes' => array('blog' => 1),
    'tags' => TRUE,
    'help' => t('Enter tags related to your post.'),
  );
  taxonomy_save_vocabulary($vocab);

  // Set time zone
  $tz_offset = date('Z');
  variable_set('date_default_timezone', $tz_offset);
  
  // Revert key components that are overridden by others on install.
  $revert = array(
    'calla_core' => array('user', 'variable', 'filter'),
    'calla_blog' => array('user', 'variable'),
    'calla_team' => array('user', 'variable'),
  );
  features_revert($revert);
}

/**
 * Configuration. Second stage.
 */
function _calla_configure_check() {

  // @todo document the following three functions.
  node_access_rebuild();
  drupal_flush_all_caches();
  system_theme_data();
  
  db_query("UPDATE {blocks} SET status = 0, region = ''"); // disable all DB blocks
  db_query("UPDATE {system} SET status = 0 WHERE type = 'theme' and name ='%s'", 'garland');
  db_query("UPDATE {system} SET status = 0 WHERE type = 'theme' and name ='%s'", 'singular');
  variable_set('theme_default', 'singular');
  variable_set('admin_theme', 'rubik');
}

/**
 * Finish configuration batch
 * 
 * @todo Handle error condition
 */
function _calla_configure_finished($success, $results) {
  variable_set('install_task', 'profile-finished');
}

/**
 * Finished callback for the modules install batch.
 *
 * Advance installer task to language import.
 */
function _calla_profile_batch_finished($success, $results) {
  variable_set('install_task', 'calla-configure');
}

/**
 * Set the default installation profile.
 */
function system_form_install_select_profile_form_alter(&$form, $form_state) {
  foreach($form['profile'] as $key => $element) {
    $form['profile'][$key]['#value'] = 'calla';
  }
}

/**
 * Set the default language to English.
 */
function system_form_install_select_locale_form_alter(&$form, $form_state) {
  $form['locale']['en']['#value'] = 'en';
}

/**
 * Alter the install profile configuration form and provide timezone location options.
 */
function system_form_install_configure_form_alter(&$form, $form_state) {
  $form['site_information']['site_name']['#default_value'] = 'Calla';
  $form['site_information']['site_mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST'];
  $form['admin_account']['account']['name']['#default_value'] = 'admin';
  $form['admin_account']['account']['mail']['#default_value'] = 'admin@'. $_SERVER['HTTP_HOST'];
 
  if (function_exists('date_timezone_names') && function_exists('date_timezone_update_site')) {
    $form['server_settings']['date_default_timezone']['#access'] = FALSE;
    $form['server_settings']['#element_validate'] = array('date_timezone_update_site');
    $form['server_settings']['date_default_timezone_name'] = array(
      '#type' => 'select',
      '#title' => t('Default time zone'),
      '#default_value' => NULL,
      '#options' => date_timezone_names(FALSE, TRUE),
      '#description' => t('Select the default site time zone. If in doubt, choose the timezone that is closest to your location which has the same rules for daylight saving time.'),
      '#required' => TRUE,
    );
  }
}