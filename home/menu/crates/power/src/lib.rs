use component::{status_page, Component};

pub fn component() -> Component {
    Component {
        id: "power",
        title: "Power",
        icon: "system-shutdown-symbolic",
        build: build,
    }
}

fn build() -> gtk4::Widget {
    status_page(
        "Power",
        "system-shutdown-symbolic",
        "Power and session actions.",
    )
}
