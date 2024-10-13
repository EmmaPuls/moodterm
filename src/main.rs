mod terminal_evaluation;
mod ui;

fn main() {
    

    // Start the terminal emulation in a separate thread
    std::thread::spawn(move || {
        terminal_evaluation::start_terminal_emulation();
    });

    // Start the UI
    ui::start_app();
}
