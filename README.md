# Nimbus

## Building, Testing, and Installation


You'll need the following dependencies:
* libgtk-3-dev
* libgweather-3-dev 
* valac
* meson

Run `meson build` to configure the build environment and then change to the build directory and run `ninja` to build

    meson build
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.danrabbit.nimbus`

    ninja install
    com.github.danrabbit.nimbus
