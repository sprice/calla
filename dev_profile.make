core = 6.x

projects[] = cck
projects[] = views
projects[] = features
projects[] = imagecache
projects[] = admin_menu
projects[] = backup_migrate
projects[] = imageapi
projects[] = content_profile
projects[] = strongarm
projects[] = token
projects[] = pathauto
projects[] = diff
projects[] = context
projects[] = spaces
projects[] = purl
projects[] = install_profile_api
projects[blog_feature][location] = "http://haikungfu.com/fserver"
projects[team_feature][location] = "http://haikungfu.com/fserver"
projects[rubik][location] = http://code.developmentseed.org/fserver
projects[singular][location] = http://code.developmentseed.org/fserver
projects[tao][type] = "theme"
projects[tao][download][type] = "git"
projects[tao][download][url] = "git://github.com/sprice/tao.git"
; Patched
projects[simpletest][version] = "2.9"
projects[simpletest][patch] = "http://drupalcode.org/viewvc/drupal/contributions/modules/simpletest/D6-core-simpletest.patch?revision=1.1.2.1&view=co"
