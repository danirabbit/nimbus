project('com.github.danrabbit.nimbus', 'vala', 'c',
    version: '0.2.0'
)

gnome = import('gnome')
i18n = import('i18n')

asresources = gnome.compile_resources(
    'as-resources', 'data/css.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

gweather_deps = dependency('gweather-3.0')

vala_args = []
if(gweather_deps.version().version_compare('>=3.28'))
    vala_args += ['--define=GWEATHER_3_28']
endif

c_args = [
  '-include', 'config.h',
  '-DGWEATHER_I_KNOW_THIS_IS_UNSTABLE',
]

executable(
    'com.github.danrabbit.nimbus',
    'src/Application.vala',
    'src/MainWindow.vala',
    asresources,
    vala_args: vala_args,
    c_args: c_args,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        gweather_deps,
        dependency('libgeoclue-2.0')
    ],
    install : true
)

meson.add_install_script('meson/post_install.py')

subdir('data')
subdir('po')
