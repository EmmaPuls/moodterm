mod text_input;

use cacao::appkit::menu::{Menu, MenuItem};
use cacao::appkit::window::{Window, WindowConfig};
use cacao::appkit::{App, AppDelegate};
use text_input::TextInputOutputWindowWrapper;
use std::sync::{Arc, Mutex};
pub use text_input::TextInputOutputWindow;

pub fn start_app(app_window: Arc<Mutex<TextInputOutputWindow>>) {
    App::new(
        "com.moodterm.ui",
        BasicApp {
            window: Window::with(WindowConfig::default(), TextInputOutputWindowWrapper(app_window)),
        },
    )
    .run();
}

#[derive(Debug)]
struct BasicApp {
    window: Window<TextInputOutputWindowWrapper>,
}

impl AppDelegate for BasicApp {
    fn did_finish_launching(&self) {
        // Menu settings
        App::set_menu(vec![
            Menu::new(
                "",
                vec![
                    MenuItem::Services,
                    MenuItem::Separator,
                    MenuItem::Hide,
                    MenuItem::HideOthers,
                    MenuItem::ShowAll,
                    MenuItem::Separator,
                    MenuItem::Quit,
                ],
            ),
            Menu::new("File", vec![MenuItem::CloseWindow]),
            Menu::new(
                "Edit",
                vec![
                    MenuItem::Undo,
                    MenuItem::Redo,
                    MenuItem::Separator,
                    MenuItem::Cut,
                    MenuItem::Copy,
                    MenuItem::Paste,
                    MenuItem::Separator,
                    MenuItem::SelectAll,
                ],
            ),
            Menu::new("View", vec![MenuItem::EnterFullScreen]),
            Menu::new(
                "Window",
                vec![
                    MenuItem::Minimize,
                    MenuItem::Zoom,
                    MenuItem::Separator,
                    MenuItem::new("Bring All to Front"),
                ],
            ),
            Menu::new("Help", vec![]),
        ]);

        // Start app
        App::activate();
        self.window.show();
    }

    fn should_terminate_after_last_window_closed(&self) -> bool {
        true
    }
}
