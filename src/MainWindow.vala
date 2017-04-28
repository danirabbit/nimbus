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
*
*/

public class MainWindow : Gtk.Dialog {
    private const string CSS = """
        @define-color colorPrimary #42baea;
        @define-color bg_highlight_color shade (@colorPrimary, 1.4);

        .titlebar,
        .background {
            background-color: @colorPrimary;
            color: #fff;
            icon-shadow: 0 1px 1px shade (@colorPrimary, 0.82);
            text-shadow: 0 1px 1px shade (@colorPrimary, 0.82);
        }

        GtkDialog .window-frame {
            border-radius: 4px;
            box-shadow:
                0 0 0 1px alpha (shade (@colorPrimary, 0.6), 0.55),
                0 8px 10px 1px alpha (#000, 0.14),
                0 3px 14px 2px alpha (#000, 0.12),
                0 5px 5px -3px alpha (#000, 0.4),
                0 14px 28px transparent;
        }

        .weather {
            font-size: 14px;
        }

        .temperature {
            font-size: 36px;
        }
    """;
 
    public MainWindow (Gtk.Application application) {
        Object (application: application,
                width_request: 500,
                deletable: false,
                resizable: false);
    }

    construct {
        set_keep_above (true);

        var provider = new Gtk.CssProvider ();
        try {
            provider.load_from_data (CSS, CSS.length);
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (Error e) {
            critical (e.message);
        }

        var weather_icon = new Gtk.Image.from_icon_name ("weather-clear-symbolic", Gtk.IconSize.LARGE_TOOLBAR);

        var weather_label = new Gtk.Label ("Sunny");
        weather_label.halign = Gtk.Align.START;
        weather_label.hexpand = true;
        weather_label.get_style_context ().add_class ("weather");

        var temp_label = new Gtk.Label ("70°");
        temp_label.halign = Gtk.Align.START;
        temp_label.get_style_context ().add_class ("temperature");

        var weather_grid = new Gtk.Grid ();
        weather_grid.column_spacing = 6;
        weather_grid.halign = Gtk.Align.START;
        weather_grid.attach (weather_icon, 0, 0, 1, 1);
        weather_grid.attach (weather_label, 1, 0, 1, 1);
        weather_grid.attach (temp_label, 0, 1, 2, 1);

        var location_label = new Gtk.Label ("Sacramento");
        location_label.halign = Gtk.Align.END;
        location_label.valign = Gtk.Align.END;
        location_label.margin_bottom = 12;

        var grid = new Gtk.Grid ();
        grid.margin_bottom = 6;
        grid.margin_end = 18;
        grid.margin_start = 18;
        grid.attach (weather_grid, 0, 0, 1, 1);
        grid.attach (location_label, 1, 0, 1, 1);

        var content_box = get_content_area () as Gtk.Box;
        content_box.border_width = 0;
        content_box.add (grid);
        content_box.show_all ();

        var action_box = get_action_area () as Gtk.Box;
        action_box.visible = false;
    }
}
