(asdf:defsystem #:statslite
  :components ((:file "statslite"))
  :in-order-to ((test-op (test-op "statslite/test")))
  :version "0.0.2"
  :author "Jeremy Mates <jmates@cpan.org>"
  :license "BSD"
  :description "wafer-thin statistics library")

; KLUGE statslite/test system is defined here; could not get
; statslite-test.asd nor statslite.test.asd files to not fail in various
; ways (errors, system not found, etc) after much fiddling and copying
; from various systems. meanwhile,
;
;   (ql:quickload :statslite)
;   (asdf:test-system :statslite)
;
; results in:
;
;   WARNING:
;     Deprecated recursive use of (ASDF/OPERATE:OPERATE 'ASDF/LISP-ACTION:LOAD-OP
;     '("statslite/test")) while visiting
;     (ASDF/LISP-ACTION:TEST-OP "statslite/test") - please use proper dependencies
;     instead
;
; for statements copied from asdf.pdf section 7.1.1 or so.
;
; the "runtests" script adapted from "testscr.ros" under
; cl-ansi-text-20200218-git however appears to work?
(asdf:defsystem #:statslite/test
  :depends-on (#:statslite #:fiveam)
  :components ((:file "tests"))
  :perform (test-op (o c)
                    (load-system :statslite/test)
                    (symbol-call :5am :run! :statslite-suite))
  :description "test suite for statslite")
