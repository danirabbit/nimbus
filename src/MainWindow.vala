/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2017-2023 Danielle Foré (https://danirabbit.github.io/)
 */

public class MainWindow : Gtk.ApplicationWindow {
    private Gtk.Stack stack;
    private Gtk.Spinner spinner;
    private Gtk.Box box;
    private Granite.Placeholder placeholder;
    private GWeather.Location? location = null;
    private GWeather.Info weather_info;

    construct {
        weather_info = new GWeather.Info (location) {
            application_id = Application.get_default ().application_id,
            contact_info = "danielle@elementary.io",
            enabled_providers = METAR | MET_NO
        };

        var weather_icon = new Gtk.Image ();
        weather_icon.add_css_class ("weather-icon");

        var weather_label = new Gtk.Label ("") {
            halign = Gtk.Align.END,
            valign = Gtk.Align.END,
            hexpand = true
        };
        weather_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var temp_label = new Gtk.Label ("") {
            halign = Gtk.Align.START
        };
        temp_label.add_css_class (Granite.STYLE_CLASS_H1_LABEL);

        var location_label = new Gtk.Label ("") {
            halign = Gtk.Align.END,
            valign = Gtk.Align.START
        };

        var wind_icon = new Gtk.Image.from_icon_name ("weather-windy-symbolic") {
            halign = END,
            tooltip_text = _("Wind")
        };
        wind_icon.add_css_class ("conditions");

        var wind_label = new Gtk.Label ("") {
            halign = START
        };

        var visibility_icon = new Gtk.Image.from_icon_name ("eye-open-negative-filled-symbolic") {
            halign = END,
            tooltip_text = _("Visibility")
        };
        visibility_icon.add_css_class ("conditions");

        var visibility_label = new Gtk.Label ("") {
            halign = START
        };

        var pressure_icon = new Gtk.Image.from_icon_name ("pressure-symbolic") {
            halign = END,
            tooltip_text = _("Pressure")
        };
        pressure_icon.add_css_class ("conditions");

        var pressure_label = new Gtk.Label ("") {
            halign = START
        };

        var hourly_box = new Gtk.FlowBox () {
            min_children_per_line = 24,
            max_children_per_line = 24
        };

        var hourly_scrolled = new Gtk.ScrolledWindow () {
            child = hourly_box,
            vscrollbar_policy = NEVER
        };

        var grid = new Gtk.Grid ();
        grid.attach (weather_icon, 0, 0, 1, 2);
        grid.attach (temp_label, 1, 0, 1, 2);
        grid.attach (weather_label, 2, 0);
        grid.attach (location_label, 2, 1);

        grid.attach (wind_icon, 0, 2);
        grid.attach (wind_label, 1, 2, 2);
        grid.attach (visibility_icon, 0, 3);
        grid.attach (visibility_label, 1, 3, 2);
        grid.attach (pressure_icon, 0, 4);
        grid.attach (pressure_label, 1, 4, 2);

        grid.add_css_class ("weather");

        box = new Gtk.Box (VERTICAL, 0);
        box.append (grid);
        box.append (hourly_scrolled);

        spinner = new Gtk.Spinner () {
            halign = Gtk.Align.CENTER,
            vexpand = true,
            spinning = true
        };

        placeholder = new Granite.Placeholder (_("Unable to Get Location")) {
            icon = new ThemedIcon ("location-disabled-symbolic"),
            description = _("Make sure location access is turned on in <a href='settings://privacy/location'>System Settings → Security &amp; Privacy</a>")
        };

        stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE,
            valign = Gtk.Align.CENTER,
            vhomogeneous = false
        };
        stack.add_child (spinner);
        stack.add_child (box);
        stack.add_child (placeholder);

        var window_handle = new Gtk.WindowHandle () {
            child = stack
        };

        child = window_handle;
        default_width = 350;
        icon_name = Application.get_default ().application_id;
        titlebar = new Gtk.Grid () { visible = false };
        title = _("Nimbus");

        get_location ();

        notify["is-active"].connect (() => {
            if (stack.visible_child == spinner || !is_active) {
                return;
            }

            if (location == null) {
                get_location ();
            } else {
                weather_info.update ();
            }
        });

        weather_info.updated.connect (() => {
            if (location == null) {
                return;
            }

            location_label.label = dgettext ("libgweather-locations", location.get_city_name ());

            weather_icon.icon_name = weather_info.get_symbolic_icon_name ();

            var conditions = weather_info.get_conditions ();
            if (conditions == "-") {
                conditions = weather_info.get_sky ();
            }

            weather_label.label = dgettext ("libgweather", conditions);

            double temp;
            weather_info.get_value_temp (GWeather.TemperatureUnit.DEFAULT, out temp);
            temp_label.label = _("%i°").printf ((int) temp);

            visibility_label.label = dgettext ("libgweather", weather_info.get_visibility ());
            pressure_label.label = dgettext ("libgweather", weather_info.get_pressure ());
            wind_label.label = dgettext ("libgweather", weather_info.get_wind ());

            switch (weather_icon.icon_name) {
                case "weather-clear-night-symbolic":
                case "weather-few-clouds-night-symbolic":
                    css_classes = {"night", "background", "csd"};
                    break;
                case "weather-overcast-symbolic":
                    css_classes = {"cloudy", "background", "csd"};
                case "weather-showers-symbolic":
                case "weather-showers-scattered-symbolic":
                    css_classes = {"showers", "background", "csd"};
                    break;
                default:
                    css_classes = {"day", "background", "csd"};
                    break;
            }

            while (hourly_box.get_first_child () != null) {
                hourly_box.remove (hourly_box.get_first_child ());
            }

            unowned var forecast_list = weather_info.get_forecast_list ();
            foreach (unowned var info in forecast_list) {
                hourly_box.append (new HourlyInfoChild (info, location));
                if (hourly_box.get_child_at_index (23) != null) {
                    break;
                }
            }
        });
    }

    private void get_location () {
        stack.visible_child = spinner;

        get_gclue_simple.begin ((obj, res) => {
            var simple = get_gclue_simple.end (res);
            if (simple != null) {
                simple.notify["location"].connect (() => {
                    on_location_updated (simple.location.latitude, simple.location.longitude);
                });

                on_location_updated (simple.location.latitude, simple.location.longitude);
            } else {
                stack.visible_child = placeholder;
            }
        });
    }

    private async GClue.Simple? get_gclue_simple () {
        try {
            var simple = yield new GClue.Simple (Application.get_default ().application_id, GClue.AccuracyLevel.CITY, null);
            return simple;
        } catch (Error e) {
            warning ("Failed to connect to GeoClue2 service: %s", e.message);
            return null;
        }
    }

    private void on_location_updated (double latitude, double longitude) {
        location = GWeather.Location.get_world ();
        location = location.find_nearest_city (latitude, longitude);
        if (location != null) {
            weather_info.location = location;
            weather_info.update ();
            stack.visible_child = box;
        }
    }
}
