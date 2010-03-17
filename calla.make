core = 6.x

; Contrib
projects[admin][subdir] = "contrib"
projects[admin][version] = "2.0-beta2"
projects[backup_migrate][subdir] = "contrib"

projects[boxes][subdir] = "contrib"
; projects[boxes][version] = "1.0-beta3"
projects[boxes][type] = "module"
projects[boxes][download][type] = "cvs"
projects[boxes][download][module] = "contributions/modules/boxes"
projects[boxes][download][revision] = "HEAD"

projects[cck][subdir] = "contrib"
projects[ctools][subdir] = "contrib"
projects[codefilter][subdir] = "contrib"
projects[content_profile][subdir] = "contrib"

projects[context][subdir] = "contrib"
; projects[context][version] = "3.0-beta3"
projects[context][type] = "module"
projects[context][download][type] = "cvs"
projects[context][download][module] = "contributions/modules/context"
projects[context][download][revision] = "DRUPAL-6--3"

projects[diff][subdir] = "contrib"

projects[features][subdir] = "contrib"
; projects[features][version] = "1.0-beta6"
projects[features][type] = "module"
projects[features][download][type] = "cvs"
projects[features][download][module] = "contributions/modules/features"
projects[features][download][revision] = "DRUPAL-6--1"

projects[libraries][subdir] = "contrib"
projects[jquery_ui][subdir] = "contrib"
projects[jquery_ui][version] = "1"
projects[pathauto][subdir] = "contrib"

projects[purl][subdir] = "contrib"
; projects[purl][version] = "1.0-beta10"
projects[purl][type] = "module"
projects[purl][download][type] = "cvs"
projects[purl][download][module] = "contributions/modules/purl"
projects[purl][download][revision] = "DRUPAL-6--1"

projects[markdown][subdir] = "contrib"
projects[semanticviews][subdir] = "contrib"

projects[spaces][subdir] = "contrib"
; projects[spaces][version] = "3.0-beta2"
projects[spaces][type] = "module"
projects[spaces][download][type] = "cvs"
projects[spaces][download][module] = "contributions/modules/spaces"
projects[spaces][download][revision] = "DRUPAL-6--3"


projects[strongarm][subdir] = "contrib"
projects[token][subdir] = "contrib"
projects[typogrify][subdir] = "contrib"
projects[views][subdir] = "contrib"
projects[wysiwyg][subdir] = "contrib"

; Development
projects[coder][subdir] = "development"
projects[devel][subdir] = "development"
projects[install_profile_api][subdir] = "development"
projects[schema][subdir] = "development"
projects[simpletest][subdir] = "development"

; Features
projects[calla_team][subdir] = "features"
projects[calla_team][location] = "http://features.affinitybridge.com/fserver"
projects[calla_core][subdir] = "features"
projects[calla_core][location] = "http://features.affinitybridge.com/fserver"
projects[calla_blog][subdir] = "features"
projects[calla_blog][location] = "http://features.affinitybridge.com/fserver"

; Themes
projects[rubik][location] = http://code.developmentseed.org/fserver
projects[singular][location] = http://code.developmentseed.org/fserver
projects[tao][location] = http://code.developmentseed.org/fserver

; Libraries
libraries[fckeditor][download][type] = "get"
libraries[fckeditor][download][url] = "http://download.cksource.com/CKEditor/CKEditor/CKEditor%203.2/ckeditor_3.2.tar.gz"
libraries[fckeditor][directory_name] = "ckeditor"
libraries[jquery_ui][download][type] = "get"
libraries[jquery_ui][download][url] = "http://jquery-ui.googlecode.com/files/jquery.ui-1.6.zip"
libraries[jquery_ui][directory_name] = "jquery.ui"
libraries[jquery_ui][destination] = "modules/contrib/jquery_ui"