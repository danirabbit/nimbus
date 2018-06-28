# Nimbus
[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.danrabbit.nimbus)

See the current temperature and weather conditions for your location with this minimal color-changing applet.

![Nimbus Screenshot](https://raw.github.com/danrabbit/nimbus/master/data/screenshot.png)

## Building, Testing, and Installation


You'll need the following dependencies to build:
* libgeoclue-2-dev
* libgtk-3-dev
* libgweather-3-dev
* meson
* valac

You'll need the following dependencies to run:
* geoclue-2.0

Run `meson build` to configure the build environment and run `ninja test` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.danrabbit.nimbus`

    sudo ninja install
    com.github.danrabbit.nimbus
