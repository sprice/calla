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
    // Install Profile API
    'install_profile_api',
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
    // Image
    // 'imageapi', 'imageapi_gd', 'imagecache', 'imagecache_ui',
    // Token
    'token',
    // Path Auto
    'pathauto',
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
    // Content profile
    'content_profile',
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
  /*
  if (_atrium_installer_language_selected()) {
    $tasks['intranet-translation-batch'] = st('Download and import translation');
  }
  */
  $tasks['dev-modules-batch'] = st('Install features modules');
  $tasks['dev-configure-batch'] = st('Configure');
  return $tasks;
}

/**
 * Implementation of hook_profile_tasks().
 */
function dev_profile_profile_tasks(&$task, $url) {
  global $profile, $install_locale;
  
  // Just in case some of the future tasks adds some output
  $output = '';
  
  
  // Download and install translation if needed
  if ($task == 'profile') {
    /*
    if (_atrium_installer_language_selected() && module_exists('atrium_translate')) {
      module_load_install('atrium_translate');
      if ($batch = atrium_translate_create_batch($install_locale, 'install')) {
        $batch['finished'] = '_atrium_installer_translate_batch_finished';
        // Remove temporary variables and set install task
        variable_del('install_locale_batch_components');
        variable_set('install_task', 'intranet-translation-batch');
        batch_set($batch);
        batch_process($url, $url);
        // Jut for cli installs. We'll never reach here on interactive installs.
        return;
      }
    }
    // If we reach here, means no language install, move on to the next task
  */
    $task = 'dev-modules';
  }

  // We are running a batch task for this profile so basically do nothing and return page
  if (in_array($task, array('dev-modules-batch', 'dev-configure-batch'))) {
    include_once 'includes/batch.inc';
    $output = _batch_page();
  }
  
  // Install some more modules and maybe localization helpers too
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
 * Check whether we are installing in a language other than English
 */
/*
function _atrium_installer_language_selected() {
  global $install_locale;
  return !empty($install_locale) && ($install_locale != 'en');
}
*/

/**
 * Configuration. First stage.
 */
function _dev_profile_intranet_configure() {
  global $install_locale;

  /*
  // Disable the english locale if using a different default locale.
  if (!empty($install_locale) && ($install_locale != 'en')) {
    db_query("DELETE FROM {languages} WHERE language = 'en'");
  }

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
  variable_set('atrium_install', 1);
  // Get out of this batch and let the installer continue. If loaded translation,
  // we skip the locale remaining batch and move on to the next.
  // However, if we didn't make it with the translation file, or they downloaded
  // an unsupported language, we let the standard locale do its work.
  //if (variable_get('atrium_translate_done', 0)) {
  //  variable_set('install_task', 'finished');
  //}
  //else {
    variable_set('install_task', 'profile-finished');
    
    
    // turn off default blocks
    
    db_query("UPDATE {blocks} SET status = 0, region = '%s' WHERE theme = '%s'", '', 'garland');
  //} 
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
 * Finished callback for the first locale import batch.
 *
 * Advance installer task to the configure screen.
 */
/*
function _dev_profile_translate_batch_finished($success, $results) {
  include_once 'includes/locale.inc';
  // Let the installer now we've already imported locales
  variable_set('atrium_translate_done', 1);
  variable_set('install_task', 'intranet-modules');
  _locale_batch_language_finished($success, $results);
}
*/
/**
 * Alter some forms implementing hooks in system module namespace
 * 
 * This is a trick for hooks to get called, otherwise we cannot alter forms
 */

// Set Dev Profile as default profile
function system_form_install_select_profile_form_alter(&$form, $form_state) {
  foreach($form['profile'] as $key => $element) {
    $form['profile'][$key]['#value'] = 'dev_profile';
  }
}

/**
 * Set English as default language.
 * 
 * If no language selected, the installation crashes. I guess English should be the default 
 * but it isn't in the default install. @todo research, core bug?
 */
/*
function system_form_install_select_locale_form_alter(&$form, $form_state) {
  $form['locale']['en']['#value'] = 'en';
}
*/
/**
 * Alter the install profile configuration form and provide timezone location options.
 */
function system_form_install_configure_form_alter(&$form, $form_state) {
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
