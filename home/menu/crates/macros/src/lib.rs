use component::{status_page, Component};

pub fn component() -> Component {
    Component {
        id: "macros",
        title: "Macros",
        icon: "input-keyboard-symbolic",
        build: build,
    }
}

fn build() -> gtk4::Widget {
    status_page(
        "Macros",
        "input-keyboard-symbolic",
        "Create and run macros.",
    )
}
