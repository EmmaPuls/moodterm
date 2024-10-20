mod app;
mod command_line_gui;
mod terminal_evaluation;

use cacao::appkit::App;

use app::MoodTermApp;
use terminal_evaluation::start_terminal_emulation;

fn main() {
    // Start the terminal emulation in a separate thread
    std::thread::spawn(|| {
        start_terminal_emulation();
    });

    // Start the UI
    App::new("com.moodterm.moodterm", MoodTermApp::default()).run();
}
