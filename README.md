# README.md

## Context

I want to create a lightweight terminal application that allows me to use a mouse and keyboard to edit commands cleanly.

I'm writing this for MacOS in Swift as it's my favourite dev environment, no plans to extend support to other OS's.

## Updates

### 2024-09-28
#### Changes
- Have communication between terminal and application
- Have a simple UI to send simple
- Keeps the state of past commands

#### Thoughts/ problems
- Permission problems, currently using the applications permissions to access CLI instead of the users permissions
- Not waiting for user follow up input for commands that require user response
- Not properly streaming the output from the command line

https://github.com/user-attachments/assets/9b5f0259-fe9f-47a0-b9d5-a8f57c588d94

