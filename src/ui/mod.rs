mod text_input;

use cacao::appkit::menu::{Menu, MenuItem};
use cacao::appkit::window::{Window, WindowConfig};
use cacao::appkit::{App, AppDelegate};

use crate::terminal_evaluation::TerminalEmulator;

pub fn start_app(terminal_emulator: &mut TerminalEmulator) {
    App::new(
        "com.moodterm.ui",
        BasicApp {
            window: Window::with(
                WindowConfig::default(),
                text_input::AppWindow::new(terminal_emulator),
            ),
        },
    )
    .run();
}

#[derive(Debug)]
struct BasicApp {
    window: Window<text_input::AppWindow>,
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
