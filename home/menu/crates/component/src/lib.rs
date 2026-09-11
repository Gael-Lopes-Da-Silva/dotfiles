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

/// Defer work until after the widget has been painted at least once.
pub fn defer_after_paint<F>(widget: &impl IsA<gtk::Widget>, func: F)
where
    F: FnOnce() + 'static,
{
    use std::cell::{Cell, RefCell};
    use std::rc::Rc;
    use std::time::Duration;

    let func = Rc::new(RefCell::new(Some(func)));
    let done = Rc::new(Cell::new(false));

    let run = gtk::glib::clone!(
        #[strong]
        func,
        #[strong]
        done,
        move || {
            if done.replace(true) {
                return;
            }
            if let Some(func) = func.borrow_mut().take() {
                func();
            }
        }
    );

    widget.add_tick_callback(gtk::glib::clone!(
        #[strong]
        run,
        move |_, _| {
            // Schedule after this frame so the tab switch paints first.
            gtk::glib::idle_add_local_once(run.clone());
            gtk::glib::ControlFlow::Break
        }
    ));

    // Fallback if the widget does not receive a frame tick promptly.
    gtk::glib::timeout_add_local_once(
        Duration::from_millis(32),
        gtk::glib::clone!(
            #[strong]
            run,
            move || run()
        ),
    );
}

/// Defer work until the next main-loop iteration (for main-thread-only APIs).
pub fn defer_idle<F>(func: F)
where
    F: FnOnce() + 'static,
{
    gtk::glib::idle_add_local_once(func);
}

pub fn empty_list_label(text: &str) -> gtk::Label {
    gtk::Label::builder()
        .label(text)
        .halign(gtk::Align::Center)
        .valign(gtk::Align::Center)
        .vexpand(true)
        .css_classes(["dim-label"])
        .build()
}

pub fn update_list_empty_state(
    selection: &gtk::SingleSelection,
    empty: &gtk::Label,
    loading: &gtk::Spinner,
) {
    empty.set_visible(!loading.is_visible() && selection.n_items() == 0);
}

/// True if any MenuButton under `root` currently has its popover open.
pub fn has_open_popover(root: &impl IsA<gtk::Widget>) -> bool {
    fn walk(widget: &gtk::Widget) -> bool {
        if let Ok(btn) = widget.clone().downcast::<gtk::MenuButton>()
            && let Some(popover) = btn.popover()
            && popover.is_visible()
        {
            return true;
        }
        let mut child = widget.first_child();
        while let Some(c) = child {
            if walk(&c) {
                return true;
            }
            child = c.next_sibling();
        }
        false
    }
    walk(root.upcast_ref())
}
