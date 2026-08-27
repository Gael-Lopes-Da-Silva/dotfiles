use component::{status_page, Component};

pub fn component() -> Component {
    Component {
        id: "applications",
        title: "Applications",
        icon: "view-app-grid-symbolic",
        build: build,
    }
}

fn build() -> gtk4::Widget {
    status_page(
        "Applications",
        "view-app-grid-symbolic",
        "Launch and manage applications.",
    )
}
