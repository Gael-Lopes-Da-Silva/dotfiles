use component::{status_page, Component};

pub fn component() -> Component {
    Component {
        id: "bluetooth",
        title: "Bluetooth",
        icon: "bluetooth-active-symbolic",
        build: build,
    }
}

fn build() -> gtk4::Widget {
    status_page(
        "Bluetooth",
        "bluetooth-active-symbolic",
        "Connect and manage Bluetooth devices.",
    )
}
