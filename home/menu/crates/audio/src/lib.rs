use component::{status_page, Component};

pub fn component() -> Component {
    Component {
        id: "audio",
        title: "Audio",
        icon: "audio-volume-high-symbolic",
        build: build,
    }
}

fn build() -> gtk4::Widget {
    status_page(
        "Audio",
        "audio-volume-high-symbolic",
        "Control volume and audio devices.",
    )
}
