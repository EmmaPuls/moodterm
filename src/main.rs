use cacao::appkit::window::Window;
use cacao::appkit::{App, AppDelegate};
use nix::pty::ForkptyResult;
use nix::sys::termios::{tcgetattr, tcsetattr, SetArg, Termios};
use nix::unistd::{execvp, read, write};
use std::ffi::CString;
use std::io::{self, Read, Write};
use std::os::fd::{AsRawFd, IntoRawFd};
use std::os::unix::io::{AsFd, BorrowedFd};

fn set_raw_mode(fd: BorrowedFd) -> Termios {
    let termios = tcgetattr(fd).expect("Failed to get terminal attributes");
    let raw = termios.clone();
    tcsetattr(fd, SetArg::TCSANOW, &raw).expect("Failed to set terminal to raw mode");
    termios
}

fn restore_terminal(fd: BorrowedFd, termios: &Termios) {
    tcsetattr(fd, SetArg::TCSANOW, termios).expect("Failed to restore terminal settings");
}

fn spawn_shell() -> BorrowedFd<'static> {
    let fork_pty_res = unsafe { nix::pty::forkpty(None, None).expect("Failed to fork PTY") };
    match fork_pty_res {
        ForkptyResult::Parent { master, .. } => unsafe {
            BorrowedFd::borrow_raw(master.into_raw_fd())
        },
        ForkptyResult::Child => {
            let shell = std::env::var("SHELL").unwrap_or_else(|_| "/bin/sh".to_string());
            let shell_cstr = CString::new(shell).expect("CString::new failed");
            execvp(&shell_cstr, &[&shell_cstr]).expect("Failed to execute shell");
            unreachable!()
        }
    }
}

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

fn start_terminal_emulation() {
    let stdin_fd = unsafe { BorrowedFd::borrow_raw(0) }; // File descriptor for stdin

    // Set terminal to raw mode
    let original_termios = set_raw_mode(stdin_fd);

    // Spawn the shell
    let master_fd = spawn_shell();

    // Create a thread to read from the shell and write to stdout
    // Cloning the master_fd allows us to use it concurrently via the original and the clone.
    let master_fd_clone = master_fd.clone();
    std::thread::spawn(move || {
        let mut buffer = [0u8; 1024];
        loop {
            let n =
                read(master_fd_clone.as_raw_fd(), &mut buffer).expect("Failed to read from PTY");
            if n == 0 {
                break;
            }
            io::stdout()
                .write_all(&buffer[..n])
                .expect("Failed to write to stdout");
            io::stdout().flush().expect("Failed to flush stdout");
        }
    });

    // Read from stdin and write to the shell
    let mut buffer = [0u8; 1024];
    loop {
        let n = io::stdin()
            .read(&mut buffer)
            .expect("Failed to read from stdin");
        if n == 0 {
            break;
        }
        write(master_fd.as_fd(), &buffer[..n]).expect("Failed to write to PTY");
    }

    // Restore terminal settings
    restore_terminal(stdin_fd, &original_termios);
}

fn main() {
    // Start the terminal emulation in a separate thread
    std::thread::spawn(move || {
        start_terminal_emulation();
    });

    // Start the UI
    App::new("com.moodterm.ui", BasicApp::default()).run();
}
