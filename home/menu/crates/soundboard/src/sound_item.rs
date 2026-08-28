use std::cell::{Cell, OnceCell};

use gtk4::{
    glib::{self, Properties},
    prelude::*,
    subclass::prelude::*,
};

#[derive(Clone)]
pub struct SoundboardItemData {
    pub display_name: String,
    pub file_path: String,
}

mod imp {
    use super::*;

    #[derive(Properties, Default)]
    #[properties(wrapper_type = super::SoundboardItem)]
    pub struct SoundboardItem {
        #[property(get, set)]
        pub is_playing: Cell<bool>,
        pub data: OnceCell<SoundboardItemData>,
    }

    #[glib::object_subclass]
    impl ObjectSubclass for SoundboardItem {
        const NAME: &'static str = "MenuSoundboardItem";
        type Type = super::SoundboardItem;
    }

    #[glib::derived_properties]
    impl ObjectImpl for SoundboardItem {}
}

glib::wrapper! {
    pub struct SoundboardItem(ObjectSubclass<imp::SoundboardItem>);
}

impl SoundboardItem {
    pub fn new(display_name: &str, file_path: &str) -> Self {
        Self::from_data(&SoundboardItemData {
            display_name: display_name.to_string(),
            file_path: file_path.to_string(),
        })
    }

    pub fn from_data(data: &SoundboardItemData) -> Self {
        let obj: Self = glib::Object::builder().build();
        let _ = obj.imp().data.set(data.clone());
        obj
    }

    fn data(&self) -> &SoundboardItemData {
        self.imp()
            .data
            .get()
            .expect("SoundboardItem data set at construction")
    }

    pub fn display_name(&self) -> &str {
        &self.data().display_name
    }

    pub fn file_path(&self) -> &str {
        &self.data().file_path
    }
}
