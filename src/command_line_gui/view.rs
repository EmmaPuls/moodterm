use cacao::{
    color::Color,
    input::TextField,
    layout::{Layout, LayoutConstraint},
    text::Font,
    view::{View, ViewDelegate},
};

#[derive(Debug, Default)]
pub struct CommandLineGuiView {
    container: View,
    pub text_input: TextField,
}

impl CommandLineGuiView {
    pub fn new() -> Self {
        let text_input = TextField::new();
        text_input.set_wraps(false);
        text_input.set_max_number_of_lines(5);
        text_input.set_text("Hello, World!");
        text_input.set_font(Font::bold_system(24.));
        text_input.set_uses_single_line(false);
        text_input.set_background_color(Color::rgb(100, 0, 0));

        let container = View::new();
        container.set_background_color(Color::rgb(0, 0, 100));
        container.add_subview(&text_input);

        Self {
            text_input,
            container,
        }
    }
}

impl ViewDelegate for CommandLineGuiView {
    const NAME: &'static str = "TextWindowView";

    fn did_load(&mut self, view: View) {
        view.add_subview(&self.container);

        LayoutConstraint::activate(&[
            self.container.top.constraint_equal_to(&view.top),
            self.container.leading.constraint_equal_to(&view.leading),
            self.container.trailing.constraint_equal_to(&view.trailing),
            self.container.bottom.constraint_equal_to(&view.bottom),
            self.container
                .height
                .constraint_less_than_or_equal_to_constant(800.),
            self.text_input
                .top
                .constraint_equal_to(&self.container.top)
                .offset(48.),
            self.text_input
                .leading
                .constraint_equal_to(&self.container.leading)
                .offset(48.),
            self.text_input
                .trailing
                .constraint_equal_to(&self.container.trailing)
                .offset(-48.),
            self.text_input
                .height
                .constraint_less_than_or_equal_to(&self.container.height),
            self.text_input
                .height
                .constraint_less_than_or_equal_to_constant(800. - (48. * 2.)),
            self.text_input
                .bottom
                .constraint_less_than_or_equal_to(&self.container.bottom)
                .offset(-48.),
        ]);

        view.set_needs_display(true);
    }
}
