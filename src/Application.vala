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

public class Nimbus : Gtk.Application {
    public Nimbus () {
        Object (application_id: "com.github.danrabbit.nimbus",
        flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate () {
        var app_window = new MainWindow (this);
        app_window.show ();

        var quit_action = new SimpleAction ("quit", null);

        quit_action.activate.connect (() => {
            if (app_window != null) {
                app_window.destroy ();
            }
        });

        add_action (quit_action);
        add_accelerator ("<Control>q", "app.quit", null);

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/danrabbit/nimbus/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    public static int main (string[] args) {
        var app = new Nimbus ();
        return app.run (args);
    }
}
