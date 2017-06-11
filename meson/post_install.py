#!/usr/bin/env python3

from os import environ, path
from subprocess import call

PREFIX = environ.get("MESON_INSTALL_PREFIX", "/usr/local")
SCHEMA_DIR = path.join(PREFIX, 'share', 'glib-2.0', 'schemas')
ICONS_DIR = path.join(PREFIX, 'share', 'icons', 'hicolor')

if not environ.get('DESTDIR'):
    print('Compiling gsettings schemas...')
    call(['glib-compile-schemas', SCHEMA_DIR])
    print('Refreshing icon cache...')
    call(['gtk-update-icon-cache', '-q', ICONS_DIR])
