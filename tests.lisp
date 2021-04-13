(defpackage :statslite/test (:use #:cl #:statslite #:5am))
(in-package :statslite/test)

(def-suite :statslite-suite)
(in-suite :statslite-suite)

; TODO better account for floating point errors
(defun more-or-less (n)
  (check-type n number)
  (format nil "~,2f" n))
(defmacro approx (got expected)
  `(is (string= (more-or-less ,got) ,expected)))

; so this is at least as bad as R is:
;   > x = c(0, 0, 1, 2, 63, 61, 27, 13)
;   > length(x)
;   [1] 8
;   > min(x)
;   [1] 0
;   > max(x)
;   [1] 63
;   > range(x)
;   [1]  0 63
;   > mean(x)
;   [1] 20.875
;   > sd(x)
;   [1] 27.01025
(test statslite
 (let ((ret (statslite '(0 0 1 2 63 61 27 13))))
   ; TODO not sure if this is portable or if PRIN1 is correct
   #+SBCL
   (is (string= (prin1-to-string ret)
                "#<STATSLITE 8 [0.00 63.00] mean 20.88 range 63.00 sd 27.01>"))
   (is (equal (statslite-count ret) 8))
   (is (zerop (statslite-min ret)))
   (is (equal (statslite-max ret) 63))
   (is (equal (statslite-range ret) 63))
   (is (approx (statslite-mean ret) "20.88"))
   (is (approx (statslite-sd ret) "27.01"))))

;  > fivenum(x)
;  [1]  0.0  0.5  7.5 44.0 63.0
;  > quantile(x, type=2);
;    0%  25%  50%  75% 100%
;   0.0  0.5  7.5 44.0 63.0
(test statsmore
 (let ((ret (statsmore '(0 0 1 2 63 61 27 13))))
   #+SBCL
   (is (string= (prin1-to-string ret)
                "#<STATSMORE 8 [0.00 0.50 7.50 44.00 63.00] mean 20.88 range 63.00 sd 27.01>"))
   (is (equal (statsmore-count ret) 8))
   (is (zerop (statsmore-min ret)))
   (is (equal (statsmore-max ret) 63))
   (is (equal (statsmore-range ret) 63))
   (is (approx (statsmore-mean ret) "20.88"))
   (is (approx (statsmore-sd ret) "27.01"))
   (is (approx (statsmore-1st ret) "0.50"))
   (is (approx (statsmore-median ret) "7.50"))
   (is (approx (statsmore-3rd ret) "44.00"))))

; the 0 .. something used above is a bad range test
(test statsrange
 (let ((ret (statslite '(42 640))))
   (is (equal (statslite-range ret) 598))))
