use component::{status_page, Component};

pub fn component() -> Component {
    Component {
        id: "clipboard",
        title: "Clipboard",
        icon: "edit-copy-symbolic",
        build: build,
    }
}

fn build() -> gtk4::Widget {
    status_page(
        "Clipboard",
        "edit-copy-symbolic",
        "Browse clipboard history.",
    )
}
