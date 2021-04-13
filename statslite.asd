; this being mostly cargo culted from fiveam.asd

#.(unless (or #+asdf3.1 (version<= "3.1" (asdf-version)))
        (error "You need ASDF >= 3.1 to load this system correctly."))

(asdf:defsystem :statslite
  :components ((:file "statslite"))
  :in-order-to ((test-op (test-op :statslite/test)))
  :version "0.0.3"
  :author "Jeremy Mates <jmates@cpan.org>"
  :license "BSD"
  :description "wafer-thin statistics library")

(asdf:defsystem :statslite/test
  :depends-on (:statslite :fiveam)
  :components ((:file "tests"))
  :perform (test-op (o c) (symbol-call :5am :run! :statslite-suite))
  :description "test suite for statslite")
