use std::cell::OnceCell;

use gtk4::{gio, glib, subclass::prelude::*};

mod imp {
    use super::*;

    #[derive(Default)]
    pub struct AppItem {
        pub info: OnceCell<gio::AppInfo>,
    }

    #[glib::object_subclass]
    impl ObjectSubclass for AppItem {
        const NAME: &'static str = "MenuApplicationItem";
        type Type = super::AppItem;
    }

    impl ObjectImpl for AppItem {}
}

glib::wrapper! {
    pub struct AppItem(ObjectSubclass<imp::AppItem>);
}

impl AppItem {
    pub fn new(info: gio::AppInfo) -> Self {
        let obj: Self = glib::Object::builder().build();
        let _ = obj.imp().info.set(info);
        obj
    }

    pub fn app_info(&self) -> gio::AppInfo {
        self.imp()
            .info
            .get()
            .expect("AppItem info set at construction")
            .clone()
    }

    pub fn name(&self) -> glib::GString {
        gio::prelude::AppInfoExt::name(&self.app_info())
    }
}
