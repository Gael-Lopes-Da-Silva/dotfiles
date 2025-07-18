#include <gtk/gtk.h>
#include <dirent.h>
#include <string.h>
#include <glib/gstdio.h>
#include "config.h"

typedef struct {
    GtkWidget *button;
    char *file_path;
} SoundButton;

static GPtrArray *sound_buttons = NULL;
static GtkWidget *search_entry = NULL;
static guint debounce_timeout = 0;

static void on_stop_button_clicked(GtkWidget *button, gpointer data) {
    gchar *argv[] = {"dsound_stop", NULL};
    GError *error = NULL;

    if (!g_spawn_async(NULL, argv, NULL, G_SPAWN_SEARCH_PATH, NULL, NULL, NULL, &error)) {
        g_printerr("Error stopping sound: %s\n", error->message);
        g_error_free(error);
    }
}

static void on_button_clicked(GtkWidget *button, gpointer data) {
    SoundButton *sound = (SoundButton *)data;
    gchar *argv[] = {"dsound_play", sound->file_path, NULL};
    GError *error = NULL;

    if (!g_spawn_async(NULL, argv, NULL, G_SPAWN_SEARCH_PATH, NULL, NULL, NULL, &error)) {
        g_printerr("Error playing sound: %s\n", error->message);
        g_error_free(error);
    }
}

static void free_sound_button(gpointer data) {
    SoundButton *sound = (SoundButton *)data;
    g_free(sound->file_path);
    g_free(sound);
}

static void on_search_changed(GtkSearchEntry *search_entry, gpointer grid) {
    const char *search_text = gtk_editable_get_text(GTK_EDITABLE(search_entry));
    gchar *search_lower = g_utf8_strdown(search_text, -1);

    for (guint i = 0; i < sound_buttons->len; i++) {
        SoundButton *sound = g_ptr_array_index(sound_buttons, i);
        const char *label = gtk_button_get_label(GTK_BUTTON(sound->button));
        gchar *label_lower = g_utf8_strdown(label, -1);

        if (search_lower[0] == '\0' || strstr(label_lower, search_lower)) {
            gtk_widget_set_visible(sound->button, TRUE);
        } else {
            gtk_widget_set_visible(sound->button, FALSE);
        }

        g_free(label_lower);
    }

    g_free(search_lower);
    gtk_widget_queue_resize(grid);
}

static void create_soundboard(GtkWidget *grid, GtkWindow *parent_window) {
    DIR *dir;
    struct dirent *entry;
    int row = 0;
    int col = 0;
    const int max_cols = 3;

    for (guint i = 0; i < sound_buttons->len; i++) {
        SoundButton *sound = g_ptr_array_index(sound_buttons, i);
        gtk_grid_remove(GTK_GRID(grid), sound->button);
    }
    g_ptr_array_set_size(sound_buttons, 0);

    dir = opendir(soundfolder);
    if (!dir) {
        GtkWidget *dialog = gtk_message_dialog_new(parent_window, GTK_DIALOG_MODAL | GTK_DIALOG_DESTROY_WITH_PARENT, GTK_MESSAGE_ERROR, GTK_BUTTONS_OK, "Could not open directory: %s", soundfolder);
        gtk_window_set_title(GTK_WINDOW(dialog), "Error");
        gtk_window_set_transient_for(GTK_WINDOW(dialog), parent_window);
        gtk_window_set_modal(GTK_WINDOW(dialog), TRUE);
        g_signal_connect(dialog, "response", G_CALLBACK(gtk_window_destroy), NULL);
        gtk_widget_realize(GTK_WIDGET(parent_window));
        gtk_window_present(GTK_WINDOW(dialog));
        gtk_widget_grab_focus(dialog);
        return;
    }

    while ((entry = readdir(dir)) != NULL) {
        if (strstr(entry->d_name, ".mp3") || strstr(entry->d_name, ".MP3") ||
            strstr(entry->d_name, ".wav") || strstr(entry->d_name, ".WAV")) {
            char *file_path = g_build_filename(soundfolder, entry->d_name, NULL);

            SoundButton *sound = g_new(SoundButton, 1);
            sound->file_path = file_path;
            sound->button = gtk_button_new_with_label(entry->d_name);

            gtk_widget_set_hexpand(sound->button, TRUE);
            gtk_widget_set_halign(sound->button, GTK_ALIGN_FILL);
            g_signal_connect(sound->button, "clicked", G_CALLBACK(on_button_clicked), sound);
            gtk_grid_attach(GTK_GRID(grid), sound->button, col, row, 1, 1);
            g_object_set_data_full(G_OBJECT(sound->button), "sound-data", sound, NULL);
            g_ptr_array_add(sound_buttons, sound);

            col++;
            if (col >= max_cols) {
                col = 0;
                row++;
            }
        }
    }

    closedir(dir);

    if (search_entry) {
        on_search_changed(GTK_SEARCH_ENTRY(search_entry), grid);
    }
}

