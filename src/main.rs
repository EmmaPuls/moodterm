mod terminal_evaluation;
mod ui;

use std::sync::{Arc, Mutex};
use terminal_evaluation::start_terminal_emulation;
use ui::start_app;

fn main() {
    // Create a channel for communication between the terminal and the UI
    let (tx, rx) = std::sync::mpsc::channel();

    // Spawn the terminal emulation in a separate thread
    let pty_fd = Arc::new(Mutex::new(0)); // Placeholder for the pseudoterminal file descriptor
    let update_output = Arc::new(Mutex::new(move |output: String| {
        tx.send(output).expect("Failed to send output to UI");
    }));

    std::thread::spawn({
        let pty_fd = Arc::clone(&pty_fd);
        let update_output = Arc::clone(&update_output);
        move || {
            start_terminal_emulation(pty_fd, update_output);
        }
    });

    // Start the UI
    let app_window = ui::TextInputOutputWindow::new(*pty_fd.lock().unwrap());

    // Update the UI with the output from the terminal
    let app_window_arc = Arc::new(Mutex::new(app_window));
    let app_window_clone = Arc::clone(&app_window_arc);
    std::thread::spawn(move || {
        for output in rx {
            app_window_clone.lock().unwrap().update_output(&output);
        }
    });

    start_app(app_window_arc);
}