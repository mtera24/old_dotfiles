
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;#Commentary:

;;;; Emacsの公式ドキュメント一覧
;; - [[info:emacs#Top][Emacs]]
;; - [[info:eintr#Top][An Introduction to Programming in Emacs Lisp]]
;; - [[info:elisp#Top][Emacs Lisp]]
;; - Reference Cards (/etc/refcards)
;;   - refcard.pdf :: Emacs
;;   - calccard.pdf :: Calc
;;   - dired-ref.pdf :: Dired
;;   - gnus-booklet.pdf :: Gnus
;;   - gnus-refcard.pdf :: Gnus
;;   - orgcard.pdf :: Org


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;#Code:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;#packeges
;;;; 初期化
;;   Emacsは init.el 読み込み後に各パッケージへのload-path設定を行い
;;   XXX-autoloads.el を読み込む。このままでは init の段階では
;;   require/locate-library ができないため、(package-initialize) を事前
;;   に実行する。

(package-initialize)
;;(setq package-enable-at-startup nil) ; 初期化済みなので自動初期化は停止。

;; パッケージの情報は、~/.emacs.d/elpa/archives/ に格納される。自分で
;; パッケージを作る場合は、 package-x.el の、
;; `package-upload-{buffer,file}' を利用する。archive-contents ファイ
;; ルが自動生成される。

;;;; Package Archives
(set-variable 'package-archives
              '(("gnu" . "http://elpa.gnu.org/packages/")
                ("melpa" . "http://melpa.milkbox.net/packages/")
                ;; org-mode
                ("org"   . "http://orgmode.org/elpa/")
                ))


;;;#direct settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;#appearance
;; フォントをRictyに,ookisa wa height de kaerare ru.
(set-face-attribute 'default nil
                    :family "Ricty Diminished"
                    :height 150)

;; 行間を指定
(setq-default line-spacing 0.2)

;; 表示を単純化（スタートアップメッセージなし．スクラッチは空．ツールバー無し，
;; スクロールバーなし）．，ベル無し．
(setq ring-bell-function 'ignore)
(setq inhibit-startup-message t)
(setq initial-scratch-message "") 
(tool-bar-mode -1)
(set-scroll-bar-mode nil)
(setq frame-title-format (format "%%f - Emacs@%s" (system-name)))


;;;# for org-mode
  ;; TODO状態
  (setq org-todo-keywords
        '((sequence "APPT(a@/!)" "TODO(t)" "STARTED(s!)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCEL(c@/!)" "SOMEDAY(s@/!)"))
        )
  ;; DONEの時刻を記録
  (setq org-log-done 'time)
  ;; アジェンダ表示の対象ファイル
  (setq org-agenda-files '(
                           "~/org/gtd.org"
                ;;           "~/org/active"
                           )
        )
  ;; refile target
  (setq org-refile-targets '((org-agenda-files :maxlevel . 3)))
  ;; アジェンダ表示で下線を用いる
  (add-hook 'org-agenda-mode-hook '(lambda () (hl-line-mode 1)))
  (setq hl-line-face 'underline)
  ;; 標準の祝日を利用しない
  (setq calendar-holidays nil)
  ;; org-capture 構成
 (setq org-capture-templates
       '(("t" "Todo" entry (file+headline "~/org/gtd.org" "Inbox")
          "* TODO %? (wrote on %U)")
         ("k" "Knowledge" entry (file+headline "~/org/knowledge.org" "Inbox")
          "* %?  # Wrote on %U")
         )
 )


;;;#settings by packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;#all-the-icons
(use-package all-the-icons
  :ensure t
  )

;;;#emoji (for the following themes)
(use-package emojify :ensure t
  :if (display-graphic-p)
  :hook (after-init . global-emojify-mode)
  :bind
  ("C-x e" . 'emojify-insert-emoji)
  )

;;;#theme
;;;# doom theme
(use-package doom-themes
    :ensure t
    :custom
     (doom-themes-enable-italic t)
     (doom-themes-enable-bold t)
     :custom-face
     (doom-modeline-bar ((t (:background "#6272a4"))))
      :config
      (load-theme 'doom-dracula t)
    (doom-themes-neotree-config)
    (doom-themes-org-config)
    )

;;;#task-measuring
(defun ladicle/task-clocked-time ()
        "Return a string with the clocked time and effort, if any"
        (interactive)
        (let* ((clocked-time (org-clock-get-clocked-time))
               (h (truncate clocked-time 60))
               (m (mod clocked-time 60))
               (work-done-str (format "%d:%02d" h m)))
          (if org-clock-effort
              (let* ((effort-in-minutes
                  (org-duration-to-minutes org-clock-effort))
                 (effort-h (truncate effort-in-minutes 60))
                 (effort-m (truncate (mod effort-in-minutes 60)))
                 (effort-str (format "%d:%02d" effort-h effort-m)))
            (format "%s/%s" work-done-str effort-str))
            (format "%s" work-done-str))))
;;;#pomodoro
(use-package org-pomodoro
    :after org-agenda
    :custom
    (org-pomodoro-ask-upon-killing t)
    (org-pomodoro-format "%s")
    (org-pomodoro-short-break-format "%s")
    (org-pomodoro-long-brea-format  "%s")
    :custom-face
    (org-pomodoro-mode-line ((t (:foreground "#ff5555"))))
    (org-pomodoro-mode-line-break   ((t (:foreground "#50fa7b"))))
    :hook
    ;; (org-pomodoro-started . (lambda () (notifications-notify
    ;;                                            :title "org-pomodoro"
    ;;                        :body "Let's focus for 25 minutes!"
    ;; 			   ;;                           :app-icon "~/.emacs.d/img/001-food-and-restaurant.png"
    ;; 			   )))
    ;; (org-pomodoro-finished . (lambda () (notifications-notify
    ;;                                            :title "org-pomodoro"
    ;;                        :body "Well done! Take a break."
    ;; 			   ;;                           :app-icon "~/.emacs.d/img/004-beer.png"
    ;; 			   )))
    :config
    :bind (:map org-agenda-mode-map
                ("p" . org-pomodoro)))

