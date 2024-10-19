use cacao::{
    appkit::window::{Window, WindowDelegate}, control::{Control, ControlSize}, geometry::Rect, input::{TextField, TextFieldDelegate}, layout::{Layout, LayoutConstraint}, view::View
};
use std::{os::fd::BorrowedFd, sync::{Arc, Mutex}};

const TOP: f64 = 20.0;
const SPACING: f64 = 20.0;
const WIDTH: f64 = 280.0;
const HEIGHT: f64 = 280.0;

#[derive(Debug, Default)]
pub struct ConsoleLogger;

#[derive(Debug)]
pub struct TextInputOutputWindow {
    non_editable_input: TextField<ConsoleLogger>,
    editable_input: TextField<ConsoleLogger>,
    content: Arc<Mutex<View>>, // Wrap View in Arc<Mutex<...>>
    pty_fd: Arc<Mutex<i32>>, // Add a field to store the pseudoterminal file descriptor
}

impl TextFieldDelegate for ConsoleLogger {
    const NAME: &'static str = "ConsoleLogger";

    fn text_should_begin_editing(&self, value: &str) -> bool {
        println!("Should begin with value: {}", value);
        true
    }

    fn text_did_change(&self, value: &str) {
        println!("Did change to: {}", value);
    }

    fn text_did_end_editing(&self, value: &str) {
        println!("Ended: {}", value);
    }
}

impl TextInputOutputWindow {
    pub fn new(pty_fd: i32) -> Self {
        TextInputOutputWindow {
            non_editable_input: {
                let input = TextField::with(ConsoleLogger);
                input.set_enabled(false);
                input.set_control_size(ControlSize::Large);
                input.set_frame(Rect {
                    top: TOP,
                    left: SPACING,
                    width: WIDTH,
                    height: HEIGHT / 2.0,
                });
                input
            },
            editable_input: {
                let input = TextField::with(ConsoleLogger);
                input.set_max_number_of_lines(5);
                input.set_wraps(true);
                input.set_uses_single_line(false);
                input.set_control_size(ControlSize::Large);
                input.set_frame(Rect {
                    top: TOP + HEIGHT / 2.0,
                    left: SPACING,
                    width: WIDTH,
                    height: HEIGHT / 2.0,
                });
                input
            },
            content: Arc::new(Mutex::new(View::new())), // Initialize View
            pty_fd: Arc::new(Mutex::new(pty_fd)), // Initialize the pseudoterminal file descriptor
        }
    }

    pub fn send_input_to_pty(&self, input: &str) {
        let fd = {
            let guard = self.pty_fd.lock().unwrap();
            *guard
        };

        let borrowed_fd = unsafe { BorrowedFd::borrow_raw(fd) };

        nix::unistd::write(borrowed_fd, input.as_bytes()).expect("Failed to write to PTY");
    }

    pub fn update_output(&self, output: &str) {
        self.non_editable_input.set_text(output);
    }
}

#[derive(Debug, Clone)]
pub struct TextInputOutputWindowWrapper(pub Arc<Mutex<TextInputOutputWindow>>);

impl WindowDelegate for TextInputOutputWindowWrapper {
    const NAME: &'static str = "WindowDelegate";

    fn did_load(&mut self, window: Window) {
        window.set_title("Input Logger Example");
        window.set_minimum_content_size(400., 400.);

        {
            let window_instance = self.0.lock().unwrap();
            let content = window_instance.content.lock().unwrap();
            content.add_subview(&window_instance.non_editable_input);
            content.add_subview(&window_instance.editable_input);
            window.set_content_view(&*content);
        }

        let binding = self.0.lock().unwrap();
        let non_editable_input = &binding.non_editable_input;
        let editable_input = &binding.editable_input;
        let content = binding.content.lock().unwrap();

        LayoutConstraint::activate(&[
            non_editable_input.top.constraint_equal_to(&content.top),
            non_editable_input.left.constraint_equal_to(&content.left),
            non_editable_input.right.constraint_equal_to(&content.right),
            non_editable_input.height.constraint_equal_to_constant(HEIGHT / 2.0),
            editable_input.top.constraint_equal_to(&non_editable_input.bottom),
            editable_input.left.constraint_equal_to(&content.left),
            editable_input.right.constraint_equal_to(&content.right),
            editable_input.bottom.constraint_equal_to(&content.bottom),
            editable_input.height.constraint_equal_to_constant(HEIGHT / 2.0),
        ]);

        // Window Settings
        window.set_title("MoodTerm");
        window.set_minimum_content_size(400.0, 400.0);
        window.set_titlebar_appears_transparent(true);
        window.make_key_and_order_front();

        // Start app
        window.show();
    }
}