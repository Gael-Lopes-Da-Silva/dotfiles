use clap::Parser;
use component::Component;
use gtk4::gdk;
use gtk4::gio;
use gtk4::glib;
use gtk4::prelude::*;
use gtk4::{self as gtk};
use libadwaita as adw;
use libadwaita::prelude::*;

const APP_ID: &str = "dev.menu.Menu";

#[derive(Debug, Clone, Parser)]
#[command(name = "menu", about = "Utility menu with component pages")]
struct Cli {
    /// Focus the Applications page
    #[arg(long, group = "component")]
    applications: bool,

    /// Focus the Audio page
    #[arg(long, group = "component")]
    audio: bool,

    /// Focus the Bluetooth page
    #[arg(long, group = "component")]
    bluetooth: bool,

    /// Focus the Clipboard page
    #[arg(long, group = "component")]
    clipboard: bool,

    /// Focus the Macros page
    #[arg(long, group = "component")]
    macros: bool,

    /// Focus the Power page
    #[arg(long, group = "component")]
    power: bool,

    /// Focus the Soundboard page
    #[arg(long, group = "component")]
    soundboard: bool,
}

impl Cli {
    fn focused_id(&self) -> &'static str {
        if self.applications {
            "applications"
        } else if self.audio {
            "audio"
        } else if self.bluetooth {
            "bluetooth"
        } else if self.clipboard {
            "clipboard"
        } else if self.macros {
            "macros"
        } else if self.power {
            "power"
        } else if self.soundboard {
            "soundboard"
        } else {
            "applications"
        }
    }
}

fn components() -> [Component; 7] {
    [
        applications::component(),
        audio::component(),
        bluetooth::component(),
        clipboard::component(),
        macros::component(),
        power::component(),
        soundboard::component(),
    ]
}

fn build_ui(app: &adw::Application, focused_id: &str) {
    let stack = adw::ViewStack::new();

    for component in components() {
        let page = (component.build)();
        stack.add_titled_with_icon(
            &page,
            Some(component.id),
            component.title,
            component.icon,
        );
    }

    stack.set_visible_child_name(focused_id);

    let switcher = adw::ViewSwitcherBar::builder()
        .stack(&stack)
        .reveal(true)
        .build();

    let header = adw::HeaderBar::new();
    let title = adw::WindowTitle::new("Menu", "");
    header.set_title_widget(Some(&title));

    let toolbar = adw::ToolbarView::new();
    toolbar.add_top_bar(&header);
    toolbar.set_content(Some(&stack));
    toolbar.add_bottom_bar(&switcher);

    let window = adw::ApplicationWindow::builder()
        .application(app)
        .title("Menu")
        .default_width(780)
        .default_height(640)
        .resizable(false)
        .content(&toolbar)
        .build();

    let escape = gtk::EventControllerKey::new();
    escape.set_propagation_phase(gtk::PropagationPhase::Capture);
    escape.connect_key_pressed(glib::clone!(
        #[weak]
        app,
        #[upgrade_or]
        glib::Propagation::Proceed,
        move |_, key, _, _| {
            if key == gdk::Key::Escape {
                app.quit();
                glib::Propagation::Stop
            } else {
                glib::Propagation::Proceed
            }
        }
    ));
    window.add_controller(escape);

    window.present();
}

fn focus_component(window: &gtk::Window, focused_id: &str) {
    let Some(adw_win) = window.downcast_ref::<adw::ApplicationWindow>() else {
        return;
    };
    let Some(content) = adw_win.content() else {
        return;
    };
    let Some(toolbar) = content.downcast_ref::<adw::ToolbarView>() else {
        return;
    };
    let Some(stack_widget) = toolbar.content() else {
        return;
    };
    let Some(stack) = stack_widget.downcast_ref::<adw::ViewStack>() else {
        return;
    };
    stack.set_visible_child_name(focused_id);
}

fn open_or_focus(app: &adw::Application, focused_id: &str) {
    let windows = app.windows();
    if windows.is_empty() {
        build_ui(app, focused_id);
        return;
    }

    for window in windows {
        focus_component(&window, focused_id);
        window.present();
    }
}

fn main() {
    let app = adw::Application::builder()
        .application_id(APP_ID)
        .flags(gio::ApplicationFlags::HANDLES_COMMAND_LINE)
        .build();

    app.connect_command_line(|app, cmdline| {
        let args = cmdline.arguments();
        let cli = Cli::parse_from(args);
        open_or_focus(app, cli.focused_id());
        glib::ExitCode::SUCCESS
    });

    app.connect_activate(|app| {
        open_or_focus(app, "applications");
    });

    app.run();
}
