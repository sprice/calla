core = 6.x

; Contrib
projects[admin][version] = "6.2-alpha2"
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

; Libraries
libraries[ckeditor][download][type] = "get"
libraries[ckeditor][download][url] = "http://downloads.sourceforge.net/project/fckeditor/FCKeditor/2.6.5/FCKeditor_2.6.5.tar.gz"
libraries[ckeditor][directory_name = "fckeditor"