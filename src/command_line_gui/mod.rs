use cacao::{
    appkit::window::{Window, WindowDelegate},
    view::ViewController,
};
mod view;
use view::CommandLineGuiView;

pub struct CommandLineGuiWindow {
    pub content: ViewController<CommandLineGuiView>,
}

impl CommandLineGuiWindow {
    pub fn new() -> Self {
        let content = ViewController::new(CommandLineGuiView::new());

        CommandLineGuiWindow { content }
    }
}

impl WindowDelegate for CommandLineGuiWindow {
    const NAME: &'static str = "CommandLineGuiWindow";

    fn did_load(&mut self, window: Window) {
        window.set_minimum_content_size(500, 150);
        window.set_title("Cross thread comms with UI");
        window.set_autosave_name("CrossThreadCommsWithUI");
        window.set_content_view_controller(&self.content);
    }
}
