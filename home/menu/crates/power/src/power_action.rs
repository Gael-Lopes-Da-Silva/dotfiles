use std::cell::OnceCell;

use gtk4::{glib, subclass::prelude::*};

#[derive(Clone)]
pub struct PowerActionData {
    pub name: String,
    pub command: Vec<String>,
    pub icon_names: Vec<&'static str>,
}

mod imp {
    use super::*;

    #[derive(Default)]
    pub struct PowerAction {
        pub data: OnceCell<PowerActionData>,
    }

    #[glib::object_subclass]
    impl ObjectSubclass for PowerAction {
        const NAME: &'static str = "MenuPowerAction";
        type Type = super::PowerAction;
    }

    impl ObjectImpl for PowerAction {}
}

glib::wrapper! {
    pub struct PowerAction(ObjectSubclass<imp::PowerAction>);
}

impl PowerAction {
    pub fn new(name: &str, command: &[&str], icon_names: &[&'static str]) -> Self {
        let obj: Self = glib::Object::builder().build();
        let _ = obj.imp().data.set(PowerActionData {
            name: name.to_string(),
            command: command.iter().map(|s| (*s).to_string()).collect(),
            icon_names: icon_names.to_vec(),
        });
        obj
    }

    fn data(&self) -> &PowerActionData {
        self.imp()
            .data
            .get()
            .expect("PowerAction data set at construction")
    }

    pub fn name(&self) -> &str {
        &self.data().name
    }

    pub fn command(&self) -> &[String] {
        &self.data().command
    }

    pub fn icon_names(&self) -> &[&'static str] {
        &self.data().icon_names
    }

    pub fn is_destructive(&self) -> bool {
        matches!(self.name(), "Shutdown" | "Reboot")
    }
}
