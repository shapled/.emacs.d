(load-file "~/.emacs.d/env.el")
(when (eq system-type 'windows-nt)
  (set-language-environment 'Chinese-GB18030)
  (setenv "PYTHONIOENCODING" "gb18030"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   包管理   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  配置加载   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 启用 use-package
(require 'use-package)

;; 启用 pyim 拼音输入法
(use-package pyim
  :ensure nil
  :config
  ;; 激活 basedict 拼音词库
  (use-package pyim-basedict
    :ensure nil
    :config (pyim-basedict-enable))

  (setq default-input-method "pyim")

  ;; 绘制选词弹窗
  (require 'popup)
  (setq pyim-page-tooltip 'popup)
  
  ;; 开启拼音搜索功能
  (require 'pyim-cregexp-utils)
  (pyim-isearch-mode 1)

  ;; 使用 pupup-el 来绘制选词框
  (setq pyim-page-tooltip 'popup)

  ;; 选词框显示5个候选词
  (setq pyim-page-length 8)

  ;; 让 Emacs 启动时自动加载 pyim 词库
  (add-hook 'emacs-startup-hook
            #'(lambda () (pyim-restart-1 t)))

  ;; 定义一个函数用于切换 pyim 开关
  (defun toggle-pyim ()
    "切换 pyim 输入法的开启和关闭."
    (interactive)
    (if (string= current-input-method "pyim")
        (set-input-method nil) ;; 关闭输入法
      (set-input-method "pyim"))) ;; 开启输入法

  :bind
  (("C-;" . 'toggle-pyim) ;与 pyim-probe-dynamic-english 配合
   ))

;; 当前比较流行的补全插件 vertico
(use-package vertico
  :ensure nil
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;; (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :config
  (vertico-mode)

  ;; 弹窗 mini buffer
  (use-package vertico-posframe
    :config
    (vertico-posframe-mode 1)
    (setq vertico-posframe-poshandler #'posframe-poshandler-frame-top-center))

  ;; 对齐 mini buffer 中的内容
  (use-package marginalia
    :config
    (marginalia-mode))

  ;; 基于 rg 的搜索功能
  (use-package consult
    :bind
    (("<ESC> /" . 'consult-ripgrep))))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :ensure nil
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  (orderless-component-separator #'orderless-escapable-split-on-space)
  
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; 树状目录
(use-package direx
  :bind
  ("<ESC> d". direx:jump-to-directory))

;; 必备的 ai 提示
(use-package aider
  :config
  (setq aider-args '("--no-auto-commits" "--deepseek"))
  (if (or (not (boundp 'deepseek-api-key)) (null deepseek-api-key) (string= deepseek-api-key ""))
      (warn "variable deepseek-api-key is not set or is empty.")
    (setenv "DEEPSEEK_API_KEY" deepseek-api-key))

  (add-hook 'find-file-hook
	    (lambda ()
	      (when (and (buffer-file-name)
			 (string-match-p "aider" (buffer-file-name)))
		(aider-minor-mode 1))))
	    
  :bind
  (("<ESC> a" . 'aider-transient-menu)))

;; TODO: 关闭时保留工作区
(use-package perspective
  :init
  (setq persp-suppress-no-prefix-key-warning t)
  (setq persp-state-default-file "~/.emacs.d/auto-save-list/default.persp")
  
  :config
  (persp-mode)
  (when (file-exists-p persp-state-default-file)
    (persp-state-load persp-state-default-file))
  (add-hook 'kill-emacs-hook 'persp-state-save))

;; 系统配置
(use-package emacs
  :config
  ;; 关闭备份文件
  (setq make-backup-files nil)

  ;; cua 模式，支持 C-c C-v C-x C-y
  (cua-mode t)
  (setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
  (transient-mark-mode 1)               ;; No region when it is not highlighted
  (setq cua-keep-region-after-copy t)

  ;; 设置字体
  (set-face-attribute 'default nil :font (font-spec :family "Consolas" :size 18))
  (set-fontset-font t 'han (font-spec :family "Microsoft Yahei"))
  (setq face-font-rescale-alist '(("Microsoft Yahei" . 1.6) ("WenQuanYi Zen Hei" . 1.6)))

  ;; 关闭菜单栏、图标栏
  (menu-bar-mode -1)
  (tool-bar-mode -1)

  ;; 禁止自动打开欢迎页
  (setq inhibit-startup-screen t)

  :bind
  ("M-o" . 'find-file))

;; 加载完成
(message "emacs configure loaded")
