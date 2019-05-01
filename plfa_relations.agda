module plfa_relations where

import Relation.Binary.PropositionalEquality as Eq
import plfa_induction
import plfa_naturals

open plfa_naturals using (ℕ; zero; suc; _+_; _*_; _∸_; Bin; inc; To; From; mul2)
open plfa_naturals.Bin using (nil; x0_; x1_)
open plfa_induction using (*-identity; +-identity; +-comm; *-comm; +-suc)
open Eq using (_≡_; refl; cong)


data _≤_ : ℕ → ℕ → Set where

  z≤n : ∀ {n : ℕ}
      -----------
      → zero ≤ n

  s≤s : ∀ {n m : ℕ}
      → n ≤ m
      ----------------
      → suc n ≤ suc m

infix 4 _≤_

inv-s≤s : ∀ {m n : ℕ}
  → suc m ≤ suc n
  ---------------
  → m ≤ n
inv-s≤s (s≤s m≤n) = m≤n

inv-z≤n : ∀ {m : ℕ}
  → m ≤ zero
  -----------
  →
 m ≡ zero
inv-z≤n z≤n = refl

-- Relation (Pre-order and not partial order): x R y ⇔ gcd(x,y) ≠ 1
-- Relation (Partial order and not total order): "Estar contido em (conjuntos)"

≤-refl : ∀ {n : ℕ}
       ------------
       →  n ≤ n
≤-refl {zero} = z≤n
≤-refl {suc n} = s≤s (≤-refl {n})

≤-trans : ∀ {n m p : ℕ}
          → n ≤ m
          → m ≤ p
          -------------
          → n ≤ p
≤-trans z≤n _ = z≤n
≤-trans (s≤s (n≤m)) (s≤s (m≤p)) = s≤s (≤-trans (n≤m) (m≤p))

≤-trans' : ∀ (n m p : ℕ)
         → n ≤ m
         → m  ≤ p
         -----
         → n ≤ p
≤-trans' zero _ _ z≤n _ = z≤n
≤-trans' (suc n) (suc m) (suc p) (s≤s (n≤m)) (s≤s (m≤p)) = s≤s (≤-trans' n m p (n≤m) (m≤p))

≤-antisym : ∀ {m n : ℕ}
            → m ≤ n
            → n ≤ m
            ----------e-
            → n ≡ m
≤-antisym z≤n n≤z = inv-z≤n n≤z
≤-antisym (s≤s (m≤n)) (s≤s (n≤m)) = cong suc (≤-antisym (m≤n) (n≤m))

-- antisym (s≤s (m≤n)) (z≤m) is contradictory, the first hypotesis implies that n = suc n' and the second implies n = 0

data Total (m n : ℕ) : Set where
  forward :
    m ≤ n
    -----------
    → Total m n
  flipped :
    n ≤ m
    -----------
    → Total m n

data Total' : ℕ → ℕ → Set where
  forward' : ∀ (m n : ℕ)
            → m ≤ n
            -----------
            → Total' m n
  flipped' : ∀ (m n : ℕ)
            → n ≤ m
            -----------
            → Total' m n


≤-Total : ∀ (m n : ℕ) → Total m n
≤-Total zero n = forward z≤n
≤-Total (suc m) zero = flipped z≤n
≤-Total (suc m) (suc n) with ≤-Total m n
...                        | forward m≤n = forward (s≤s m≤n)
...                        | flipped n≤m = flipped (s≤s n≤m)

≤-Total' : ∀ (m n : ℕ) → Total m n
≤-Total' zero n = forward z≤n
≤-Total' (suc m) zero = flipped z≤n
≤-Total' (suc m) (suc n) = helper (≤-Total' m n)
  where
  helper : Total m n → Total (suc m) (suc n)
  helper (forward m≤n) = forward (s≤s (m≤n))
  helper (flipped n≤m) = flipped (s≤s (n≤m))

+-mono¹-≤ : ∀ (m p q : ℕ)
            → p ≤ q
            --------
            → m + p ≤ m + q

+-mono¹-≤ zero p q p≤q = p≤q
+-mono¹-≤ (suc m) p q p≤q = s≤s (+-mono¹-≤ m p q p≤q)

