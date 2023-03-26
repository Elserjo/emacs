(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(adwaita))
 '(package-selected-packages
   '(smartparens no-littering elfeed evil-collection magit use-package chess evil nix-mode))
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
(setq user-emacs-directory (expand-file-name "~/.cache/emacs/"))
      
;; this package prevents writting emacs packages data to home directory
(use-package no-littering)

(use-package evil
  :init
  (setq evil-want-keybinding nil)
  (evil-mode))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

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

(use-package magit)
;;(use-package smartparens
;;  :hook (prog-mode . smartparens-mode))

(use-package elfeed
  :config
  (setq elfeed-feeds
        '(("https://news.ycombinator.com/rss" hacker_news)
          ("https://www.reddit.com/r/linux_gaming.rss" reddit_linux_gaming)
          ("https://www.reddit.com/r/linux.rss" reddit_linux)
          ("https://www.reddit.com/r/emacs.rss" reddit_emacs)
          ("https://boilingsteam.com/?feed=rss2" pc_linux_gaming)
          ("https://www.phoronix.com/rss.php" phoronix)
          ("https://grapheneos.org/releases.atom" grapheneos_feed)
          ("https://b-movies.ru/?feed=rss2" b-movies)))
  (add-hook 'window-configuration-change-hook 'update-rss))
  
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
