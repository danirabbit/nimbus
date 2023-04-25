/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2017-2023 Danielle Foré (https://danirabbit.github.io/)
 */

public class MainWindow : Gtk.ApplicationWindow {
    private const string COLOR_PRIMARY = """
        @define-color colorPrimary %s;
    """;

    private Gtk.Stack stack;
    private GWeather.Location location;
    private GWeather.Info weather_info;

    construct {
        get_location.begin ();

        weather_info = new GWeather.Info (location) {
            contact_info = "danielle@elementary.io"
        };

        var weather_icon = new Gtk.Image.from_icon_name (weather_info.get_symbolic_icon_name ()) {
            pixel_size = 48
        };

        var weather_label = new Gtk.Label (weather_info.get_sky ()) {
            halign = Gtk.Align.END,
            valign = Gtk.Align.END,
            hexpand = true
        };
        weather_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var temp_label = new Gtk.Label (weather_info.get_temp ()) {
            halign = Gtk.Align.START
        };
        temp_label.add_css_class (Granite.STYLE_CLASS_H1_LABEL);

        var location_label = new Gtk.Label ("") {
            halign = Gtk.Align.END,
            valign = Gtk.Align.START
        };

        var grid = new Gtk.Grid () {
            column_spacing = 12
        };
        grid.attach (weather_icon, 0, 0, 1, 2);
        grid.attach (temp_label, 1, 0, 1, 2);
        grid.attach (weather_label, 2, 0);
        grid.attach (location_label, 2, 1);

        var spinner = new Gtk.Spinner () {
            halign = Gtk.Align.CENTER,
            vexpand = true,
            spinning = true
        };

        var alert_label = new Gtk.Label (_("Unable to Get Location"));

        stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE,
            valign = Gtk.Align.CENTER,
            vhomogeneous = true
        };
        stack.add_child (spinner);
        stack.add_named (grid, "weather");
        stack.add_named (alert_label, "alert");

        var window_handle = new Gtk.WindowHandle () {
            child = stack
        };

        child = window_handle;
        default_width = 350;
        icon_name = Application.get_default ().application_id;
        titlebar = new Gtk.Grid () { visible = false };
        title = _("Nimbus");

        notify["is-active"].connect (() => {
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
                provider.load_from_data (colored_css.data);

                Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (GLib.Error e) {
                critical (e.message);
            }
        });
    }

    public async void get_location () {
        try {
            var simple = yield new GClue.Simple (Application.get_default ().application_id, GClue.AccuracyLevel.CITY, null);

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
