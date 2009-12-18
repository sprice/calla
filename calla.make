core = 6.x

; Contrib
projects[admin][version] = "2.0-alpha2"
projects[] = backup_migrate
projects[] = cck
projects[] = codefilter
projects[] = content_profile
projects[] = context
projects[] = diff
projects[] = features
projects[] = libraries
projects[] = pathauto
projects[] = purl
projects[] = markdown
projects[] = schema
projects[] = spaces
projects[] = strongarm
projects[] = token
projects[] = typogrify
projects[] = views
projects[] = wysiwyg

; Custom
projects[wysiwyg_features][type] = "module"
projects[wysiwyg_features][download][type] = "git"
projects[wysiwyg_features][download][url] = "git://github.com/sprice/wysiwyg_features.git"

; Features
projects[calla_core][location] = "http://haikungfu.com/fserver"
projects[calla_blog][location] = "http://haikungfu.com/fserver"
projects[calla_team][location] = "http://haikungfu.com/fserver"

; Themes
projects[rubik][location] = http://code.developmentseed.org/fserver
projects[singular][location] = http://code.developmentseed.org/fserver
projects[tao][type] = "theme"
projects[tao][download][type] = "git"
projects[tao][download][url] = "git://github.com/sprice/tao.git"

; Libraries
libraries[fckeditor][download][type] = "get"
libraries[fckeditor][download][url] = "http://downloads.sourceforge.net/project/fckeditor/FCKeditor/2.6.5/FCKeditor_2.6.5.tar.gz"
libraries[fckeditor][directory_name] = "fckeditor"