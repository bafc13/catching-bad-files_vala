project('git_vala', ['c', 'vala'],
  version : '0.1',
  default_options : ['warning_level=3'])

dependencies = [
  dependency('gtk4'),
  dependency('gio-2.0'),
  dependency('gee-0.8'),
  dependency('gobject-2.0'),
  dependency('glib-2.0')
]

executable('git_vala',
           'md5-compare.vala',
           'md5-compare.c',
           'CBF.vala',
           dependencies: dependencies,
           install : true)
