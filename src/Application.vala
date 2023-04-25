/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2017-2023 Danielle Foré (https://danirabbit.github.io/)
 */

public class Nimbus : Gtk.Application {
    public Nimbus () {
        Object (
            application_id: "com.github.danrabbit.nimbus",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void startup () {
        var quit_action = new SimpleAction ("quit", null);

        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});

        quit_action.activate.connect (quit);

        base.startup ();
    }

    protected override void activate () {
        if (active_window == null) {
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("com/github/danrabbit/nimbus/Application.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            add_window (new MainWindow (this));
        }

        active_window.present ();
    }

    public static int main (string[] args) {
        return new Nimbus ().run (args);
    }
}
