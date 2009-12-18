<?php
// $Id$
/**
 * Drupal install profile file.
 * atrium_installer.profile used as reference
 */

/**
 * Implementation of hook_profile_details().
 */
function calla_profile_details() {
  return array(
    'name' => 'Calla',
    'description' => 'Calla by Affinity Bridge'
  );
}

/**
 * Implementation of hook_profile_modules().
 */
function calla_profile_modules() {
  $modules = array(
     // Drupal core
    'block',
    'comment',
    'dblog',
    'filter',
    'help',
    'menu',
    'node',
    'path',
    'system',
    'taxonomy',
    'user',
    // Admin
    'admin',
    // Backup Migrate
    'backup_migrate',
    // Features
    'features',
    // Content profile
    'content_profile',
    // Context
    'context', 'context_contrib',
    // Context UI
    'context_ui',
    // Pathauto
    'pathauto',
    // PURL
    'purl',
    // Spaces
    'spaces',
    // Token
    'token',
    // Views
    'views',
    // Wysiwyg API
    'wysiwyg',
  );
  return $modules;
}

/**
 * Returns an array list of features (and supporting) modules.
 */
function _calla_dev_modules() {
  return array(
    // CCK
    'content', 'content_permissions', 'nodereference', 'optionwidgets', 'number', 'text',
    // Diff
    'diff',
    // Features
    'calla_core', 'calla_blog', 'calla_team',
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
  $tasks['dev-modules-batch'] = st('Install modules for features');
  $tasks['dev-configure-batch'] = st('Configure installation');
  return $tasks;
}

/**
 * Implementation of hook_profile_tasks().
 */
function calla_profile_tasks(&$task, $url) {
  global $profile, $install_locale;
  
  // Just in case some of the future tasks adds some output
  $output = '';
  
  if ($task == 'profile') {
    $task = 'dev-modules';
  }

  // We are running a batch task for this profile so basically do nothing and return page
  if (in_array($task, array('dev-modules-batch', 'dev-configure-batch'))) {
    include_once 'includes/batch.inc';
    $output = _batch_page();
  }
  
  // Install some more modules
  if ($task == 'dev-modules') {
    $modules = _calla_dev_modules();
    $files = module_rebuild_cache();
    // Create batch
    foreach ($modules as $module) {
      $batch['operations'][] = array('_install_module_batch', array($module, $files[$module]->info['name']));
    }    
    $batch['finished'] = '_calla_profile_batch_finished';
    $batch['title'] = st('Installing @drupal', array('@drupal' => drupal_install_profile_name()));
    $batch['error_message'] = st('The installation has encountered an error.');

    // Start a batch, switch to 'dev-modules-batch' task. We need to
    // set the variable here, because batch_process() redirects.
    variable_set('install_task', 'dev-modules-batch');
    batch_set($batch);
    batch_process($url, $url);
    // Jut for cli installs. We'll never reach here on interactive installs.
    return;
  }

  // Run additional configuration tasks
  // @todo Review all the cache/rebuild options at the end, some of them may not be needed
  // @todo Review for localization, the time zone cannot be set that way either
  if ($task == 'intranet-configure') {
    $batch['title'] = st('Configuring @drupal', array('@drupal' => drupal_install_profile_name()));
    $batch['operations'][] = array('_calla_intranet_configure', array());
    $batch['operations'][] = array('_calla_intranet_configure_check', array());
    $batch['finished'] = '_calla_intranet_configure_finished';
    variable_set('install_task', 'dev-configure-batch');
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
function _calla_intranet_configure() {
  global $install_locale;

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
  //$tz_offset = date('Z');
  //variable_set('date_default_timezone', $tz_offset);

  // Set default theme. This needs some more set up on next page load
  // We cannot do everything here because of _system_theme_data() static cache
  system_theme_data();
  db_query("UPDATE {system} SET status = 0 WHERE type = 'theme' and name ='%s'", 'garland');
  variable_set('theme_default', 'singular');
  variable_set('admin_theme', 'rubik');
  variable_set('node_admin_theme', 'rubik');
  
}

/**
 * Configuration. Second stage.
 */
function _calla_intranet_configure_check() {
  // Rebuild key tables/caches
  module_rebuild_cache(); // Detects the newly added bootstrap modules
  node_access_rebuild();
  drupal_get_schema(NULL, TRUE); // Clear schema DB cache
  drupal_flush_all_caches();    
  system_theme_data();  // Rebuild theme cache.
   _block_rehash();      // Rebuild block cache.
  views_invalidate_cache(); // Rebuild the views.
  // This one is done by the installer alone
  //menu_rebuild();       // Rebuild the menu.
  features_rebuild();   // Features rebuild scripts.
}

/**
 * Finish configuration batch
 * 
 * @todo Handle error condition
 */
function _calla_intranet_configure_finished($success, $results) {
  variable_set('install_task', 'profile-finished');
    
  // turn off default blocks  
  db_query("UPDATE {blocks} SET status = 0, region = '%s' WHERE theme = '%s'", '', 'garland'); 
}

/**
 * Finished callback for the modules install batch.
 *
 * Advance installer task to language import.
 */
function _calla_profile_batch_finished($success, $results) {
  variable_set('install_task', 'intranet-configure');
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