+-mono²-≤ : ∀ (m p q : ℕ)
            → p ≤ q
            ----------
            → p + m ≤ q + m
+-mono²-≤ m p q p≤q rewrite +-comm p m | +-comm q m = +-mono¹-≤ m p q p≤q

+-mono-≤ : ∀ (m n p q : ℕ)
  → m ≤ n
  → p ≤ q
  -------------
  → m + p ≤ n + q
+-mono-≤ m n p q m≤n p≤q  =  ≤-trans (+-mono²-≤ p m n m≤n) (+-mono¹-≤ n p q p≤q)


*-mono¹-≤ : ∀ (m p q : ℕ)
  → p ≤ q
  ----------
  → m * p ≤ m * q

*-mono¹-≤ zero _ _ _ = z≤n
*-mono¹-≤ (suc m) p q p≤q = +-mono-≤ p q (m * p) (m * q) p≤q (*-mono¹-≤ m p q p≤q)

*-mono²-≤ : ∀ (m p q : ℕ)
  → p ≤ q
  ----------
  → p * m ≤ q * m

*-mono²-≤ m p q p≤q rewrite *-comm p m | *-comm q m = *-mono¹-≤ m p q p≤q

*-mono-≤ : ∀ (m n p q : ℕ)
  → m ≤ n
  → p ≤ q
  ------------
  → m * p ≤ n * q

*-mono-≤ m n p q m≤n p≤q  =  ≤-trans (*-mono²-≤ p m n m≤n) (*-mono¹-≤ n p q p≤q)

infix 4 _<_

data _<_ : ℕ → ℕ → Set where
  z<s : ∀ {n : ℕ}
        ----------------
        → zero < (suc n)
  s<s : ∀ {m n : ℕ}
        → m < n
        ----------------
        → suc m < suc n


<-trans : ∀ {m n p : ℕ}
  → m < n
  → n < p
  --------
  → m < p

<-trans z<s (s<s n<p) = z<s
<-trans (s<s (m<n)) (s<s (n<p)) = s<s (<-trans (m<n) (n<p))

data _>_ : ℕ → ℕ → Set where
  n>m : ∀ {x y : ℕ}
        → x < y
        -----------
        → y > x

data Trichotomy (m n : ℕ) : Set where
  less :
    m < n
    --------
    → Trichotomy m n
  equal :
    m ≡ n
    --------
    → Trichotomy m n
  greater :
    m > n
    --------
    → Trichotomy m n

<-Trichotomy : ∀ (n m : ℕ) → Trichotomy n m
<-Trichotomy zero zero = equal refl
<-Trichotomy zero (suc m) = less (z<s)
<-Trichotomy (suc n) zero = greater (n>m (z<s))
<-Trichotomy (suc n) (suc m) with <-Trichotomy n m
...                             | less n<m = less (s<s n<m)
...                             | equal n≡m = equal (cong suc (n≡m))
...                             | greater (n>m m<n) = greater (n>m (s<s m<n))

+-mono¹-< : ∀ (m p q : ℕ)
  → p < q
  --------
  → m + p < m + q

+-mono¹-< zero p q p<q = p<q
+-mono¹-< (suc m) p q p<q = s<s (+-mono¹-< m p q p<q)

+-mono²-< : ∀ (m p q : ℕ)
  → p < q
  ----------
  → p + m < q + m
+-mono²-< m p q p<q rewrite +-comm p m | +-comm q m = +-mono¹-< m p q p<q

+-mono-< : ∀ (m n p q : ℕ)
  → m < n
  → p < q
  -------------
  → m + p < n + q
+-mono-< m n p q m<n p<q  =  <-trans (+-mono²-< p m n m<n) (+-mono¹-< n p q p<q)

≤-iff-< : ∀ {m n : ℕ}
  → suc m ≤ n
  ------------
  → m < n

≤-iff-< {zero} {suc n} (s≤s (m≤n)) = z<s
≤-iff-< {suc m} {suc n} (s≤s (m≤n)) = s<s (≤-iff-< {m} {n} m≤n)

