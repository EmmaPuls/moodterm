mod terminal_evaluation;
mod ui;

fn main() {
    // Initialize the terminal
    let mut terminal_emulator = terminal_evaluation::TerminalEmulator::new();

    // Start the UI
    ui::start_app(&mut terminal_emulator);

    // Stop the terminal
    terminal_emulator.stop_terminal_emulation();
}
