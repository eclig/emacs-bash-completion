;;; bacom-tests.el --- Tests cases for bacom.el

;; Copyright (C) 2013 Emílio Lopes
;; Copyright (C) 2009 Stephane Zermatten

;; Author: Stephane Zermatten <szermatt@gmx.net>
;;         Emílio Lopes <eclig@gmx.net>
;; Keywords: processes

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see `http://www.gnu.org/licenses/'.

;;; Commentary:
;;
;; This file defines regression tests for the "bacom" package.
;; Eval these forms to run the tests:
;;
;;     (ert '(tag bacom))
;;     (ert '(tag bacom-integration))
;;
;; See Info(ert) for more information.

;;; Code:

(require 'ert)
(require 'bacom)
(require 'sz-testutils)

(eval-when-compile
  '(require cl-macs))

(ert-deftest bacom-test-join-simple ()
  :tags '(bacom)
  "bacom-join simple"
  (should (string=
           (bacom-join
            '("a" "hello" "world" "b" "c"))
           "a hello world b c")))

(ert-deftest bacom-test-join-escape-quote ()
  :tags '(bacom)
  "bacom-join escape quote"
  (should (string=
           (bacom-join '("a" "hel'lo" "world" "b" "c"))
           "a 'hel'\\''lo' world b c")))

(ert-deftest bacom-test-join-escape-space ()
  :tags '(bacom)
  "bacom-join escape space"
  (should (string=
           (bacom-join '("a" "hello world" "b" "c"))
           "a 'hello world' b c")))

(ert-deftest bacom-test-tokenize-simple ()
  :tags '(bacom)
  "bacom-tokenize simple"
  (should (equal
           (sz-testutils-with-buffer
            '("a hello world b c")
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("a" "hello" "world" "b" "c"))))

(ert-deftest bacom-test-tokenize-simple-extra-spaces ()
  :tags '(bacom)
  "bacom-tokenize simple extra spaces"
  (should (equal
           (sz-testutils-with-buffer
            '("  a  hello \n world \t b \r c  ")
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position 2))))
           '("a" "hello" "world" "b" "c"))))

(ert-deftest bacom-test-tokenize-escaped-char ()
  :tags '(bacom)
  "bacom-tokenize escaped char"
  (should (equal
           (sz-testutils-with-buffer
            '("a hello\\-world b c")
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("a" "hello-world" "b" "c"))))

(ert-deftest bacom-test-tokenize-escaped-space ()
  :tags '(bacom)
  "bacom-tokenize escaped space"
  (should (equal
           (sz-testutils-with-buffer
            '("a hello\\ world b c")
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("a" "hello world" "b" "c"))))

(ert-deftest bacom-test-tokenize-escaped-hash ()
  :tags '(bacom)
  "bacom-tokenize escaped #"
  (should (equal
           (sz-testutils-with-buffer
            '("a hello \\#world\\# b")
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("a" "hello" "#world#" "b"))))

(ert-deftest bacom-test-tokenize-double-quotes ()
  :tags '(bacom)
  "bacom-tokenize double quotes"
  (should (equal
           (sz-testutils-with-buffer
            '("a \"hello world\" b c")
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("a" "hello world" "b" "c"))))

(ert-deftest bacom-test-tokenize-double-quotes-escaped ()
  :tags '(bacom)
  "bacom-tokenize double quotes escaped"
  (should (equal
           (sz-testutils-with-buffer
            '("a \"-\\\"hello world\\\"-\" b c")
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("a" "-\"hello world\"-" "b" "c"))))

(ert-deftest bacom-test-tokenize-single-quotes ()
  :tags '(bacom)
  "bacom-tokenize single quotes"
  (should (equal
           (sz-testutils-with-buffer
            '("a \"hello world\" b c")
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("a" "hello world" "b" "c"))))

(ert-deftest bacom-test-tokenize-single-quotes-escaped ()
  :tags '(bacom)
  "bacom-tokenize single quotes escaped"
  (should (equal
           (sz-testutils-with-buffer
            '("a '-\\'hello world\\'-' b c")
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("a" "-\\hello" "world'- b c"))))

(ert-deftest bacom-test-get-token-open-single-quote ()
  :tags '(bacom)
  "bacom-tokenize with a single quote open"
  (should (string=
           (sz-testutils-with-buffer
            '("hello 'world")
            ;; 123456789
            (goto-char 7)
            (bacom-token-string
             (bacom-get-token (line-end-position))))
           "world")))

(ert-deftest bacom-test-tokenize-open-single-quote-limited ()
  :tags '(bacom)
  "bacom-tokenize with a single quote open limited"
  (should (string=
           (sz-testutils-with-buffer
            '("hello 'world")
            ;; 123456789
            (goto-char 7)
            (bacom-token-string
             (bacom-get-token 10)))
           "wo")))

(ert-deftest bacom-test-tokenize-complex-quote-mix ()
  :tags '(bacom)
  "bacom-tokenize complex quote mix"
  (should (equal
           (sz-testutils-with-buffer
            '("a hel\"lo w\"o'rld b'c d")
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("a" "hello world bc" "d"))))

(ert-deftest bacom-test-tokenize-unescaped-semicolon ()
  :tags '(bacom)
  "bacom-tokenize unescaped semicolon"
  (should (equal
           (sz-testutils-with-buffer
            "to infinity;and\\ beyond"
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("to" "infinity" ";" "and beyond"))))

(ert-deftest bacom-test-tokenize-unescaped-and ()
  :tags '(bacom)
  "bacom-tokenize unescaped &&"
  (should (equal
           (sz-testutils-with-buffer
            "to infinity&&and\\ beyond"
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("to" "infinity" "&&" "and beyond"))))

(ert-deftest bacom-test-tokenize-unescaped-or ()
  :tags '(bacom)
  "bacom-tokenize unescaped ||"
  (should (equal
           (sz-testutils-with-buffer
            "to infinity||and\\ beyond"
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("to" "infinity" "||" "and beyond"))))

(ert-deftest bacom-test-tokenize-quoted-separators ()
  :tags '(bacom)
  "bacom-tokenize quoted ;&|"
  (should (equal
           (sz-testutils-with-buffer
            "to \"infinity;&|and\" beyond"
            (bacom-strings-from-tokens
             (bacom-tokenize 1 (line-end-position))))
           '("to" "infinity;&|and" "beyond"))))

(ert-deftest bacom-test-parse-line-cursor-at-end-of-word ()
  :tags '(bacom)
  "bacom-parse-line cursor at end of word"
  (should (equal
           (sz-testutils-with-buffer
            "a hello world"
            (bacom-parse-line 1 (line-end-position)))
           '((line . "a hello world")
             (point . 13)
             (cword . 2)
             (stub . "world")
             (words "a" "hello" "world")))))

(ert-deftest bacom-test-parse-line-cursor-in-the-middle-of-a-word ()
  :tags '(bacom)
  "bacom-parse-line cursor in the middle of a word"
  (should (equal
           (sz-testutils-with-buffer
            "a hello wo"
            (bacom-parse-line 1 (line-end-position)))
           '((line . "a hello wo")
             (point . 10)
             (cword . 2)
             (stub . "wo")
             (words "a" "hello" "wo")))))

(ert-deftest bacom-test-parse-line-cursor-at-the-beginning ()
  :tags '(bacom)
  "bacom-parse-line cursor at the beginning"
  (should (equal
           (sz-testutils-with-buffer
            " "
            (bacom-parse-line 1 (line-end-position)))
           '((line . "")
             (point . 0)
             (cword . 0)
             (stub . "")
             (words "")))))

(ert-deftest bacom-test-parse-line-cursor-in-the-middle ()
  :tags '(bacom)
  "bacom-parse-line cursor in the middle"
  (should (equal
           (sz-testutils-with-buffer
            "a hello "
            (bacom-parse-line 1 (line-end-position)))
           '((line . "a hello ")
             (point . 8)
             (cword . 2)
             (stub . "")
             (words "a" "hello" "")))))

(ert-deftest bacom-test-parse-line-cursor-at-end ()
  :tags '(bacom)
  "bacom-parse-line cursor at end"
  (should (equal
           (sz-testutils-with-buffer
            "a hello world b c"
            (bacom-parse-line 1 (line-end-position)))
           '((line . "a hello world b c")
             (point . 17)
             (cword . 4)
             (stub . "c")
             (words "a" "hello" "world" "b" "c")))))

(ert-deftest bacom-test-parse-line-complex-multi-command-line ()
  :tags '(bacom)
  "bacom-parse-line complex multi-command line"
  (should (equal
           (sz-testutils-with-buffer
            "cd /var/tmp ; ZORG=t make -"
            (bacom-parse-line 1 (line-end-position)))
           '((line . "make -")
             (point . 6)
             (cword . 1)
             (stub . "-")
             (words "make" "-")))))

(ert-deftest bacom-test-parse-line-pipe ()
  :tags '(bacom)
  "bacom-parse-line pipe"
  (should (equal
           (sz-testutils-with-buffer
            "ls /var/tmp | sort -"
            (bacom-parse-line 1 (line-end-position)))
           '((line . "sort -")
             (point . 6)
             (cword . 1)
             (stub . "-")
             (words "sort" "-")))))

(ert-deftest bacom-test-parse-line-escaped-semicolon ()
  :tags '(bacom)
  "bacom-parse-line escaped semicolon"
  (should (equal
           (sz-testutils-with-buffer
            "find -name '*.txt' -exec echo {} ';' -"
            (bacom-parse-line 1 (line-end-position)))
           '((line . "find -name '*.txt' -exec echo {} ';' -")
             (point . 38)
             (cword . 7)
             (stub . "-")
             (words "find" "-name" "*.txt" "-exec" "echo" "{}" ";" "-")))))

(ert-deftest bacom-test-parse-line-at-var-assignment ()
  :tags '(bacom)
  "bacom-parse-line at var assignment"
  (should (equal
           (sz-testutils-with-buffer
            "cd /var/tmp ; A=f ZORG=t"
            (bacom-parse-line 1 (line-end-position)))
           '((line . "ZORG=t")
             (point . 6)
             (cword . 0)
             (stub . "ZORG=t")
             (words "ZORG=t")))))

(ert-deftest bacom-test-parse-line-cursor-after-end ()
  :tags '(bacom)
  "bacom-parse-line cursor after end"
  (should (equal
           (sz-testutils-with-buffer
            "a hello world b c "
            (bacom-parse-line 1 (line-end-position)))
           '((line . "a hello world b c ")
             (point . 18)
             (cword . 5)
             (stub . "")
             (words "a" "hello" "world" "b" "c" "")))))

(ert-deftest bacom-test-parse-line-with-escaped-quote ()
  :tags '(bacom)
  "bacom-parse-line with escaped quote"
  (should (equal
           (sz-testutils-with-buffer
            "cd /vcr/shows/Dexter\\'s"
            (bacom-parse-line 1 (line-end-position)))
           '((line . "cd /vcr/shows/Dexter\\'s")
             (point . 23)
             (cword . 1)
             (stub . "/vcr/shows/Dexter's")
             (words "cd" "/vcr/shows/Dexter's")))))

(ert-deftest bacom-test-add-rule-garbage ()
  :tags '(bacom)
  "bacom-add-rule garbage"
  (should (let ((rules (make-hash-table :test 'equal)))
            (bacom-add-rule (list "just" "some" "garbage") rules)
            (zerop (hash-table-count rules)))))

(ert-deftest bacom-test-add-rule-empty ()
  :tags '(bacom)
  "bacom-add-rule empty"
  (should (let ((rules (make-hash-table :test 'equal)))
            (bacom-add-rule nil rules)
            (zerop (hash-table-count rules)))))

(ert-deftest bacom-test-add-rule-empty-string ()
  :tags '(bacom)
  "bacom-add-rule empty string"
  (should (let ((rules (make-hash-table :test 'equal)))
            (bacom-add-rule (list "") rules)
            (zerop (hash-table-count rules)))))

(ert-deftest bacom-test-add-rule-empty-complete ()
  :tags '(bacom)
  "bacom-add-rule empty complete"
  (should (let ((rules (make-hash-table :test 'equal)))
            (bacom-add-rule (list "complete") rules)
            (zerop (hash-table-count rules)))))

(ert-deftest bacom-test-add-rule-one-command ()
  :tags '(bacom)
  "bacom-add-rule one command"
  (should (equal
           (let ((rules (make-hash-table :test 'equal)))
             (bacom-add-rule (list "complete" "-e" "-F" "_cdargs_aliases" "cdb") rules)
             (gethash "cdb" rules))
           '("-e" "-F" "_cdargs_aliases"))))

(ert-deftest bacom-test-initialize-rules ()
  :tags '(bacom)
  "bacom-initialize-rules"
  (should (equal
           (sz-testutils-with-buffer
            (concat "\n"
                    "complete -F _cdargs_aliases cdb\n"
                    "complete -F complete_projects project\n"
                    "complete -F complete_projects pro\n"
                    "complete -F _cdargs_aliases cv\n"
                    "complete -F _cdargs_aliases cb\n"
                    "garbage\n")
            (let ((rules (make-hash-table :test 'equal)))
              (bacom-initialize-rules (current-buffer) rules)
              (mapcar (lambda (cmd)
                        (cons cmd (gethash cmd rules)))
                      (list "cdb" "project" "pro" "cv" "cb"))))
           '(("cdb" "-F" "_cdargs_aliases")
             ("project" "-F" "complete_projects")
             ("pro" "-F" "complete_projects")
             ("cv" "-F" "_cdargs_aliases")
             ("cb" "-F" "_cdargs_aliases")))))

(ert-deftest bacom-test-quote-not-necessary ()
  :tags '(bacom)
  "bacom-quote not necessary"
  (should (string=
           (bacom-quote "hello")
           "hello")))

(ert-deftest bacom-test-quote-space ()
  :tags '(bacom)
  "bacom-quote space"
  (should (string=
           (bacom-quote "hello world")
           "'hello world'")))

(ert-deftest bacom-test-quote-quote ()
  :tags '(bacom)
  "bacom-quote quote"
  (should (string=
           (bacom-quote "hell'o")
           "'hell'\\''o'")))

(ert-deftest bacom-test-generate-line-no-custom-completion ()
  :tags '(bacom)
  "bacom-generate-line no custom completion"
  (should (string=
           (let ((bacom-initialized t)
                 (bacom-rules (make-hash-table :test 'equal))
                 (default-directory "~/test"))
             (bacom-generate-line "hello worl" 7 '("hello" "worl") 1 "worl"))
           (format "compgen -P '%s' -f -- worl" bacom-candidates-prefix))))

(ert-deftest bacom-test-generate-line-custom-completion-no-function-or-command ()
  :tags '(bacom)
  "bacom-generate-line custom completion no function or command"
  (should (string=
           (let ((bacom-initialized t)
                 (bacom-rules (make-hash-table :test 'equal))
                 (default-directory "/test"))
             (bacom-add-rule (list "complete" "-A" "-G" "*.txt" "zorg") bacom-rules)
             (bacom-generate-line "zorg worl" 7 '("zorg" "worl") 1 "worl"))
           (format "compgen -P '%s' -A -G '*.txt' -- worl" bacom-candidates-prefix))))

(ert-deftest bacom-test-bacom-specification ()
  :tags '(bacom)
  "bacom-specification"
  (let ((bacom-initialized t)
        (bacom-rules (make-hash-table :test 'equal))
        (default-directory "/test"))
    (bacom-add-rule (list "complete" "-A" "-G" "*.txt" "zorg") bacom-rules)
    (let ((system-type 'toto))
      (should
       (equal (bacom-specification "zorg")
              '("-A" "-G" "*.txt")))
      (should
       (equal (bacom-specification "/bin/zorg")
              '("-A" "-G" "*.txt")))
      (should-not (bacom-specification "zorg.exe"))
      (should-not (bacom-specification "/bin/zorg.exe")))

    (let ((system-type 'windows-nt))
      (should
       (equal (bacom-specification "zorg")
              '("-A" "-G" "*.txt")))
      (should-not (bacom-specification "zorgo.exe"))
      (should
       (equal (bacom-specification "zorg.exe")
              '("-A" "-G" "*.txt")))
      (should
       (equal (bacom-specification "c:\\foo\\bar\\zorg.exe")
              '("-A" "-G" "*.txt"))))))

(ert-deftest bacom-test-generate-line-custom-completion-function ()
  :tags '(bacom)
  "bacom-generate-line custom completion function"
  (should (string=
           (let ((bacom-initialized t)
                 (bacom-rules (make-hash-table :test 'equal))
                 (default-directory "/test"))
             (bacom-add-rule (list "complete" "-F" "__zorg" "zorg") bacom-rules)
             (bacom-generate-line "zorg worl" 7 '("zorg" "worl") 1 "worl"))
           (format "__BASH_COMPLETE_WRAPPER='COMP_LINE='\\''zorg worl'\\''; COMP_POINT=7; COMP_CWORD=1; COMP_WORDS=( zorg worl ); __zorg \"${COMP_WORDS[@]}\"' compgen -P '%s' -F __bash_complete_wrapper -- worl" bacom-candidates-prefix))))

(ert-deftest bacom-test-generate-line-custom-completion-command ()
  :tags '(bacom)
  "bacom-generate-line custom completion command"
  (should (string=
           (let ((bacom-initialized t)
                 (bacom-rules (make-hash-table :test 'equal))
                 (default-directory "/test"))
             (bacom-add-rule (list "complete" "-C" "__zorg" "zorg") bacom-rules)
             (bacom-generate-line "zorg worl" 7 '("zorg" "worl") 1 "worl"))
           (format "__BASH_COMPLETE_WRAPPER='COMP_LINE='\\''zorg worl'\\''; COMP_POINT=7; COMP_CWORD=1; COMP_WORDS=( zorg worl ); __zorg \"${COMP_WORDS[@]}\"' compgen -P '%s' -F __bash_complete_wrapper -- worl" bacom-candidates-prefix))))

(ert-deftest bacom-test-starts-with-empty-str ()
  :tags '(bacom)
  "bacom-starts-with empty str"
  (should-not (bacom-starts-with "" "prefix")))

(ert-deftest bacom-test-starts-with-starts-with ()
  :tags '(bacom)
  "bacom-starts-with starts with"
  (should (bacom-starts-with "blah-blah" "blah-")))

(ert-deftest bacom-test-starts-with-does-not-starts-with ()
  :tags '(bacom)
  "bacom-starts-with does not starts with"
  (should-not (bacom-starts-with "blah-blah" "blih-")))

(ert-deftest bacom-test-starts-with-same ()
  :tags '(bacom)
  "bacom-starts-with same"
  (should (bacom-starts-with "blah-" "blah-")))

(ert-deftest bacom-test-send ()
  :tags '(bacom)
  "bacom-send"
  (should (string=
           (cl-letf ((bacom-initialized t)
                     (process 'something-else)
                     (kill-buffer-query-functions nil)
                     ((symbol-function 'get-buffer-process)
                      (lambda (buffer)
                        'process))
                     ((symbol-function 'processp)
                      (lambda (process)
                        (eq process 'process)))
                     ((symbol-function 'process-buffer)
                      (lambda (process)
                        (unless (eq process 'process)
                          (error "unexpected process: %s" process))
                        (current-buffer)))
                     ((symbol-function 'comint-redirect-send-command-to-process)
                      (lambda (command output-buffer process echo no-display)
                        (unless (eq process 'process)
                          (error "unexpected process: %s" process))
                        (unless (string= " cmd" command)
                          (error "unexpected command: %s" command))
                        (setq comint-redirect-completed nil)))
                     ((symbol-function 'accept-process-output)
                      (lambda (process timeout)
                        (insert "line1\nline2\n")
                        (setq comint-redirect-completed t)
                        t)))
             (with-temp-buffer
               (bacom-send "cmd" 'process (current-buffer))
               (buffer-string)))
           "line1\nline2\n")))

(ert-deftest bacom-test-addsuffix-ends-with-slash ()
  :tags '(bacom)
  "bacom-addsuffix ends with /"
  (should (string=
           (cl-letf (((symbol-function 'file-accessible-directory-p)
                      (lambda (a)
                        (error "unexpected"))))
             (bacom-addsuffix "hello/"))
           "hello/")))

(ert-deftest bacom-test-addsuffix-ends-with-space ()
  :tags '(bacom)
  "bacom-addsuffix ends with space"
  (should (string=
           (cl-letf (((symbol-function 'file-accessible-directory-p)
                      (lambda (a)
                        (error "unexpected"))))
             (bacom-addsuffix "hello "))
           "hello ")))

(ert-deftest bacom-test-addsuffix-ends-with-separator ()
  :tags '(bacom)
  "bacom-addsuffix ends with separator"
  (should (string=
           (cl-letf (((symbol-function 'file-accessible-directory-p)
                      (lambda (a)
                        (error "unexpected"))))
             (bacom-addsuffix "hello:"))
           "hello:")))

(ert-deftest bacom-test-addsuffix-check-directory ()
  :tags '(bacom)
  "bacom-addsuffix check directory"
  (should (string=
           (cl-letf (((symbol-function 'file-accessible-directory-p)
                      (lambda (a)
                        (string= a
                                 (if (memq system-type '(windows-nt ms-dos))
                                     "c:/tmp/hello"
                                   "/tmp/hello"))))
                     (default-directory
                       (if (memq system-type '(windows-nt ms-dos))
                           "c:/tmp"
                         "/tmp")))
             (bacom-addsuffix "hello"))
           "hello/")))

(ert-deftest bacom-test-addsuffix-check-directory-expand-tilde ()
  :tags '(bacom)
  "bacom-addsuffix check directory, expand tilde"
  (should (string=
           (cl-letf (((symbol-function 'file-accessible-directory-p)
                      (lambda (a)
                        (string= a (concat (expand-file-name "y" "~/x")))))
                     (default-directory "~/x"))
             (bacom-addsuffix "y"))
           "y/")))

(ert-deftest bacom-test-starts-with ()
  :tags '(bacom)
  "bacom-starts-with"
  (should-not (bacom-starts-with "" "hello "))
  (should (bacom-starts-with "hello world" "hello "))
  (should-not (bacom-starts-with "hello world" "hullo "))
  (should (bacom-starts-with "hello" "")))

(ert-deftest bacom-test-ends-with ()
  :tags '(bacom)
  "bacom-ends-with"
  (should-not (bacom-ends-with "" "world"))
  (should (bacom-ends-with "hello world" "world"))
  (should-not (bacom-ends-with "hello world" "wurld"))
  (should (bacom-ends-with "hello" "")))

(ert-deftest bacom-test-last-wordbreak-split ()
  :tags '(bacom)
  "bacom-last-wordbreak-split"
  (should (equal (bacom-last-wordbreak-split "a:b:c:d:e")
                 '("a:b:c:d:" . "e")))
  (should (equal (bacom-last-wordbreak-split "hello=world")
                 '("hello=" . "world")))
  (should (equal (bacom-last-wordbreak-split "hello>world")
                 '("hello>" . "world")))
  (should (equal (bacom-last-wordbreak-split ">world")
                 '(">" . "world")))
  (should (equal (bacom-last-wordbreak-split "hello")
                 '("" . "hello"))))

(ert-deftest bacom-test-before-last-wordbreak ()
  :tags '(bacom)
  "bacom-before-last-wordbreak"
  (should (string= (bacom-before-last-wordbreak "a:b:c:d:e") "a:b:c:d:"))
  (should (string= (bacom-before-last-wordbreak "hello=world") "hello="))
  (should (string= (bacom-before-last-wordbreak "hello>world") "hello>"))
  (should (string= (bacom-before-last-wordbreak "hello") "")))

(ert-deftest bacom-test-after-last-wordbreak ()
  :tags '(bacom)
  "bacom-after-last-wordbreak"
  (should (string= (bacom-after-last-wordbreak "a:b:c:d:e") "e"))
  (should (string= (bacom-after-last-wordbreak "hello=world") "world"))
  (should (string= (bacom-after-last-wordbreak "hello>world") "world"))
  (should (string= (bacom-after-last-wordbreak "hello") "hello")))

(ert-deftest bacom-test-postprocess-escape-rest ()
  :tags '(bacom)
  "bacom-postprocess escape rest"
  (should (string=
           (bacom-postprocess "a\\ bc d e" "a\\ b")
           "a\\ bc\\ d\\ e")))

(ert-deftest bacom-test-postprocess-do-not-escape-final-space ()
  :tags '(bacom)
  "bacom-postprocess do not escape final space"
  (should (string=
           (let ((bacom-nospace nil))
             (bacom-postprocess "ab " "a"))
           "ab ")))

(ert-deftest bacom-test-postprocess-remove-final-space ()
  :tags '(bacom)
  "bacom-postprocess remove final space"
  (should (string=
           (let ((bacom-nospace t))
             (bacom-postprocess "ab " "a"))
           "ab")))

(ert-deftest bacom-test-postprocess-unexpand-home-and-escape ()
  :tags '(bacom)
  "bacom-postprocess unexpand home and escape"
  (should (string=
           (bacom-postprocess (expand-file-name "~/a/hello world") "~/a/he")
           "~/a/hello\\ world")))

(ert-deftest bacom-test-postprocess-match-after-wordbreak-and-escape ()
  :tags '(bacom)
  "bacom-postprocess match after wordbreak and escape"
  (should (string=
           (bacom-postprocess "hello world" "a:b:c:he")
           "a:b:c:hello\\ world")))

(ert-deftest bacom-test-postprocess-just-append ()
  :tags '(bacom)
  "bacom-postprocess just append"
  (should (string=
           (bacom-postprocess " world" "hello")
           "hello\\ world")))

(ert-deftest bacom-test-postprocess-subset-of-the-prefix ()
  :tags '(bacom)
  "bacom-postprocess subset of the prefix"
  (should (string=
           (bacom-postprocess "Dexter" "Dexter'")
           "Dexter")))

(ert-deftest bacom-test-postprocess-for-ending-with-a-slash ()
  :tags '(bacom)
  "bacom-postprocess for \"~\" ending with a slash"
  (should (string=
           (cl-letf ((real-expand-file-name (symbol-function 'expand-file-name))
                     ((symbol-function 'expand-file-name)
                      (lambda (name &optional default-dir)
                        (if (string= name "~")
                            "/"
                          (funcall real-expand-file-name name default-dir)))))
             (bacom-postprocess "/foo/bar" "~/f"))
           "~/foo/bar")))

(ert-deftest bacom-test-extract-candidates ()
  :tags '(bacom)
  "bacom-extract-candidates"
  (should (equal
           (let ((bacom-nospace nil))
             (sz-testutils-with-buffer
              (format "%shello world\n%shello \n\n" bacom-candidates-prefix bacom-candidates-prefix)
              (bacom-extract-candidates (current-buffer) "hello" nil)))
           '("hello\\ world" "hello "))))

(ert-deftest bacom-test-extract-candidates-with-spurious-output ()
  :tags '(bacom)
  "bacom-extract-candidates with spurious output"
  (should (equal
           (let ((bacom-nospace nil))
             (sz-testutils-with-buffer
              (format "%shello world\nspurious \n\n" bacom-candidates-prefix)
              (bacom-extract-candidates (current-buffer) "hello" nil)))
           '("hello\\ world"))))

(ert-deftest bacom-test-nonsep ()
  :tags '(bacom)
  "bacom-nonsep"
  (should (string= (bacom-nonsep nil) "^ \t\n\r;&|'\"\\\\#"))
  (should (string= (bacom-nonsep ?\') "^ \t\n\r'"))
  (should (string= (bacom-nonsep ?\") "^ \t\n\r\"\\\\")))

(ert-deftest bacom-test-escape-candidate-no-quote ()
  :tags '(bacom)
  "bacom-escape-candidate no quote"
  (should (string=
           (bacom-escape-candidate "He said: \"hello, 'you'\"" nil)
           "He\\ said:\\ \\\"hello,\\ \\'you\\'\\\""))
  (should (string=
           (bacom-escape-candidate "#hello#" nil)
           "\\#hello\\#")))

(ert-deftest bacom-test-escape-candidate-single-quote ()
  :tags '(bacom)
  "bacom-escape-candidate single quote"
  (should (string=
           (bacom-escape-candidate "He said: \"hello, 'you'\"" 39)
           "He said: \"hello, '\\''you'\\''\"")))

(ert-deftest bacom-test-escape-candidate-double-quote ()
  :tags '(bacom)
  "bacom-escape-candidate double quote"
  (should (string=
           (bacom-escape-candidate "He said: \"hello, 'you'\"" 34)
           "He said: \\\"hello, 'you'\\\"")))

(ert-deftest bacom-test-escape-candidate-no-quote-not-if-double-quoted ()
  :tags '(bacom)
  "bacom-escape-candidate no quote not if double quoted"
  (should (string=
           (bacom-escape-candidate "\"hello, you" nil)
           "\"hello, you")))

(ert-deftest bacom-test-escape-candidate-no-quote-not-if-single-quoted ()
  :tags '(bacom)
  "bacom-escape-candidate no quote not if single quoted"
  (should (string=
           (bacom-escape-candidate "'hello, you" nil)
           "'hello, you")))

(ert-deftest bacom-test-quote-allowed ()
  :tags '(bacom)
  "bacom-quote allowed"
  (should (string=
           (bacom-quote "abc_ABC/1-2.3")
           "abc_ABC/1-2.3")))

(ert-deftest bacom-test-quote-quoted ()
  :tags '(bacom)
  "bacom-quote quoted"
  (should (string=
           (bacom-quote "a$b")
           "'a$b'")))

(ert-deftest bacom-test-quote-quoted-single-quote ()
  :tags '(bacom)
  "bacom-quote quoted single quote"
  (should (string=
           (bacom-quote "a'b")
           "'a'\\''b'")))

(ert-deftest bacom-test-join ()
  :tags '(bacom)
  "bacom-join"
  (should (string=
           (bacom-join '("ls" "-l" "/a/b" "/a/b c" "/a/b'c" "$help/d"))
           "ls -l /a/b '/a/b c' '/a/b'\\''c' '$help/d'")))

(ert-deftest bacom-test-completion-in-region ()
  :tags '(bacom)
  "Simple tests for `completion-in-region'."
  (should (string=
           (sz-testutils-with-buffer
            '("f" cursor "b")
            (let ((completion-styles '(basic)))
              (completion-in-region (point-min) (point-max) '("foo-bar" "fox" "fun")))
            (buffer-string))
           "foo-bar"))

  (should (string=
           (sz-testutils-with-buffer
            '("f" cursor "n")
            (let ((completion-styles '(basic)))
              (completion-in-region (point-min) (point-max) '("foo-bar" "fox" "fun")))
            (buffer-string))
           "fun"))


  (should (string=
           (sz-testutils-with-buffer
            '("f-" cursor "b")
            (let ((completion-styles '(basic)))
              (completion-in-region (point-min) (point-max) '("foo-bar" "fox" "fun")))
            (buffer-string))
           "f-b"))

  (should (string=
           (sz-testutils-with-buffer
            '("f-" cursor "b")
            (let ((completion-styles '(partial-completion)))
              (completion-in-region (point-min) (point-max) '("foo-bar" "fox" "fun")))
            (buffer-string))
           "foo-bar")))


(defmacro bacom-tests-with-shell (&rest body)
  (let ((shell-buffer (make-symbol "shell-buffer")))
    `(let ((,shell-buffer nil))
       (unwind-protect
           (progn
             (setq ,shell-buffer (generate-new-buffer "*bacom-tests-with-shell*"))
             (shell ,shell-buffer)
             (with-current-buffer ,shell-buffer
               (while (accept-process-output nil 1))
               (goto-char (point-max)) 
               (let ((start (point)))
                 ,@body)))
         (when ,shell-buffer
           (when (buffer-live-p ,shell-buffer)
             (comint-send-string ,shell-buffer "\nexit\n")
             (sit-for 1))
           (kill-buffer ,shell-buffer))))))

(ert-deftest bacom-test-interaction ()
  :tags '(bacom-integration)
  "bacom interaction"
  (should-not bacom-initialized)
  (should-not (hash-table-p bacom-rules))
  (should (member "help "
                  (bacom-tests-with-shell
                   (bacom-comm "hel" 4 '("hel") 0 "hel" nil)))))

(ert-deftest bacom-test-execute-one-completion ()
  :tags '(bacom-integration)
  "bacom execute one completion"
  (should (equal (bacom-tests-with-shell
                  (let ((pos (point)))
                    (insert "__bash_complete_")
                    (bacom-dynamic-complete)
                    (sit-for 1)
                    (buffer-substring-no-properties pos (point))))
                 "__bash_complete_wrapper ")))

(ert-deftest bacom-test-execute-wordbreak-completion ()
  :tags '(bacom-integration)
  "bacom execute wordbreak completion"
  (should (equal (bacom-tests-with-shell
                  (let ((pos (point)))
                    (insert "export PATH=/sbin:/bi")
                    (bacom-dynamic-complete)
                    (sit-for 1)
                    (buffer-substring-no-properties pos (point))))
                 "export PATH=/sbin:/bin")))

(provide 'bacom-tests)
;;; bacom-tests.el ends here