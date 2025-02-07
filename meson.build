project('catch-bad-files', ['c', 'vala'],
  version : '0.1',
  default_options : ['warning_level=3'])

dependencies = [
  dependency('gtk4'),
  dependency('gio-2.0'),
  dependency('gee-0.8'),
  dependency('gobject-2.0'),
  dependency('glib-2.0'),
]


lib = shared_library('md5-compare',
		     'src/md5-compare.vala',
		     dependencies: dependencies,
		     )

executable('catch-bad-files',      
	   'src/CBF.vala',           
	   link_with: lib,
	   dependencies: dependencies,
           install : true
)
