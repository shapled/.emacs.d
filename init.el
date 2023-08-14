;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 系统配置 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 关闭备份文件
(setq make-backup-files nil)

;; 窗口切割操作：
;; C-x 2 纵向切割
;; C-x 3 横向切割
;; C-x 0 关闭

;; 使用 Shift + 方向键 控制当前窗口
(windmove-default-keybindings)
(setq windmove-wrap-around t)

;; 保存窗口布局
(desktop-save-mode 1)
(setq desktop-dir
      (expand-file-name ".cache/desktop" user-emacs-directory))
(desktop-read desktop-dir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   插件   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 设置加载路径
(setq pkg-path
  (substring 
    (shell-command-to-string (format "cask package-directory --path %s" user-emacs-directory)) 
   0 -1))
(let* ((local-pkgs (mapcar 'file-name-directory (directory-files-recursively pkg-path "\\.el$"))))
    (if (file-accessible-directory-p pkg-path)
        (mapc (apply-partially 'add-to-list 'load-path) local-pkgs)
      (make-directory pkg-path :parents)))

;; 重定向到本地路径，禁止联网下载插件
(setq package-archives '(("gnu"    . pkg-path)
                         ("nongnu" . pkg-path)
                         ("melpa"  . pkg-path)))

;; 启用 use-package
(require 'use-package)

;; 启用 evil
(use-package evil
  :after (aweshell)
  :config
  (evil-mode 1)
  (define-key evil-normal-state-map (kbd "SPC b") 'ibuffer)
  (define-key evil-normal-state-map (kbd "SPC s") 'eshell))

;; 启用 treemacs
(use-package treemacs
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   'simple
          treemacs-file-event-delay                2000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-find-workspace-method           'find-for-file-or-pick-first
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-header-scroll-indicators        '(nil . "^^^^^^")
          treemacs-hide-dot-git-directory          t
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-project-follow-into-home        nil
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-wide-toggle-width               70
          treemacs-width                           35
          treemacs-width-increment                 1
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
;;    (when treemacs-python-executable
;;      (treemacs-git-commit-diff-mode t))

   ;; (pcase (cons (not (null (executable-find "git")))
   ;;              (not (null treemacs-python-executable)))
   ;;   (`(t . t)
   ;;    (treemacs-git-mode 'deferred))
   ;;   (`(t . _)
   ;;    (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t d"   . treemacs-select-directory)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after (treemacs evil))

;; doom-themes 主题
(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
  ;;; (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  ;;; (doom-themes-neotree-config)
  ;; or for treemacs users
  ;; (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  ;;; (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  ;;;(doom-themes-org-config)
  )

;; 启用 aweshell 管理多个 shell
(use-package aweshell)

