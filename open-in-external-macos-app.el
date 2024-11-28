;;; open-in-external-macos-app.el --- Open files and projects in external applications -*- lexical-binding: t -*-

;; Copyright (C) 2024 nohzafk

;; Author: nohzafk
;; Keywords: convenience, files
;; Version: 0.1.0
;; Package-Requires: ((emacs "25.1"))
;; Homepage: https://github.com/nohzafk/open-in-external-macos-app

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides commands to open files and projects in external
;; applications on macOS.  It offers two main functions:
;;
;; 1. `open-file-in-external-app': Opens the current file in an external
;; application.  Shows a dialog for choosing the application.
;;
;; 2. `open-project-in-external-app': Opens the current project directory
;; in an external application.  Uses projectile if available, falls back
;; to git root, and finally uses the current directory.
;;
;; You can customize `open-in-external-macos-app-list' to provide a quick list
;; of preferred applications:
;;
;;   (setq open-in-external-macos-app-list
;;         '("Visual Studio Code" "Sublime Text" "TextMate"))
;;
;; If this list is nil, it will show the standard macOS application
;; chooser dialog.

;;; Code:

(declare-function projectile-project-p "projectile")
(declare-function projectile-project-root "projectile")

(defcustom open-in-external-macos-app-list nil
  "List of preferred applications to show in the chooser dialog.
If nil, will show the system application chooser."
  :type '(repeat string)
  :group 'open-in-external-macos-app)

(defun get-git-root ()
  "Get the git root directory of the current buffer's file.
Returns nil if not in a git repository."
  (when-let* ((file-name (or (buffer-file-name) default-directory))
              (git-root (locate-dominating-file file-name ".git")))
    (expand-file-name git-root)))

(defun get-project-root ()
  "Get the project root directory.
First tries projectile, then git root, finally falls back to current directory."
  (or (when (and (featurep 'projectile) (projectile-project-p))
        (projectile-project-root))
      (get-git-root)
      default-directory))

(defun open-file-in-external-macos-app ()
  "Open current file in external application using a macOS native dialog."
  (interactive)
  (when-let ((current-file (buffer-file-name)))
    (start-process "choose-app" nil "osascript" "-e"
                  (if open-in-external-macos-app-list
                      (format "
                        set theFile to \"%s\"
                        set appList to {%s}
                        set chosenApp to choose from list appList with prompt \"Choose application to open the file:\" default items {item 1 of appList}
                        if chosenApp is not false then
                          set theApp to item 1 of chosenApp
                          do shell script \"open -a \" & quoted form of theApp & \" \" & quoted form of theFile
                        end if"
                              current-file
                              (mapconcat (lambda (app) (format "\"%s\"" app))
                                        open-in-external-macos-app-list
                                        ", "))
                    (format "
                        set theFile to \"%s\"
                        set theApp to name of (choose application with prompt \"Choose application to open the file:\")
                        do shell script \"open -a \" & quoted form of theApp & \" \" & quoted form of theFile"
                            current-file)))))

(defun open-project-in-external-macos-app ()
  "Open current project in external application using a macOS native dialog."
  (interactive)
  (when-let ((project-dir (get-project-root)))
    (start-process "choose-app" nil "osascript" "-e"
                  (if open-in-external-macos-app-list
                      (format "
                        set theDir to \"%s\"
                        set appList to {%s}
                        set chosenApp to choose from list appList with prompt \"Choose application to open the project:\" default items {item 1 of appList}
                        if chosenApp is not false then
                          set theApp to item 1 of chosenApp
                          do shell script \"open -a \" & quoted form of theApp & \" \" & quoted form of theDir
                        end if"
                              project-dir
                              (mapconcat (lambda (app) (format "\"%s\"" app))
                                        open-in-external-macos-app-list
                                        ", "))
                    (format "
                        set theDir to \"%s\"
                        set theApp to name of (choose application with prompt \"Choose application to open the project:\")
                        do shell script \"open -a \" & quoted form of theApp & \" \" & quoted form of theDir"
                            project-dir)))))

(provide 'open-in-external-macos-app)
;;; open-in-external-macos-app.el ends here
