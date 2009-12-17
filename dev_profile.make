core = 6.x


; Contrib
projects[] = admin_menu
projects[] = backup_migrate
projects[] = cck
projects[] = content_profile
projects[] = context
projects[] = diff
projects[] = features
projects[] = libraries
projects[] = pathauto
projects[] = purl
projects[] = schema
projects[] = simpletest
projects[] = spaces
projects[] = strongarm
projects[] = token
projects[] = wysiwyg
projects[] = views

; Custom
projects[wysiwyg_features][type] = "module"
projects[wysiwyg_features][download][type] = "git"
projects[wysiwyg_features][download][url] = "git://github.com/sprice/wysiwyg_features.git"

; Features
projects[blog_feature][location] = "http://haikungfu.com/fserver"
projects[team_feature][location] = "http://haikungfu.com/fserver"

; Themes
projects[rubik][location] = http://code.developmentseed.org/fserver
projects[singular][location] = http://code.developmentseed.org/fserver
projects[tao][type] = "theme"
projects[tao][download][type] = "git"
projects[tao][download][url] = "git://github.com/sprice/tao.git"

; Patched
;projects[simpletest][patch] = "http://drupalcode.org/viewvc/drupal/contributions/modules/simpletest/D6-core-simpletest.patch?revision=1.1.2.1&view=co"
;projects[context][version] = "2.0-beta7"
;projects[context][patch] = "http://drupal.org/files/issues/context_test_setup.patch"

; Libraries
libraries[ckeditor][download][type] = "get"
libraries[ckeditor][download][url] = "http://download.cksource.com/CKEditor/CKEditor/CKEditor%203.0.1/ckeditor_3.0.1.tar.gz"
libraries[ckeditor][directory_name = "ckeditor"