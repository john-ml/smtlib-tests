(set-option :produce-proofs true)

(declare-datatype Prod (par (A B) ((pair (fst A) (snd B)))))

(define-sort Var () Int)
(declare-datatype Exp (
  (LVar (lvar-x Var))
  (LBool (lbool-b Bool))
  (And (and-e1 Exp) (and-e2 Exp))
  (Let (let-x Var) (let-e1 Exp) (let-e2 Exp))
))

(define-sort Val () Bool)
(define-sort Env () (List (Prod Var Val)))

(declare-fun bstep (Env Exp Val) Bool)
(declare-fun find (Env Var Val) Bool)

(assert (forall ((x Var) (v Val) (rho Env)) (find (insert (pair x v) rho) x v)))
(assert (forall ((rho Env) (x Var) (v Val) (y Var) (w Val)) (=>
  (find rho x v)
  (distinct x y)
  (find (insert (pair y w) rho) x v)
)))

; Lookups seem to work
;(assert (not
;  (find
;    (insert (pair 0 true) (insert (pair 1 true) (insert (pair 2 false) nil)))
;    2 false)))
;(check-sat)
;(get-proof)

(assert (forall ((rho Env) (x Var) (v Val)) (=>
  (find rho x v)
  (bstep rho (LVar x) v))))
(assert (forall ((rho Env) (b Val)) (bstep rho (LBool b) b)))
(assert (forall ((rho Env) (e1 Exp) (e2 Exp) (b1 Bool) (b2 Bool)) (=>
  (bstep rho e1 b1)
  (bstep rho e2 b2)
  (bstep rho (And e1 e2) (and b1 b2))
)))
(assert (forall ((rho Env) (x Var) (e1 Exp) (e2 Exp) (b1 Bool) (b2 Bool)) (=>
  (bstep rho e1 b1)
  (bstep (insert (pair x b1) rho) e2 b2)
  (bstep rho (Let x e1 e2) b2)
)))

; Used to identify the synthesized exp in the proof
(declare-fun the-answer-is (Exp) bool)
(assert (forall ((e Exp)) (the-answer-is e)))

; Synthesizes (LVar 0)
(push)
(assert (forall ((e Exp)) (not (and
  (the-answer-is e)
  (bstep (insert (pair 0 true) nil) e true)
  (bstep (insert (pair 0 false) nil) e false)
))))
(check-sat)
(get-proof)
(pop)

; ; Hangs
; (assert (forall ((e Exp)) (not (and
;   (the-answer-is e)
;   (bstep (insert (pair 0 false) (insert (pair 1 false) nil)) e false)
;   (bstep (insert (pair 0 false) (insert (pair 1 true) nil)) e false)
;   (bstep (insert (pair 0 true) (insert (pair 1 false) nil)) e false)
;   (bstep (insert (pair 0 true) (insert (pair 1 true) nil)) e true)
; ))))
; (check-sat)
; (get-proof)

; ; Hangs
; (push)
; (assert (forall ((e Exp)) (not (and
;   (the-answer-is e)
;   (bstep (insert (pair 0 true) (insert (pair 1 true) nil)) e true)
;   (bstep (insert (pair 0 true) (insert (pair 1 false) nil)) e false)
; ))))
; (check-sat)
; (get-proof)
; (pop)
