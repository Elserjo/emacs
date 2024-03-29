(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(adwaita))
 '(package-selected-packages
   '(whitespace-cleanup-mode dashboard evil-commentary no-littering elfeed evil-collection magit use-package evil nix-mode))
 '(warning-suppress-log-types '((comp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(add-to-list 'default-frame-alist
             '(font . "Source Code Pro-14"))

(setq-default indent-tabs-mode nil)
(setq tab-stop-list (number-sequence 4 120 4))
;; Now dired will ask before creating missing directory
(setq dired-create-destination-dirs "ask")

;; Terminal Modes https://systemcrafters.cc/emacs-from-scratch/learn-to-love-the-terminal-modes/
;; get current linux distro. printf removes new line symbol from command output
(setq distro (shell-command-to-string
              "printf %s $(grep -woP 'ID=\\K\\w+' /etc/os-release)"))
(when (string= distro "nixos")
;; if nixos, then set default shell type for NixOS
  (setq sh-shell-file "/usr/bin/env bash"))

;; this another emacs package repository
(require 'package)
(add-to-list 'package-archives '
             ("melpa" . "https://melpa.org/packages/"))

;; if use-package is not installed, then install. this will be usefull
;; for install on another machine with same config
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; this package prevents writting emacs packages data to home directory
;;(use-package no-littering)
(setq user-emacs-directory (expand-file-name "~/.cache/emacs/"))

(use-package no-littering)

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  (setq evil-respect-visual-line-mode t)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

;; Enable evil-commentary
;; https://github.com/linktohack/evil-commentary
(use-package evil-commentary
  :after evil
  :config
  (evil-commentary-mode))

(evil-set-initial-state 'shell-mode 'emacs)

(use-package nix-mode
  :bind ("C-x a" . nix-format-buffer)
  :mode ("\\.nix\\'" "\\.nix.in\\'"))

(use-package nix-drv-mode
  :ensure nix-mode
  :mode "\\.drv\\'")
(use-package nix-shell
  :ensure nix-mode
  :commands (nix-shell-unpack nix-shell-configure nix-shell-build))
(use-package nix-repl
  :ensure nix-mode
  :commands (nix-repl))

(use-package magit
  :ensure t)

(use-package elfeed
  :config
  (setq elfeed-feeds
        '(("https://news.ycombinator.com/rss" hacker_news)
          ("https://www.reddit.com/r/linux_gaming.rss" reddit_linux_gaming)
          ("https://www.reddit.com/r/linux.rss" reddit_linux)
          ("https://www.reddit.com/r/emacs.rss" reddit_emacs)
          ("https://www.reddit.com/r/oneplus.rss" reddit_oneplus)
          ("https://boilingsteam.com/?feed=rss2" pc_linux_gaming)
          ("https://www.phoronix.com/rss.php" phoronix)
          ("https://grapheneos.org/releases.atom" grapheneos_feed)
          ("https://github.com/arkenfox/user.js/releases.atom" github_arkenfox)
          ("https://www.allmusic.com/rss" allmusic_rss)
          ("https://b-movies.ru/?feed=rss2" b-movies)))
  (add-hook 'window-configuration-change-hook 'update-rss))

;; Alternative startup menu
(use-package dashboard
  :ensure t
  :init
  (setq dashboard-center-content t
        dashboard-items
        '((recents . 5)
          (bookmarks . 5)))
  :config
  (dashboard-setup-startup-hook))

(use-package whitespace-cleanup-mode)

;; Dummy rss updater
(defun update-rss ()
"Auto update rss in elfeed buffer"
(defconst check-interval 120);; check interval in minutes
(defconst elfeed-buff "*elfeed-search*");;
(let* ((epoch-seconds (current-time))
      (db-last-update-time (seconds-to-time (elfeed-db-last-update)))
      (current-buff (buffer-name));; buffer name
      (time-diff (string-to-number
                  (format-time-string "%s"
                                      (time-subtract epoch-seconds db-last-update-time)))))
      ;;(time-diff-minutes (/ (string-to-number(format-time-string "%s" time-diff))60))) ;;convert time diff to minutes
  ;;(message "Will updated: %d" (/ time-diff 60))
  (if (and (string= elfeed-buff current-buff)
           (> (/ time-diff 60) check-interval))
      (progn
        (elfeed-update)
        (message "Updated: %d" time-diff)))))

;; I can get name of hook by using "describe-variable"
(add-hook 'sh-mode-hook 'shell-settings-mode)
;; Use smart whitespace cleanup mode. This mode works only when
;; current buffer was initialy without whitespaces
(add-hook 'sh-mode-hook 'whitespace-cleanup-mode)

;; Delete whitespaces when save any file
;;(add-hook 'before-save-hook 'on-save)

(defun shell-settings-mode ()
  ;; Clean whitespace on shell-mode startup
  ;; (whitespace-cleanup)
  (setq display-line-numbers t))
