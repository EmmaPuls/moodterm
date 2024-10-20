# README.md

## Context

I want to create a lightweight terminal application that allows me to use a mouse and keyboard to edit commands cleanly.

I'm writing this for MacOS as it's my favourite dev environment, no plans to extend support to other OS's.

Current tech stack:
- Rust
- [Cacao](https://github.com/ryanmcgrath/cacao)
  - Rust wrapper for Cocoa and AppKit
- [mol](https://github.com/DmitryDodzin/mol)
  - Changeset and version handling for Rust

## Current state
- Pseudoterminal that runs in the command line, can execute commands and recieve output from the terminal
- User Interface with a simple text field opens on start

## Updates

I'll be writing updates in [changelog](CHANGELOG.md) from now on, including my own observations and notes about what I've been reading about while building.

