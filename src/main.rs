mod terminal_evaluation;

use cacao::appkit::window::Window;
use cacao::appkit::{App, AppDelegate};

#[derive(Default)]
struct BasicApp {
    window: Window,
}

impl AppDelegate for BasicApp {
    fn did_finish_launching(&self) {
        self.window.set_title("Hello, world!");
        self.window.set_minimum_content_size(400.0, 400.0);
        self.window.set_titlebar_appears_transparent(true);
        self.window.show();
    }
}

fn main() {
    // Start the terminal emulation in a separate thread
    std::thread::spawn(move || {
        terminal_evaluation::start_terminal_emulation();
    });

    // Start the UI
    App::new("com.moodterm.ui", BasicApp::default()).run();
}
