core = 6.x

; Contrib
projects[admin][subdir] = "contrib"
projects[admin][version] = "2.0-alpha2"
projects[backup_migrate][subdir] = "contrib" 
projects[cck][subdir] = "contrib"
projects[codefilter][subdir] = "contrib"
projects[content_profile][subdir] = "contrib"
projects[context][subdir] = "contrib"
projects[diff][subdir] = "contrib"
projects[features][subdir] = "contrib"
projects[libraries][subdir] = "contrib"
projects[pathauto][subdir] = "contrib"
projects[purl][subdir] = "contrib"
projects[markdown][subdir] = "contrib"
projects[schema][subdir] = "contrib"
projects[spaces][subdir] = "contrib"
projects[strongarm][subdir] = "contrib"
projects[token][subdir] = "contrib"
projects[typogrify][subdir] = "contrib"
projects[views][subdir] = "contrib"
projects[wysiwyg][subdir] = "contrib"

; Custom
projects[wysiwyg_features][subdir] = "custom"
projects[wysiwyg_features][type] = "module"
projects[wysiwyg_features][download][type] = "git"
projects[wysiwyg_features][download][url] = "git://github.com/sprice/wysiwyg_features.git"

; Features
projects[calla_core][subdir] = "features"
projects[calla_core][location] = "http://haikungfu.com/fserver"
projects[calla_blog][subdir] = "features"
projects[calla_blog][location] = "http://haikungfu.com/fserver"
projects[calla_team][subdir] = "features"
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