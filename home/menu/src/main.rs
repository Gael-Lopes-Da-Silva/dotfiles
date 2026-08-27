use clap::Parser;
use component::Component;
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

    window.present();
}

fn main() {
    let cli = Cli::parse();
    let focused_id = cli.focused_id();

    let app = adw::Application::builder().application_id(APP_ID).build();

    app.connect_activate(move |app| {
        build_ui(app, focused_id);
    });

    // Clap already consumed argv; do not let GTK re-parse unknown flags.
    app.run_with_args(&[] as &[&str]);
}
