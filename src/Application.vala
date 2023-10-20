/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * SPDX-FileCopyrightText: 2017-2023 Danielle Foré (https://danirabbit.github.io/)
 */

public class Nimbus : Gtk.Application {
    public Nimbus () {
        Object (
            application_id: "io.github.danirabbit.nimbus",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void startup () {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

        var quit_action = new SimpleAction ("quit", null);

        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});

        quit_action.activate.connect (quit);

        base.startup ();
    }

    protected override void activate () {
        if (active_window == null) {
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("io/github/danirabbit/nimbus/Application.css");
            Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            add_window (new MainWindow ());
        }

        active_window.present ();
    }

    public static int main (string[] args) {
        return new Nimbus ().run (args);
    }
}