<-iff-≤ : ∀ {m n : ℕ}
  → m < n
  ------------
  → suc m ≤ n

<-iff-≤ z<s = s≤s (z≤n)
<-iff-≤ (s<s (m<n)) = s≤s (<-iff-≤ m<n)

≤-n≤sn : ∀ (n : ℕ) → n ≤ suc n
≤-n≤sn zero = z≤n
≤-n≤sn (suc n) = s≤s (≤-n≤sn (n))

<-trans-revisited : ∀ {m n p : ℕ}
  → m < n
  → n < p
  ---------
  → m < p
<-trans-revisited z<s (s<s n<p) = z<s
<-trans-revisited {suc m} {suc n} {suc p} (s<s (m<n)) (s<s (n<p)) = s<s m<p
  where ssm≤p = ≤-trans (s≤s (<-iff-≤ m<n)) (<-iff-≤ n<p)
        sm≤p = ≤-trans (≤-n≤sn (suc m)) (ssm≤p)
        m<p = ≤-iff-< sm≤p

data even : ℕ → Set
data odd : ℕ → Set

data even where
  e-zero :
    -----------
    even zero

  e-suc : ∀ {n : ℕ}
    → odd n
    ---------
    → even (suc n)

data odd where

  o-suc : ∀ {n : ℕ}
    → even n
    ----------
    → odd (suc n)

e+e≡e : ∀ {m n : ℕ}
  → even m
  → even n
  --------------
  → even (m + n)

o+e≡o : ∀ {m n : ℕ}
 → odd m
 → even n
 ----------
 → odd (m + n)

e+e≡e {zero} {n} _ en = en
e+e≡e {suc m} {n} (e-suc om) en = e-suc (o+e≡o om en)

o+e≡o {m} {zero} om _ rewrite +-identity m = om
o+e≡o {suc m} {suc n} (o-suc em) (e-suc on) = o-suc (e+e≡e em (e-suc on))

o+o≡e : ∀ {m n : ℕ}
  → odd m
  → odd n
  ---------
  → even (m + n)

o+o≡e {suc m} {suc n} (o-suc em) (o-suc en) rewrite +-suc m n = e-suc (o-suc (e+e≡e em en))


data One : Bin → Set
data One where

  prim :
    ---------------
    One (x1 nil)

  ox0 : ∀ {b : Bin}
    → One b
    --------
    → One (x0 b)

  ox1 : ∀ {b : Bin}
    → One b
    --------
    → One (x1 b)

data Can : Bin → Set
data Can where

  zero :
    ---------
    Can nil

  one : ∀ {b : Bin}
    → One b
    ------------
    → Can b

inc-one : ∀ (b : Bin)
  → One b
  ------------
  → One (inc b)

inc-one nil ()
inc-one (x0 b) (ox0 ob) = ox1 ob
inc-one (x1 b) (ox1 ob) = ox0 (inc-one b ob)
inc-one _ prim = ox0 prim

inc-can : ∀ (b : Bin)
  → Can b
  --------
  → Can (inc b)

inc-can nil _ = one prim
inc-can (x0 b) (one ox0b) = one (inc-one (x0 b) ox0b)
inc-can (x1 b) (one ox1b) = one (inc-one (x1 b) ox1b)

can-to : ∀ (n : ℕ)
  -------------
  → Can (To n)

can-to 0 = zero
can-to (suc n) = inc-can (To n) (can-to n)

mul2-x0 : ∀ (n : ℕ)
  → 0 < n
  -------------
  → To (mul2 n) ≡ x0 (To n)

mul2-x0 0 ()
mul2-x0 (suc n) z<n = {!!}

one-predicate : ∀ (b : Bin)
  → One b
  ------------
  → To (From b) ≡ b

one-predicate nil ob = refl
one-predicate (x0 b) (ox0 ob) = {!!}
one-predicate (x1 b) prim     = refl
one-predicate (x1 b) (ox1 ob) = {!!}

-- can-reg : ∀ (b : Bin)
--   → Can b
--   -------------
--   → To (From b) ≡ b

-- can-reg nil _ = refl
-- can-reg (x0 b) cx0b = {!!}
-- can-reg (x1 b) cx1b = {!!}