/*
* Copyright (c) 2017 Daniel Foré (http://danielfore.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

public class MainWindow : Gtk.Dialog {
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
        Object (application: application,
                deletable: false,
                icon_name: "com.github.danrabbit.nimbus",
                resizable: false,
                skip_taskbar_hint: true,
                title: _("Nimbus"),
                type_hint: Gdk.WindowTypeHint.UTILITY,
                height_request: 272,
                width_request: 500);
    }

    construct {
        set_keep_below (true);
        stick ();

        get_location.begin ();

        weather_info = new GWeather.Info (location, GWeather.ForecastType.LIST);

        var weather_icon = new Gtk.Image.from_icon_name ("%s-symbolic".printf (weather_info.get_icon_name ()), Gtk.IconSize.LARGE_TOOLBAR);

        var weather_label = new Gtk.Label (weather_info.get_sky ());
        weather_label.halign = Gtk.Align.START;
        weather_label.hexpand = true;
        weather_label.get_style_context ().add_class ("weather");

        var temp_label = new Gtk.Label (weather_info.get_temp ());
        temp_label.halign = Gtk.Align.START;
        temp_label.get_style_context ().add_class ("temperature");

        var weather_grid = new Gtk.Grid ();
        weather_grid.column_spacing = 6;
        weather_grid.halign = Gtk.Align.START;
        weather_grid.attach (weather_icon, 0, 0, 1, 1);
        weather_grid.attach (weather_label, 1, 0, 1, 1);
        weather_grid.attach (temp_label, 0, 1, 2, 1);

        var location_label = new Gtk.Label ("");
        location_label.halign = Gtk.Align.END;
        location_label.valign = Gtk.Align.END;
        location_label.margin_bottom = 12;

        var grid = new Gtk.Grid ();
        grid.margin_bottom = 6;
        grid.margin_end = 18;
        grid.margin_start = 18;
        grid.attach (weather_grid, 0, 0, 1, 1);
        grid.attach (location_label, 1, 0, 1, 1);

        var spinner = new Gtk.Spinner ();
        spinner.active = true;
        spinner.halign = Gtk.Align.CENTER;
        spinner.vexpand = true;

        var alert_label = new Gtk.Label (_("Unable to Get Location"));

        stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        stack.vhomogeneous = true;
        stack.add (spinner);
        stack.add_named (grid, "weather");
        stack.add_named (alert_label, "alert");

        var content_box = get_content_area () as Gtk.Box;
        content_box.border_width = 0;
        content_box.add (stack);
        content_box.show_all ();

        var action_box = get_action_area () as Gtk.Box;
        action_box.visible = false;

        button_press_event.connect ((e) => {
            if (e.button == Gdk.BUTTON_PRIMARY) {
                begin_move_drag ((int) e.button, (int) e.x_root, (int) e.y_root, e.time);
                return true;
            }
            return false;
        });

        focus_in_event.connect (() => {
            weather_info.update ();
        });

        weather_info.updated.connect (() => {
            if (location == null) {
                return;
            }

            location_label.label = location.get_city_name ();

            weather_icon.icon_name = "%s-symbolic".printf (weather_info.get_icon_name ());
            weather_label.label = weather_info.get_sky ();

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
