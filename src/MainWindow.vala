/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2017-2023 Danielle Foré (https://danirabbit.github.io/)
 */

public class MainWindow : Hdy.ApplicationWindow {
    private const string COLOR_PRIMARY = """
        @define-color colorPrimary %s;
        .background,
        .titlebar {
            transition: all 600ms ease-in-out;
        }
    """;

    private Gtk.Stack stack;
    private GWeather.Location location;
    private GWeather.Info weather_info;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            icon_name: "com.github.danrabbit.nimbus",
            resizable: false,
            title: _("Nimbus"),
            width_request: 500
        );
    }

    construct {
        Hdy.init ();

        set_keep_below (true);
        stick ();

        get_location.begin ();

        weather_info = new GWeather.Info (location) {
            contact_info = "danielle@elementary.io"
        };

        var weather_icon = new Gtk.Image.from_icon_name (weather_info.get_symbolic_icon_name (), Gtk.IconSize.DIALOG);

        var weather_label = new Gtk.Label (weather_info.get_sky ());
        weather_label.halign = Gtk.Align.END;
        weather_label.hexpand = true;
        weather_label.margin_top = 6;
        weather_label.get_style_context ().add_class ("weather");

        var temp_label = new Gtk.Label (weather_info.get_temp ());
        temp_label.halign = Gtk.Align.START;
        temp_label.margin_bottom = 3;
        temp_label.get_style_context ().add_class ("temperature");

        var location_label = new Gtk.Label ("");
        location_label.halign = Gtk.Align.END;
        location_label.margin_bottom = 12;

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.margin = 24;
        grid.margin_bottom = 21;
        grid.attach (weather_icon, 0, 0, 1, 2);
        grid.attach (temp_label, 1, 0, 1, 2);
        grid.attach (weather_label, 2, 0, 1, 1);
        grid.attach (location_label, 2, 1, 1, 1);

        var spinner = new Gtk.Spinner ();
        spinner.active = true;
        spinner.halign = Gtk.Align.CENTER;
        spinner.vexpand = true;

        var alert_label = new Gtk.Label (_("Unable to Get Location"));

        stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE,
            vhomogeneous = true
        };
        stack.add (spinner);
        stack.add_named (grid, "weather");
        stack.add_named (alert_label, "alert");

        var window_handle = new Hdy.WindowHandle ();
        window_handle.add (stack);

        add (window_handle);

        show_all ();

        focus_in_event.connect (() => {
            weather_info.update ();
        });

        weather_info.updated.connect (() => {
            if (location == null) {
                return;
            }

            location_label.label = dgettext ("libgweather-locations", location.get_city_name ());

            weather_icon.icon_name = weather_info.get_symbolic_icon_name ();
            weather_label.label = dgettext ("libgweather", weather_info.get_sky ());

            double temp;
            weather_info.get_value_temp (GWeather.TemperatureUnit.DEFAULT, out temp);
            temp_label.label = _("%i°").printf ((int) temp);

            string color_primary;

            switch (weather_icon.icon_name) {
                case "weather-clear-night-symbolic":
                case "weather-few-clouds-night-symbolic":
                    color_primary = "#183048";
                    break;
                case "weather-few-clouds-symbolic":
                case "weather-overcast-symbolic":
                case "weather-showers-symbolic":
                case "weather-showers-scattered-symbolic":
                    color_primary = "#68758e";
                    break;
                case "weather-snow-symbolic":
                    color_primary = "#6fc3ff";
                    break;
                default:
                    color_primary = "#42baea";
                    break;
            }

            var provider = new Gtk.CssProvider ();
            try {
                var colored_css = COLOR_PRIMARY.printf (color_primary);
                provider.load_from_data (colored_css, colored_css.length);

                Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (GLib.Error e) {
                critical (e.message);
            }
        });
    }

    public async void get_location () {
        try {
            var simple = yield new GClue.Simple ("com.github.danrabbit.nimbus", GClue.AccuracyLevel.CITY, null);

            simple.notify["location"].connect (() => {
                on_location_updated (simple.location.latitude, simple.location.longitude);
            });

            on_location_updated (simple.location.latitude, simple.location.longitude);
        } catch (Error e) {
            warning ("Failed to connect to GeoClue2 service: %s", e.message);
            stack.visible_child_name = "alert";
            return;
        }
    }

    public void on_location_updated (double latitude, double longitude) {
        location = GWeather.Location.get_world ();
        location = location.find_nearest_city (latitude, longitude);
        if (location != null) {
            weather_info.location = location;
            weather_info.update ();
            stack.visible_child_name = "weather";
        }
    }
}
