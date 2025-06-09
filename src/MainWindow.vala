/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2017-2023 Danielle Foré (https://danirabbit.github.io/)
 */

public class MainWindow : Gtk.ApplicationWindow {
    private Gtk.Stack stack;
    private Gtk.Spinner spinner;
    private Gtk.Grid grid;
    private Granite.Placeholder placeholder;
    private GWeather.Location? location = null;
    private GWeather.Info weather_info;
    private Gtk.Button refresh_button;
    private Gtk.Button forecast_button;
    private Gtk.Popover forecast_popover;
    private GLib.Settings settings;

    construct {
        settings = new GLib.Settings ("io.elementary.nimbus");

        weather_info = new GWeather.Info (location) {
            application_id = Application.get_default ().application_id,
            contact_info = "danielle@elementary.io",
            enabled_providers = METAR | MET_NO
        };

        // Main weather display
        var weather_icon = new Gtk.Image () {
            pixel_size = 64
        };
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

        var feels_label = new Gtk.Label ("") {
            halign = Gtk.Align.START
        };
        feels_label.add_css_class (Granite.STYLE_CLASS_H4_LABEL);

        var location_label = new Gtk.Label ("") {
            halign = Gtk.Align.END,
            valign = Gtk.Align.START
        };

        // Weather details
        var wind_icon = new Gtk.Image.from_icon_name ("weather-windy-symbolic") {
            halign = END,
            tooltip_text = _("Wind")
        };
        wind_icon.add_css_class ("conditions");

        var wind_label = new Gtk.Label ("") {
            halign = START
        };

        var humidity_icon = new Gtk.Image.from_icon_name ("humidity-symbolic") {
            halign = END,
            tooltip_text = _("Humidity")
        };
        humidity_icon.add_css_class ("conditions");

        var humidity_label = new Gtk.Label ("") {
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

        var dew_icon = new Gtk.Image.from_icon_name ("dew-symbolic") {
            halign = END,
            tooltip_text = _("Dew Point")
        };
        dew_icon.add_css_class ("conditions");

        var dew_label = new Gtk.Label ("") {
            halign = START
        };

        // Forecast UI
        forecast_button = new Gtk.Button.with_label (_("Forecast")) {
            visible = false,
            sensitive = false
        };
        forecast_button.add_css_class (Granite.STYLE_CLASS_FLAT);

        var forecast_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };

        forecast_popover = new Gtk.Popover () {
            child = forecast_box,
            position = Gtk.PositionType.BOTTOM
        };
        forecast_button.popover = forecast_popover;

        // Main grid layout
        grid = new Gtk.Grid () {
            row_spacing = 12,
            column_spacing = 12,
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        grid.attach (weather_icon, 0, 0, 1, 2);
        grid.attach (temp_label, 1, 0, 1, 2);
        grid.attach (weather_label, 2, 0);
        grid.attach (location_label, 2, 1);
        grid.attach (feels_label, 1, 2, 2);

        grid.attach (wind_icon, 0, 3);
        grid.attach (wind_label, 1, 3, 2);
        grid.attach (humidity_icon, 0, 4);
        grid.attach (humidity_label, 1, 4, 2);
        grid.attach (visibility_icon, 0, 5);
        grid.attach (visibility_label, 1, 5, 2);
        grid.attach (pressure_icon, 0, 6);
        grid.attach (pressure_label, 1, 6, 2);
        grid.attach (dew_icon, 0, 7);
        grid.attach (dew_label, 1, 7, 2);
        grid.add_css_class ("weather");

        // Loading spinner
        spinner = new Gtk.Spinner () {
            halign = Gtk.Align.CENTER,
            vexpand = true,
            spinning = true
        };

        // Error placeholder
        placeholder = new Granite.Placeholder (_("Unable to Get Location")) {
            icon = new ThemedIcon ("location-disabled-symbolic"),
            description = _("Make sure location access is turned on in <a href='settings://privacy/location'>System Settings → Security &amp; Privacy</a>")
        };

        // Refresh button
        refresh_button = new Gtk.Button.from_icon_name ("view-refresh-symbolic") {
            tooltip_text = _("Refresh")
        };
        refresh_button.add_css_class (Granite.STYLE_CLASS_FLAT);
        refresh_button.clicked.connect (() => {
            if (location != null) {
                weather_info.update ();
                stack.visible_child = spinner;
            } else {
                get_location ();
            }
        });

        // Headerbar
        var headerbar = new Gtk.HeaderBar () {
            title_widget = new Gtk.Label ("")
        };
        headerbar.add_css_class (Granite.STYLE_CLASS_FLAT);
        headerbar.add_css_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);
        headerbar.pack_end (refresh_button);
        headerbar.pack_end (forecast_button);

        // Stack for main content
        stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE,
            valign = Gtk.Align.CENTER,
            vhomogeneous = false
        };
        stack.add_child (spinner);
        stack.add_child (grid);
        stack.add_child (placeholder);

        var window_handle = new Gtk.WindowHandle () {
            child = stack
        };

        child = window_handle;
        default_width = 380;
        default_height = 600;
        icon_name = Application.get_default ().application_id;
        titlebar = headerbar;
        title = _("Nimbus");

        // Load initial location
        get_location ();

        // Update when window becomes active
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

        // Handle weather updates
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

            double feels_temp;
            weather_info.get_value_feels_like_temp (GWeather.TemperatureUnit.DEFAULT, out feels_temp);
            feels_label.label = _("Feels like %i°").printf ((int) feels_temp);

            visibility_label.label = dgettext ("libgweather", weather_info.get_visibility ());
            pressure_label.label = dgettext ("libgweather", weather_info.get_pressure ());
            wind_label.label = dgettext ("libgweather", weather_info.get_wind ());
            
            double dew_point;
            weather_info.get_value_dew (GWeather.TemperatureUnit.DEFAULT, out dew_point);
            dew_label.label = _("%i°").printf ((int) dew_point);
            
            humidity_label.label = weather_info.get_humidity ().to_string () + "%";

            // Update forecast button
            forecast_button.visible = true;
            forecast_button.sensitive = true;
            update_forecast ();

            // Update theme based on weather
            update_theme (weather_icon.icon_name);

            stack.visible_child = grid;
        });

        // Handle forecast button click
        forecast_button.clicked.connect (update_forecast);
    }

    private void update_theme (string icon_name) {
        switch (icon_name) {
            case "weather-clear-night-symbolic":
            case "weather-few-clouds-night-symbolic":
                add_css_class ("night");
                remove_css_class ("day");
                remove_css_class ("rain");
                remove_css_class ("cloudy");
                break;
            case "weather-overcast-symbolic":
                add_css_class ("cloudy");
                remove_css_class ("day");
                remove_css_class ("night");
                remove_css_class ("rain");
                break;
            case "weather-showers-symbolic":
            case "weather-showers-scattered-symbolic":
            case "weather-rain-symbolic":
                add_css_class ("rain");
                remove_css_class ("day");
                remove_css_class ("night");
                remove_css_class ("cloudy");
                break;
            default:
                add_css_class ("day");
                remove_css_class ("night");
                remove_css_class ("rain");
                remove_css_class ("cloudy");
                break;
        }
    }

    private void update_forecast () {
        if (location == null) return;

        var forecast_box = forecast_popover.child as Gtk.Box;
        foreach (var child in forecast_box.get_children ()) {
            child.destroy ();
        }

        var now = new GLib.DateTime.now_local ();
        var time_label = new Gtk.Label (now.format ("%A, %B %d")) {
            halign = Gtk.Align.CENTER
        };
        time_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);
        forecast_box.append (time_label);

        for (int i = 0; i < 5; i++) {
            var forecast_day = now.add_days (i);
            var day_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
                halign = Gtk.Align.CENTER
            };

            var day_label = new Gtk.Label (forecast_day.format ("%a")) {
                width_chars = 3
            };

            double min_temp, max_temp;
            weather_info.get_value_temp_min_max (i, GWeather.TemperatureUnit.DEFAULT, out min_temp, out max_temp);

            var temp_label = new Gtk.Label (_("%i°/%i°").printf ((int) min_temp, (int) max_temp)) {
                width_chars = 8
            };

            var icon = new Gtk.Image.from_icon_name (weather_info.get_symbolic_icon_name_for_time (i * 24)) {
                pixel_size = 24
            };

            day_box.append (day_label);
            day_box.append (icon);
            day_box.append (temp_label);
            forecast_box.append (day_box);
        }
    }

    private void get_location () {
        stack.visible_child = spinner;
        forecast_button.visible = false;

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
        }
    }
}
