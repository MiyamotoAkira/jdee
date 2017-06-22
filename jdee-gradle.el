

;;
;; Building
;;

;;;###autoload
(defun jdee-gradle-build (&optional path)
  "Build using the gradle command from PATH"
  (interactive)
  (let ((default-directory (jdee-gradle-get-default-directory path)))
    (compilation-start (format "%s %s" jdee-gradle-program jdee-gradle-build-phase))))

;;;###autoload
(defun jdee-gradle-hook ()
  "Initialize the gradle integration if available."
  (unless jdee-gradle-disabled-p
    (let ((jdee-gradle-project-dir* (jdee-gradle-get-default-directory)))
      (when (run-hook-with-args-until-success 'jdee-gradle-init-hook jdee-gradle-project-dir*)
        (setq-local jdee-gradle-project-dir jdee-gradle-project-dir*)
        (run-hooks 'jdee-gradle-mode-hook)))))


(provide 'jdee-gradle)

;;; jdee-gradle.el ends here
