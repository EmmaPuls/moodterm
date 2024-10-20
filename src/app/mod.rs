mod menu;

use std::sync::RwLock;

use cacao::appkit::window::{Window, WindowConfig, WindowDelegate};
use cacao::appkit::{App, AppDelegate};

use crate::command_line_gui::CommandLineGuiWindow;
use crate::terminal_evaluation;

use menu::menu;

/// A helper method to handle checking for window existence, and creating
/// it if not - then showing it.
fn open_or_show<T, F>(window: &RwLock<Option<Window<T>>>, vendor: F)
where
    T: WindowDelegate + 'static,
    F: Fn() -> (WindowConfig, T),
{
    let mut lock = window.write().unwrap();

    if let Some(win) = &*lock {
        win.show();
    } else {
        let (config, delegate) = vendor();
        let win = Window::with(config, delegate);
        win.show();
        *lock = Some(win);
    }
}

#[derive(Default)]
pub struct MoodTermApp {
    pub window: RwLock<Option<Window<CommandLineGuiWindow>>>,
}

impl AppDelegate for MoodTermApp {
    fn did_finish_launching(&self) {
        // Menu settings
        App::set_menu(menu());

        // Start app
        App::activate();
        open_or_show(&self.window, || {
            (WindowConfig::default(), CommandLineGuiWindow::new())
        });
    }

    fn did_become_active(&self) {
        // Start the terminal emulation in a separate thread
        std::thread::spawn(move || {
            terminal_evaluation::start_terminal_emulation();
        });
    }

    fn should_terminate_after_last_window_closed(&self) -> bool {
        true
    }
}
