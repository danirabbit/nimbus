project('com.github.danrabbit.nimbus', ['vala', 'c'],
    version: '0.1.0'
)

gnome = import('gnome')

asresources = gnome.compile_resources(
    'as-resources', 'data/css.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')


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
        dependency('gweather-3.0'),
        dependency('libgeoclue-2.0')
    ],
    install : true
)

install_data(
    'data/com.github.danrabbit.nimbus.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

install_data(
    'data/com.github.danrabbit.nimbus.desktop',
    install_dir: join_paths(get_option('datadir'), 'applications')
)

install_data(
    'data/com.github.danrabbit.nimbus.appdata.xml',
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

icon_sizes = ['32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        'data/icons/' + i + '/com.github.danrabbit.nimbus.svg',
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
endforeach

meson.add_install_script('meson/post_install.py')
