# moodterm

## 0.3.3

### Patch Changes

- Command input is has more consistent styling
- TerminalTextView split into it's own custom component for better control options
- Terminal text starts at the bottom of the screen and moves up
- Terminal text fills it's whole container and so does not get cutoff when resizing text

## 0.3.2

### Patch Changes

- Make all app colors adhere to MacOS appearance
- Save and restore the apps scaling when user closes and reopens the app

## 0.3.1

### Patch Changes

- Adding tests to SwiftUI moodterm

## 0.3.0

### Minor Changes

- Added Tabs for creating multiple terminal sessions
- Log in to the terminal with the users settings (home directory & preferred shell)

## 0.3.0

### Minor Changes

#### Switched to SwiftUI & Swift

And I have a terminal GUI! It works!

##### Issues

- Text won't scroll
- Not handling ANSI colours

## 0.2.0

### Minor Changes

- #### Context

  - I've completed the ownership and structs sections of [The Rust Programming Language](https://doc.rust-lang.org/book/title-page.html)
  - I've been reviewing the [cacao examples](https://github.com/ryanmcgrath/cacao) to understand how it works better
    - I've spent a bit of time understanding why NSTextView is not yet supported
    - I've decided to continue using cacao for now for the UI
  - I've been reading about concurrency

  #### What is in this change

  - I've refactored the UI a bit to seperate the concerns and done a bit of a visual refresh
