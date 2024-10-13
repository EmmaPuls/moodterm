use nix::pty::ForkptyResult;
use nix::sys::termios::{tcgetattr, tcsetattr, SetArg, Termios};
use nix::unistd::{execvp, read, write};
use std::ffi::CString;
use std::os::fd::{AsRawFd, IntoRawFd, OwnedFd};
use std::os::unix::io::{AsFd, BorrowedFd};
use std::sync::mpsc;
use std::thread;

fn set_raw_mode(fd: BorrowedFd) -> Termios {
    let termios = tcgetattr(fd).expect("Failed to get terminal attributes");
    let raw = termios.clone();
    tcsetattr(fd, SetArg::TCSANOW, &raw).expect("Failed to set terminal to raw mode");
    termios
}

fn restore_terminal(fd: BorrowedFd, termios: &Termios) {
    tcsetattr(fd, SetArg::TCSANOW, termios).expect("Failed to restore terminal settings");
}

fn spawn_shell() -> OwnedFd {
    let fork_pty_res = unsafe { nix::pty::forkpty(None, None).expect("Failed to fork PTY") };
    match fork_pty_res {
        ForkptyResult::Parent { master, .. } => unsafe {
            BorrowedFd::borrow_raw(master.into_raw_fd())
                .try_clone_to_owned()
                .expect("Failed to clone")
        },
        ForkptyResult::Child => {
            let shell = std::env::var("SHELL").unwrap_or_else(|_| "/bin/sh".to_string());
            let shell_cstr = CString::new(shell).expect("CString::new failed");
            execvp(&shell_cstr, &[&shell_cstr]).expect("Failed to execute shell");
            unreachable!()
        }
    }
}

// Starts terminal emulation in the current thread
// Creates a new thread to read from the shell and write to stdout
// Reads from stdin and writes to the shell
pub struct TerminalEmulator {
    original_termios: Option<Termios>,
    master_fd: Option<OwnedFd>,
}

impl TerminalEmulator {
    pub fn new() -> Self {
        TerminalEmulator {
            original_termios: None,
            master_fd: None,
        }
    }

    pub fn start_terminal_emulation(&mut self, user_input: &str) -> String {
        let stdin_fd = unsafe { BorrowedFd::borrow_raw(0) }; // File descriptor for stdin

        // Set terminal to raw mode
        self.original_termios = Some(set_raw_mode(stdin_fd));

        // Spawn the shell
        self.master_fd = Some(spawn_shell());

        // Create a channel to communicate between the thread and the main function
        let (tx, rx) = mpsc::channel();

        // Cloning the master_fd allows us to use it concurrently via the original and the clone.
        let master_fd_clone = self
            .master_fd
            .as_ref()
            .unwrap()
            .try_clone()
            .expect("Failed to clone master_fd");

        thread::spawn(move || {
            let mut buffer = [0u8; 1024];
            loop {
                let n = read(master_fd_clone.as_raw_fd(), &mut buffer)
                    .expect("Failed to read from PTY");
                if n == 0 {
                    break;
                }
                // Send the output to the main thread
                tx.send(String::from_utf8_lossy(&buffer[..n]).to_string())
                    .expect("Failed to send data");
            }
        });

        // Read from user input and write to the shell
        write(
            self.master_fd.as_ref().unwrap().as_fd(),
            user_input.as_bytes(),
        )
        .expect("Failed to write to PTY");
        "".to_string();
        // Collect the output from the thread
        let output = rx.recv().expect("Failed to receive data");
        output
    }

    pub fn stop_terminal_emulation(&mut self) {
        if let Some(stdin_fd) = self.master_fd.as_ref() {
            restore_terminal(stdin_fd.as_fd(), self.original_termios.as_ref().unwrap());
        }
    }
}
