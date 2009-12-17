<?php
// $Id$
/**
 * Drupal install profile file.
 * atrium_installer.profile used as reference
 */

/**
 * Implementation of hook_profile_details().
 */
function dev_profile_profile_details() {
  return array(
    'name' => 'Dev Install Profile',
    'description' => 'A development install profile created by Shawn Price for Affinity Bridge'
  );
}

/**
 * Implementation of hook_profile_modules().
 */
function dev_profile_profile_modules() {
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
    // Admin Menu
    'admin_menu',
    // Backup Migrate
    'backup_migrate',
    // Views
    'views',
    // Features
    'features',
    // Context
    'context', 'context_contrib',
    // Context UI (used only to look at contexts)
    'context_ui',
    // Spaces
    'spaces',
    // PURL
    'purl',
    // Token
    'token',
    // Path Auto
    'pathauto',
    // Content profile
    'content_profile',
    // Wysiwyg API
    'wysiwyg',
  );

  return $modules;
}

/**
 * Returns an array list of features (and supporting) modules.
 */
function _dev_profile_dev_modules() {
  return array(
    // Strongarm
    'strongarm',
    // CCK
    'content', 'content_permissions', 'nodereference', 'optionwidgets', 'number', 'text',
    // Features
    'blog_feature', 'team_feature',
    // Others
    'diff',
  );
}

/**
 * Implementation of hook_profile_task_list().
 */
function dev_profile_profile_task_list() {
  $tasks['dev-modules-batch'] = st('Install modules for features');
  $tasks['dev-configure-batch'] = st('Configure installation');
  return $tasks;
}

/**
 * Implementation of hook_profile_tasks().
 */
function dev_profile_profile_tasks(&$task, $url) {
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
    $modules = _dev_profile_dev_modules();
    $files = module_rebuild_cache();
    // Create batch
    foreach ($modules as $module) {
      $batch['operations'][] = array('_install_module_batch', array($module, $files[$module]->info['name']));
    }    
    $batch['finished'] = '_dev_profile_profile_batch_finished';
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
    $batch['operations'][] = array('_dev_profile_intranet_configure', array());
    $batch['operations'][] = array('_dev_profile_intranet_configure_check', array());
    $batch['finished'] = '_dev_profile_intranet_configure_finished';
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
function _dev_profile_intranet_configure() {
  global $install_locale;

  // Create content profile for user 1
  variable_get('admin_full_name', NULL);
  
  //
  // create profile
  // @todo
  variable_del('admin_full_name');

  /*
  // Remove default input filter formats
  $result = db_query("SELECT * FROM {filter_formats} WHERE name IN ('%s', '%s')", 'Filtered HTML', 'Full HTML');
  while ($row = db_fetch_object($result)) {
    db_query("DELETE FROM {filter_formats} WHERE format = %d", $row->format);
    db_query("DELETE FROM {filters} WHERE format = %d", $row->format);
  }

  // Eliminate the access content perm from anonymous users.
  db_query("UPDATE {permission} set perm = '' WHERE rid = 1");

  // Create user picture directory
  $picture_path = file_create_path(variable_get('user_picture_path', 'pictures'));
  file_check_directory($picture_path, 1, 'user_picture_path');
  */
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

  // Set a default footer message.
  //variable_set('site_footer', '&copy; 2009 '. l('Development Seed', 'http://www.developmentseed.org', array('absolute' => TRUE)));

  // Set default theme. This needs some more set up on next page load
  // We cannot do everything here because of _system_theme_data() static cache
  system_theme_data();
  db_query("UPDATE {system} SET status = 0 WHERE type = 'theme' and name ='%s'", 'garland');
  variable_set('theme_default', 'singular');
  variable_set('admin_theme', 'rubik');
  variable_set('node_admin_theme', 'rubik');



  /*
  // Revert the filter that messaging provides to our default.  
  $component = 'filter';
  $module = 'atrium_intranet';
  module_load_include('inc', 'features', "features.{$component}");
  module_invoke($component, 'features_revert', $module);
  */
}

/**
 * Configuration. Second stage.
 */
function _dev_profile_intranet_configure_check() {
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
function _dev_profile_intranet_configure_finished($success, $results) {
  variable_set('install_task', 'profile-finished');
    
  // turn off default blocks  
  db_query("UPDATE {blocks} SET status = 0, region = '%s' WHERE theme = '%s'", '', 'garland'); 
}

/**
 * Finished callback for the modules install batch.
 *
 * Advance installer task to language import.
 */
function _dev_profile_profile_batch_finished($success, $results) {
  variable_set('install_task', 'intranet-configure');
}

/**
 * FORM ALTERS
 */

/**
 * Set the default installation profile.
 */
function system_form_install_select_profile_form_alter(&$form, $form_state) {
  foreach($form['profile'] as $key => $element) {
    $form['profile'][$key]['#value'] = 'dev_profile';
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
  
  $form['admin_account']['account']['fullname'] = array(
    '#type' => 'textfield',
    '#title' => 'Full name',
    '#maxlength' => '60',
    '#description' => 'The first and last name of the administrator.',
    '#required' => '1',
    '#weight' => '-9',
  );
  array_push($form['#submit'], '_dev_profile_install_configure_submit');
  
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

/**
 * Additional submit hook for adding the admin users full name
 */
function _dev_profile_install_configure_submit($form, &$form_state) {
  variable_set('admin_full_name', $form_state['values']['account']['fullname']);
}