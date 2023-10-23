/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2017-2023 Danielle Foré (https://danirabbit.github.io/)
 */

public class HourlyInfoChild : Gtk.FlowBoxChild {
    public GWeather.Info weather_info { get; construct; }
    public GWeather.Location location{ get; construct; }

    public HourlyInfoChild (GWeather.Info weather_info, GWeather.Location location) {
        Object (
            weather_info: weather_info,
            location: location
        );
    }

    class construct {
        set_css_name ("hourly");
    }

    construct {
        long unix_date;
        weather_info.get_value_update (out unix_date);

        var datetime = new DateTime.from_unix_utc (unix_date).to_timezone (location.get_timezone ());

        var time_label = new Gtk.Label (datetime.format (_("%l %p")).replace (" ", ""));
        time_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);

        var image = new Gtk.Image.from_icon_name (weather_info.get_symbolic_icon_name ()) {
            tooltip_text = get_conditions ()
        };
        image.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);

        var temp_label = new Gtk.Label (weather_info.get_temp ());

        var box = new Gtk.Box (VERTICAL, 0);
        box.append (time_label);
        box.append (image);
        box.append (temp_label);

        focusable = false;
        child = box;
    }

    private string get_conditions () {
        var conditions = weather_info.get_conditions ();
        if (conditions == "-") {
            conditions = weather_info.get_sky ();
        }

        return conditions;
    }
}
