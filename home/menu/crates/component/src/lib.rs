use gtk::prelude::*;
use gtk4 as gtk;
use libadwaita as adw;

pub struct Component {
    pub id: &'static str,
    pub title: &'static str,
    pub icon: &'static str,
    pub build: fn() -> gtk::Widget,
}

impl Copy for Component {}
impl Clone for Component {
    fn clone(&self) -> Self {
        *self
    }
}

pub fn status_page(title: &str, icon: &str, description: &str) -> gtk::Widget {
    let page = adw::StatusPage::builder()
        .title(title)
        .icon_name(icon)
        .description(description)
        .build();
    page.upcast()
}

pub fn loading_page(title: &str) -> gtk::Widget {
    let page = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .vexpand(true)
        .hexpand(true)
        .build();

    let centered = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .valign(gtk::Align::Center)
        .vexpand(true)
        .spacing(12)
        .build();

    let spinner = gtk::Spinner::new();
    spinner.start();
    spinner.set_halign(gtk::Align::Center);

    let label = gtk::Label::builder()
        .label(title)
        .css_classes(["title-4"])
        .halign(gtk::Align::Center)
        .build();

    centered.append(&spinner);
    centered.append(&label);
    page.append(&centered);
    page.upcast()
}

/// Run blocking work on a background thread, then deliver the result on the main loop.
pub fn spawn_background<T, F, C>(work: F, callback: C)
where
    T: Send + 'static,
    F: FnOnce() -> T + Send + 'static,
    C: FnOnce(T) + 'static,
{
    use std::sync::mpsc::{TryRecvError, sync_channel};
    use std::time::Duration;

    let (tx, rx) = sync_channel(1);
    std::thread::spawn(move || {
        let _ = tx.send(work());
    });

    let mut callback = Some(callback);
    gtk::glib::timeout_add_local(Duration::ZERO, move || match rx.try_recv() {
        Ok(result) => {
            if let Some(cb) = callback.take() {
                cb(result);
            }
            gtk::glib::ControlFlow::Break
        }
        Err(TryRecvError::Empty) => gtk::glib::ControlFlow::Continue,
        Err(TryRecvError::Disconnected) => gtk::glib::ControlFlow::Break,
    });
}

/// Defer work until the next main-loop iteration (for main-thread-only APIs).
pub fn defer_idle<F>(func: F)
where
    F: FnOnce() + 'static,
{
    gtk::glib::idle_add_local_once(func);
}
