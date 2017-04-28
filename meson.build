project('com.github.danrabbit.nimbus', ['vala', 'c'],
    version: '0.1.0'
)

gnome = import('gnome')

asresources = gnome.compile_resources(
    'as-resources', 'data/css.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

executable(
    'com.github.danrabbit.nimbus',
    'src/Application.vala',
    'src/MainWindow.vala',
    asresources,
    c_args: '-DGWEATHER_I_KNOW_THIS_IS_UNSTABLE',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        dependency('gweather-3.0')
    ],
    install : true
)

install_data(
    'data/com.github.danrabbit.nimbus.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

meson.add_install_script('meson/post_install.py')