static gboolean debounce_refresh(gpointer user_data) {
    gpointer *data = (gpointer *)user_data;
    GtkWidget *grid = GTK_WIDGET(data[0]);
    GtkWindow *parent_window = GTK_WINDOW(data[1]);
    create_soundboard(grid, parent_window);
    debounce_timeout = 0;
    g_free(data);
    return G_SOURCE_REMOVE;
}

static void on_directory_changed(GFileMonitor *monitor, GFile *file, GFile *other_file, GFileMonitorEvent event_type, gpointer user_data) {
    if (event_type == G_FILE_MONITOR_EVENT_CREATED || event_type == G_FILE_MONITOR_EVENT_DELETED) {
        if (debounce_timeout == 0) {
            gpointer *data = g_new(gpointer, 2);
            data[0] = user_data;
            data[1] = gtk_widget_get_ancestor(GTK_WIDGET(user_data), GTK_TYPE_WINDOW);
            debounce_timeout = g_timeout_add(100, debounce_refresh, data);
        }
    }
}

static void cleanup_sound_buttons(void) {
    if (sound_buttons) {
        g_ptr_array_free(sound_buttons, TRUE);
        sound_buttons = NULL;
    }
}

static void activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Dsound");
    gtk_window_set_default_size(GTK_WINDOW(window), 600, 400);

    GtkWidget *vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10);
    gtk_widget_set_margin_start(vbox, 10);
    gtk_widget_set_margin_end(vbox, 10);
    gtk_widget_set_margin_top(vbox, 10);
    gtk_widget_set_margin_bottom(vbox, 10);
    gtk_window_set_child(GTK_WINDOW(window), vbox);

    GtkWidget *search_box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_set_halign(search_box, GTK_ALIGN_CENTER);
    gtk_box_append(GTK_BOX(vbox), search_box);

    search_entry = gtk_search_entry_new();
    gtk_widget_set_size_request(search_entry, 300, -1);
    gtk_box_append(GTK_BOX(search_box), search_entry);

    GtkWidget *scrolled_window = gtk_scrolled_window_new();
    gtk_box_append(GTK_BOX(vbox), scrolled_window);
    gtk_widget_set_vexpand(scrolled_window, TRUE);

    GtkWidget *grid = gtk_grid_new();
    gtk_grid_set_row_spacing(GTK_GRID(grid), 10);
    gtk_grid_set_column_spacing(GTK_GRID(grid), 10);
    gtk_widget_set_hexpand(grid, TRUE);
    gtk_widget_set_halign(grid, GTK_ALIGN_FILL);
    gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(scrolled_window), grid);

    sound_buttons = g_ptr_array_new_with_free_func(free_sound_button);

    create_soundboard(grid, GTK_WINDOW(window));
    g_signal_connect(search_entry, "search-changed", G_CALLBACK(on_search_changed), grid);

    GFile *dir_file = g_file_new_for_path(soundfolder);
    GFileMonitor *monitor = g_file_monitor_directory(dir_file, G_FILE_MONITOR_NONE, NULL, NULL);
    if (monitor) {
        g_signal_connect(monitor, "changed", G_CALLBACK(on_directory_changed), grid);
    } else {
        g_printerr("Failed to set up directory monitor for %s\n", soundfolder);
    }
    g_object_unref(dir_file);

    GtkWidget *stop_box = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
    gtk_widget_set_halign(stop_box, GTK_ALIGN_END);
    gtk_box_append(GTK_BOX(vbox), stop_box);

    GtkWidget *stop_button = gtk_button_new_with_label("Stop");
    g_signal_connect(stop_button, "clicked", G_CALLBACK(on_stop_button_clicked), NULL);
    gtk_box_append(GTK_BOX(stop_box), stop_button);

    gtk_window_present(GTK_WINDOW(window));
}

int main(int argc, char *argv[]) {
    GtkApplication *app = gtk_application_new("com.example.Soundboard", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    g_signal_connect(app, "shutdown", G_CALLBACK(cleanup_sound_buttons), NULL);

    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    return status;
}
