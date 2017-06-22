;;; package --- Summary
;;; Commentary:
;;
;; Unit tests of jdee-graddle.el
;;
;;; Code:

(require 'ert)
(require 'el-mock)
(require 'jdee-graddle)
(require 'cl)


;;
;; Testing: jdee-graddle-get-default-directory
;;
(ert-deftest test-get-default-directory-no-graddle-returns-nil ()
  "Check that if a *.graddle is not found, it returns nil."
  (let ((default-directory "/aaaaaaaa/b/c/d/e/f"))
    (with-mock
     (stub directory-files => '("." ".."))
     (should (null (jdee-graddle-get-default-directory))))))

(ert-deftest test-get-default-directory-with-graddle-returns-dir ()
  "Check that the case where the graddle file is found returns the correct directory.
Requires directory-files and file-readable-p to be stubbed so it
doesn't try to hit the file system."
  (let* ((without-gradle '("." ".."))
         (with-gradle '("." ".." "test.gradle"))
         (dirs (list (list "/a" without-gradle)
                     (list "/a/b" without-gradle)
                     (list "/a/b/c" with-gradle)
                     (list "/a/b/c/src" without-gradle)
                     (list "/a/b/c/src/main" without-gradle)
                     (list "/a/b/c/src/main/java" without-gradle))))


    (let ((default-directory (caar (last dirs))))
      
      (cl-letf (((symbol-function 'directory-files) (lambda (d) (cadr (assoc d dirs)))))
        (with-mock
         (stub file-readable-p => t)
         
         (should (string= (format "%s/" (car (nth 2 dirs)))
                          (jdee-gradle-get-default-directory))))))))
;;
;; Testing: jdee-gradle-scope-file
;;

(ert-deftest test-gradle-jdee-scope-file-with-expected-paths ()
  "Check that `jdee-gradle-scope-file' can find the right scope for the path"
  (let ((source-path "/a/b/c/src/main/java/d/e/f/G.java")
        (test-path "/a/b/c/src/test/java/d/e/f/G.java"))
    (should (eq 'compile (car (jdee-gradle-scope-file source-path))))
    (should (eq 'compile (car (let ((default-directory source-path)) (jdee-gradle-scope-file)))))
    (should (eq 'test (car (jdee-gradle-scope-file test-path))))
    (should (eq 'test (car (let ((default-directory test-path)) (jdee-gradle-scope-file)))))))

(ert-deftest test-gradle-jdee-scope-file-with-non-gradle-paths ()
  "Check that `jdee-gradle-scope-file' returns nil for non-gradle paths"
  (let ((source-path "/a/b/c/d/e/f/G.java")
        (test-path "/a/b/c/d/e/f/G.java"))
    (should (null (jdee-gradle-scope-file source-path)))
    (should (null (let ((default-directory source-path)) (jdee-gradle-scope-file))))
    (should (null (jdee-gradle-scope-file test-path)))
    (should (null (let ((default-directory test-path)) (jdee-gradle-scope-file))))))

;;
;; Testing: jdee-gradle-check-classpath-file
;;
;;   No tests - nothing worth testing

;;
;; Testing: jdee-gradle-check-classpath-file*
;;

(ert-deftest test-jdee-gradle-check-classpath-file*-when-file-already-exists ()
  "Check that `jdee-gradle-check-classpath-file*' doesn't call gradle if the file already exists"
  (with-mock
   (mock (file-readable-p *) => t)
   (should (jdee-gradle-check-classpath-file* nil "some/random/path.cp" "/a/b/c" nil))))

(ert-deftest test-jdee-gradle-check-classpath-file*-when-file-is-missing-gradle-success ()
  "Check that `jdee-gradle-check-classpath-file*'  calls gradle if the file is missing"
  (cl-letf (((symbol-function 'call-process) (lambda (&rest _) (insert "BUILD SUCCESS"))))
    (with-mock
     (mock (file-readable-p *) => nil)
     (should (jdee-gradle-check-classpath-file* nil "some/random/path.cp" "/a/b/c" nil)))))

(ert-deftest test-jdee-gradle-check-classpath-file*-when-file-is-missing-gradle-fails ()
  "Check that `jdee-gradle-check-classpath-file*' calls gradle and returns nul when it fails"
  (cl-letf (((symbol-function 'call-process) (lambda (&rest _) (insert "BUILD FAILURE"))))
    (with-mock
     (mock (file-readable-p *) => nil)
     (should (null (jdee-gradle-check-classpath-file* nil "some/random/path.cp" "/a/b/c" nil))))))



(provide 'jdee-gradle-test)
;;; jdee-gradle-test.el ends here
