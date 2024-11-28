# open-in-external-macos-app

An Emacs package that provides convenient commands to open files and projects in external applications on macOS.

## Features

- Open current file in an external application with a native macOS application chooser dialog
- Open current project directory in an external application
- Configurable list of preferred applications for quick selection
- Smart project root detection using:
  1. Projectile (if available)
  2. Git root directory
  3. Current directory (fallback)

## Installation

### Manual Installation

1. Download `open-in-external-macos-app.el` to your local machine
2. Add the following to your Emacs configuration:

```elisp
(add-to-list 'load-path "/path/to/open-in-external-macos-app")
(require 'open-in-external-macos-app)
```

### Using straight.el

```elisp
(straight-use-package
 '(open-in-external-macos-app :type git :host github :repo "nohzafk/open-in-external-macos-app"))
```

## Configuration

You can customize a list of preferred applications to show in the chooser dialog:

```elisp
(setq open-in-external-macos-app-list
      '("Visual Studio Code" "Sublime Text" "TextMate"))
```

If `open-in-external-macos-app-list` is set to `nil`, the standard macOS application chooser dialog will be shown.

## Usage

The package provides two main interactive commands:

1. `M-x open-file-in-external-app`
   - Opens the current file in an external application
   - Shows a dialog for choosing the application

2. `M-x open-project-in-external-app`
   - Opens the current project directory in an external application
   - Uses projectile if available, falls back to git root, and finally uses the current directory

You might want to bind these commands to convenient key combinations:

```elisp
(global-set-key (kbd "C-c o f") 'open-file-in-external-app)
(global-set-key (kbd "C-c o p") 'open-project-in-external-app)
```

## Requirements

- macOS
- Emacs 25.1 or later
