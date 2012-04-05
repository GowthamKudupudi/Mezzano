(in-package #:sys.int)

(defun integerp (object)
  (system:fixnump object))

(defun realp (object)
  (integerp object))

(defun numberp (object)
  (realp object))

(defun expt (base power)
  (let ((accum 1))
    (dotimes (i power accum)
      (setf accum (* accum base)))))

(defstruct (byte (:constructor byte (size position)))
  (size 0 :type (integer 0) :read-only-p t)
  (position 0 :type (integer 0) :read-only-p t))

(defun ldb (bytespec integer)
  (logand (ash integer (- (byte-position bytespec)))
          (1- (ash 1 (byte-size bytespec)))))

(defun dpb (newbyte bytespec integer)
  (let ((mask (1- (ash 1 (byte-size bytespec)))))
    (logior (ash (logand newbyte mask) (byte-position bytespec))
            (logand integer (lognot (ash mask (byte-position bytespec)))))))

(define-compiler-macro ldb (&whole whole bytespec integer)
  (cond ((and (listp bytespec)
              (= (length bytespec) 3)
              (eql (first bytespec) 'byte)
              (integerp (second bytespec))
              (not (minusp (second bytespec)))
              (integerp (third bytespec))
              (not (minusp (third bytespec))))
         `(logand (ash ,integer ,(- (third bytespec)))
                  ,(1- (ash 1 (second bytespec)))))
        (t whole)))

(define-compiler-macro dpb (&whole whole newbyte bytespec integer)
  (cond ((and (listp bytespec)
              (= (length bytespec) 3)
              (eql (first bytespec) 'byte)
              (integerp (second bytespec))
              (not (minusp (second bytespec)))
              (integerp (third bytespec))
              (not (minusp (third bytespec))))
         ;; Maintain correct order of evaluation for NEWBYTE and INTEGER.
         (let ((mask (1- (ash 1 (second bytespec)))))
           `(logior (ash (logand ,newbyte ,mask) ,(third bytespec))
                    (logand ,integer ,(lognot (ash mask (third bytespec)))))))
        (t whole)))

;;; From SBCL 1.0.55
(defun ceiling (number divisor)
  ;; If the numbers do not divide exactly and the result of
  ;; (/ NUMBER DIVISOR) would be positive then increment the quotient
  ;; and decrement the remainder by the divisor.
  (multiple-value-bind (tru rem) (truncate number divisor)
    (if (and (not (zerop rem))
             (if (minusp divisor)
                 (minusp number)
                 (plusp number)))
        (values (+ tru 1) (- rem divisor))
        (values tru rem))))

(defun generic-< (x y)
  (error "TODO"))

(defun generic->= (x y)
  (generic-< y x))

(defun generic-> (x y)
  (error "TODO"))

(defun generic-<= (x y)
  (generic-> y x))

(defun generic-= (x y)
  (error "TODO"))

(defun generic-truncate (number divisor)
  (error "TODO"))

(defun generic-rem (number divisor)
  (multiple-value-bind (quot rem)
      (generic-truncate number divisor)
    (declare (ignore quot))
    rem))

(defun generic-+ (x y)
  (error "TODO"))

(defun generic-- (x y)
  (error "TODO"))

(defun generic-* (x y)
  (error "TODO"))
