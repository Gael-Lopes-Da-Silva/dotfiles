use component::{status_page, Component};

pub fn component() -> Component {
    Component {
        id: "soundboard",
        title: "Soundboard",
        icon: "audio-headphones-symbolic",
        build: build,
    }
}

fn build() -> gtk4::Widget {
    status_page(
        "Soundboard",
        "audio-headphones-symbolic",
        "Play soundboard clips.",
    )
}
