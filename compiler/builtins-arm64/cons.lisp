;;;; Copyright (c) 2016 Henry Harrington <henry.harrington@gmail.com>
;;;; This code is licensed under the MIT license.

;;;; Builtin functions for dealing with conses.

(in-package :mezzano.compiler.codegen.arm64)

(defbuiltin consp (object) ()
  (load-in-reg :x0 object t)
  (emit `(lap:and :x9 :x0 15)
        `(lap:subs :xzr :x9 ,sys.int::+tag-cons+))
  (predicate-result :eq))

(defbuiltin car (list) ()
  (let ((type-error-label (gensym))
        (out-label (gensym)))
    (emit-trailer (type-error-label)
      (raise-type-error :x0 'list))
    (load-in-reg :x0 list t)
    (smash-x0)
    (emit `(lap:subs :xzr :x0 :x26)
          `(lap:b.eq ,out-label)
          `(lap:and :x9 :x0 15)
          `(lap:subs :xzr :x9 ,sys.int::+tag-cons+)
          `(lap:b.ne ,type-error-label)
          `(lap:ldr :x0 (:x0 ,(- sys.int::+tag-cons+)))
          out-label)
    (setf *x0-value* (list (gensym)))))

(defbuiltin cdr (list) ()
  (let ((type-error-label (gensym))
        (out-label (gensym)))
    (emit-trailer (type-error-label)
      (raise-type-error :x0 'list))
    (load-in-reg :x0 list t)
    (smash-x0)
    (emit `(lap:subs :xzr :x0 :x26)
          `(lap:b.eq ,out-label)
          `(lap:and :x9 :x0 15)
          `(lap:subs :xzr :x9 ,sys.int::+tag-cons+)
          `(lap:b.ne ,type-error-label)
          `(lap:ldr :x0 (:x0 ,(+ (- sys.int::+tag-cons+) 8)))
          out-label)
    (setf *x0-value* (list (gensym)))))

(defbuiltin (setf car) (value object) ()
  (let ((type-error-label (gensym)))
    (emit-trailer (type-error-label)
      (raise-type-error :x1 'cons))
    (load-in-reg :x1 object t)
    (load-in-reg :x0 value t)
    (emit `(lap:and :x9 :x1 15)
          `(lap:subs :xzr :x9 ,sys.int::+tag-cons+)
          `(lap:b.ne ,type-error-label)
          `(lap:str :x0 (:x1 ,(- sys.int::+tag-cons+))))
    *x0-value*))

(defbuiltin (setf cdr) (value object) ()
  (let ((type-error-label (gensym)))
    (emit-trailer (type-error-label)
      (raise-type-error :x1 'cons))
    (load-in-reg :x1 object t)
    (load-in-reg :x0 value t)
    (emit `(lap:and :x9 :x1 15)
          `(lap:subs :xzr :x9 ,sys.int::+tag-cons+)
          `(lap:b.ne ,type-error-label)
          `(lap:str :x0 (:x1 ,(+ (- sys.int::+tag-cons+) 8))))
    *x0-value*))
