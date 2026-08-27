use gtk4 as gtk;
use gtk::prelude::*;
use libadwaita as adw;

pub struct Component {
    pub id: &'static str,
    pub title: &'static str,
    pub icon: &'static str,
    pub build: fn() -> gtk::Widget,
}

pub fn status_page(title: &str, icon: &str, description: &str) -> gtk::Widget {
    let page = adw::StatusPage::builder()
        .title(title)
        .icon_name(icon)
        .description(description)
        .build();
    page.upcast()
}
