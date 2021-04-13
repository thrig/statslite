(defpackage #:statslite
  (:use #:cl)
  (:export #:make-statslite #:make-statsmore #:statslite #:statslite-count
           #:statslite-min #:statslite-max #:statslite-mean #:statslite-range
           #:statslite-sd #:statsmore #:statsmore-count #:statsmore-min
           #:statsmore-max #:statsmore-mean #:statsmore-range
           #:statsmore-sd #:statsmore-1st #:statsmore-median #:statsmore-3rd))
(in-package #:statslite)

(declaim (inline average median-etc stdev)
         (optimize (speed 3)))

(defstruct
    (statslite
     (:print-function
      (lambda (sl stream depth)
        (declare (ignore depth))
        (format stream
                "#<STATSLITE ~d [~,2f ~,2f] mean ~,2f range ~,2f sd ~,2f>"
                (statslite-count sl) (statslite-min sl) (statslite-max sl)
                (statslite-mean sl) (statslite-range sl) (statslite-sd sl)))))
    "statslite struct with count min max mean range sd slots"
  (count 0 :type fixnum)
  (min 0 :type real)
  (mean 0 :type real)
  (max 0 :type real)
  (range 0 :type real)
  (sd 0 :type real))

(defstruct
    (statsmore (:include statslite)
     (:print-function
      (lambda (sm stream depth)
        (declare (ignore depth))
        (format stream
                "#<STATSMORE ~d [~,2f ~,2f ~,2f ~,2f ~,2f] mean ~,2f range ~,2f sd ~,2f>"
                (statsmore-count sm) (statsmore-min sm) (statsmore-1st sm)
                (statsmore-median sm) (statsmore-3rd sm) (statsmore-max sm)
                (statsmore-mean sm) (statsmore-range sm) (statsmore-sd sm)))))
    "statsmore struct with count min 1st median 3rd max mean range sd slots"
  (1st 0 :type real)
  (median 0 :type real)
  (3rd 0 :type real))

; denominator N - 1 to match sd in R
(defun stdev (seq mean n)
  (declare (fixnum n)
           (real mean))
  (the real
       (sqrt (/ (loop :for x :in seq :summing (expt (- x mean) 2)) (1- n)))))

(defun statslite (seq)
  "lite statistics on a sequence returning a statslite struct"
  (loop :for x :in seq
        :counting x :into count
        :minimizing x :into min
        :maximizing x :into max
        :summing x :into sum :finally
        (let ((mean (/ sum count)))
          (return (the statslite
            (make-statslite :count count :min min :mean mean :max max
                            :range (- max min) :sd (stdev seq mean count)))))))

(defun average (seq index)
  (declare (fixnum index))
  (the real (/ (+ (elt seq (1- index)) (elt seq index)) 2)))

(defun median-etc (seq count)
  (declare (fixnum count))
  (let* ((is-odd (oddp count))
         (mid-index (truncate (/ count 2)))
         (median (if is-odd (elt seq mid-index) (average seq mid-index)))
         (x (- count mid-index))
         (sub-index (truncate (/ x 2))))
    (if (evenp x)
        (values (average seq sub-index) median
                (average seq (- count sub-index)))
        (values (elt seq sub-index) median
                (elt seq (- count sub-index 1))))))

; s'more stats -- 1st/median/3rd should be equivalent to R's fivenum()
(defun statsmore (seq)
  "heavier statistics on a sequence returning a statsmore struct"
  (let ((newseq (sort (copy-seq seq) #'<)))
    (loop :for x :in newseq
          :counting x :into count
          :minimizing x :into min
          :maximizing x :into max
          :summing x :into sum :finally
          (let ((mean (/ sum count)))
            (multiple-value-bind (1st median 3rd)
              (median-etc newseq count)
              (return (the statsmore
                (make-statsmore :count count :min min :max max
                                :mean mean :range (- max min)
                                :sd (stdev newseq mean count)
                                :1st 1st :median median :3rd 3rd))))))))
