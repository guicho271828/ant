
(in-package :report.utilities)
(enable-annot-syntax)

@export
(defgeneric check-object-inherits-class (obj class))
(delegate-method check-object-inherits-class
				 (obj (class symbol (find-class class))))
(defmethod check-object-inherits-class (obj (class class))
  (if (member class
			  (class-precedence-list (class-of obj)))
	  t
	  (error "~t~a~% does not inherit ~%~t~a~% it should inherit one of these subclasses below: ~%~%~a"
			 obj class
			 (class-all-subclasses class))))

@export
(defgeneric class-all-subclasses (class))
(delegate-method class-all-subclasses ((obj t (class-of obj))))
(delegate-method class-all-subclasses ((class symbol (find-class class))))
(defmethod class-all-subclasses ((class class))
  (aif (class-direct-subclasses class)
	   (list class (mapcar #'class-all-subclasses it))
	   class))

@export
(defgeneric check-object-inherits-class-in-order
	(obj class-stronger class-weaker))
(delegate-method check-object-inherits-class-in-order
				 (obj 
				  (class-stronger symbol (find-class class-stronger))
				  class-weaker))
(delegate-method check-object-inherits-class-in-order
				 (obj 
				  class-stronger
				  (class-weaker symbol (find-class class-weaker))))
(defmethod check-object-inherits-class-in-order
	(obj (class-stronger class) (class-weaker class))
  (check-object-inherits-class obj class-stronger)
  (check-object-inherits-class obj class-weaker)
  (let ((lst (class-precedence-list (class-of obj))))
	(if (> (position class-stronger lst)
		   (position class-weaker lst))
		(error "class ~a comes before ~a in the class precedence list of the object: ~%~% ~a"
			   (class-name class-stronger)
			   (class-name class-weaker)
			   obj)
		t)))

@export
(defun check-object-inherits-class-in-orders (obj class-order)
  (check-object-inherits-class-in-order obj
										(first class-order)
										(second class-order))
  (when (third class-order)
	(check-object-inherits-class-in-orders obj (cdr class-order))))