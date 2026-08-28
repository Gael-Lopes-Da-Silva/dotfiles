use std::cell::OnceCell;

use gtk4::{glib, subclass::prelude::*};

#[derive(Clone)]
pub struct ClipboardItemData {
    pub item_id: String,
    pub text: String,
    pub is_image: bool,
}

mod imp {
    use super::*;

    #[derive(Default)]
    pub struct ClipboardItem {
        pub data: OnceCell<ClipboardItemData>,
    }

    #[glib::object_subclass]
    impl ObjectSubclass for ClipboardItem {
        const NAME: &'static str = "MenuClipboardItem";
        type Type = super::ClipboardItem;
    }

    impl ObjectImpl for ClipboardItem {}
}

glib::wrapper! {
    pub struct ClipboardItem(ObjectSubclass<imp::ClipboardItem>);
}

impl ClipboardItem {
    pub fn new(item_id: &str, text: &str) -> Self {
        Self::from_data(&ClipboardItemData {
            item_id: item_id.to_string(),
            text: text.to_string(),
            is_image: text.to_lowercase().contains("binary data"),
        })
    }

    pub fn from_data(data: &ClipboardItemData) -> Self {
        let obj: Self = glib::Object::builder().build();
        let _ = obj.imp().data.set(data.clone());
        obj
    }

    fn data(&self) -> &ClipboardItemData {
        self.imp()
            .data
            .get()
            .expect("ClipboardItem data set at construction")
    }

    pub fn item_id(&self) -> &str {
        &self.data().item_id
    }

    pub fn text(&self) -> &str {
        &self.data().text
    }

    pub fn is_image(&self) -> bool {
        self.data().is_image
    }
}
