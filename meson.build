project('io.github.danirabbit.nimbus', 'vala', 'c',
    version: '1.1.2'
)

add_global_arguments('-DGETTEXT_PACKAGE="' + meson.project_name() + '"', language:'c')

gnome = import('gnome')
i18n = import('i18n')

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

asresources = gnome.compile_resources(
    'as-resources', 'data/css.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

executable(
    meson.project_name(),
    'src/Application.vala',
    'src/MainWindow.vala',
    config_file,
    asresources,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk4'),
        dependency('granite-7', version: '>=7.3.0'),
        dependency('gweather4'),
        dependency('libgeoclue-2.0')
    ],
    install : true
)

subdir('data')
subdir('po')
