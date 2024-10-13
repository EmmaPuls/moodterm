use cacao::{
    appkit::window::{Window, WindowDelegate},
    control::{Control, ControlSize},
    geometry::Rect,
    input::{TextField, TextFieldDelegate},
    layout::{Layout, LayoutConstraint},
    view::View,
};

use crate::terminal_evaluation::{self, TerminalEmulator};

const TOP: f64 = 20.0;
const SPACING: f64 = 20.0;
const WIDTH: f64 = 280.0;
const HEIGHT: f64 = 280.0;

#[derive(Debug, Default)]
pub struct ConsoleLogger;

#[derive(Debug)]
pub struct AppWindow {
    non_editable_input: TextField<ConsoleLogger>,
    editable_input: TextField<ConsoleLogger>,
    content: View,
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

impl AppWindow {
    pub fn new(terminal_emulator: &mut TerminalEmulator) -> Self {
        let mut user_input = String::new();
        // Start the terminal emulation in a separate thread
        // Pass in the user input and receive the output
        let output: String = terminal_emulator.start_terminal_emulation(&user_input);

        let mut callback_to_set_user_input = |input: String| {
            user_input = input;
        };
        AppWindow {
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

                let mut new_value: String = String::new();
                new_value.push_str(&input.get_value());
                new_value.push_str(&output);
                input.set_text(&new_value);
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
                callback_to_set_user_input(input.get_value());
                input
            },
            content: View::new(),
        }
    }
}

impl WindowDelegate for AppWindow {
    const NAME: &'static str = "WindowDelegate";

    fn did_load(&mut self, window: Window) {
        window.set_title("Input Logger Example");
        window.set_minimum_content_size(400., 400.);

        self.content.add_subview(&self.non_editable_input);
        self.content.add_subview(&self.editable_input);
        window.set_content_view(&self.content);

        LayoutConstraint::activate(&[
            self.non_editable_input
                .top
                .constraint_equal_to(&self.content.top),
            self.non_editable_input
                .left
                .constraint_equal_to(&self.content.left),
            self.non_editable_input
                .right
                .constraint_equal_to(&self.content.right),
            self.non_editable_input
                .height
                .constraint_equal_to_constant(HEIGHT / 2.0),
            self.editable_input
                .top
                .constraint_equal_to(&self.non_editable_input.bottom),
            self.editable_input
                .left
                .constraint_equal_to(&self.content.left),
            self.editable_input
                .right
                .constraint_equal_to(&self.content.right),
            self.editable_input
                .bottom
                .constraint_equal_to(&self.content.bottom),
            self.editable_input
                .height
                .constraint_equal_to_constant(HEIGHT / 2.0),
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
