# Nimbus

See the current temperature and weather conditions for your location with this minimal color-changing applet.

![Nimbus Screenshot](data/screenshot02.png)
![Nimbus Screenshot](data/screenshot.png)

## Building, Testing, and Installation


You'll need the following dependencies to build:
* libgeoclue-2-dev
* libgtk-3-dev
* libgweather-3-dev
* meson
* valac

You'll need the following dependencies to run:
* geoclue-2.0

Run `meson build` to configure the build environment and then change to the build directory and run `ninja` to build

    meson build
    cd build
    mesonconf -Dprefix=/usr
    ninja

To install, use `ninja install`, then execute with `com.github.danrabbit.nimbus`

    sudo ninja install
    com.github.danrabbit.nimbus
