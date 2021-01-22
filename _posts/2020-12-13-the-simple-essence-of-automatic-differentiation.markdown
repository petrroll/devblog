---
layout: post
title:  "The Simple Essence of Automatic Differentiation"
date:   2020-12-13 17:05:37 +0100
author: Petr Houška
categories: papers
truncate: 2540
---

> This post if from a series of notes written for personal usage while reading random ML/SWE/CS papers/lectures. The notes weren't originally intended for the eyes of other people and therefore might be incomprehensible and/or flat out wrong. These notes might be especially ish as my knowledge of both category theory and lambda calculus is relatively limited.

Relevant [Lecture](https://www.youtube.com/watch?v=ne99laPUxN4) and [slides](https://www.microsoft.com/en-us/research/uploads/prod/2018/07/The-Simple-Essence-of-Automatic-Differentiation-slides.pdf).

- Don't look at backprop in terms of graphs, treat it as algebraic composition over functions
	- Graphs can be good for visualization, but AD has nothing to do with graphs
	- Problem with graphs -> hard to deal with, trees easier but can be exp. big 
- Derivative of a function `f::(a->b)` at a certain point is a linear map` f'::(a-:b)`
	- Can't compose derivative operator: `D::(a->b)->(a->(a-:b))` 
		- When composed `D (g o f) a = D g (f a) o D f a` it also needs `f a` i.e. `b`
	- Solution: `D'::(a->b) -> (a->(b * (a-:b)))`, doesn't produce just derivative but `f(a) * f'::b * (a-:b)` 
		- Now for `D' (g o f)` we only need `(D' g) o (D' f)` -> easily composable
- Compile the composition to various categories: graph repres., functions composition, derivative, … 
	- Category: identity :: `a->a`, composition (`o`) :: `(b->c)->(a->b) -> (a->c)`
	- Cartesian category: notion of Cartesian multipl.: pairs (`*`), select left, select right
- Automatic differentiation 
	- Require D' to preserve Cartesian category structure -> solve ->  instantiation that gives us automatic diff. 
	- Derivatives of complex stuff happens "automatically" through composition of D'
	- Due to composition -> a lot of computation sharing -> efficient 
- Problem with sum types: not continuous, ?Church encoding
- Generally three ways of AD:
	- Numerical approximation: terrible performance and accuracy
	- Symbolic: ~to calculus at high-school
	- AD: Chain-rule based, …,  ~symbolic done by compiler
- Linear maps could be replaced with other conforming functions -> generalized AD
	- Useful when we need to extract data representation (gradient, …)
- Replace linear maps with matrices:
	- Enables efficient extraction of e.g. gradient without having to run base vectors matrix  (domainDim^2) through lin. map
	- Every composition is matrix multiplication -> associative -> impacts performance
		- Not easy to figure out the best association but depends only on dims -> types
		- If domain >> co-domain (e.g.: ML) reverse mode AD (all left) is usually best 
- Left associating composition 
	- Corresponds to backprop
	- CPS-like category: represent `a->b` by `(b->r) -> (a->r)` ~ continuation passing style
	- Given `f`, we'll interpret `f` as something that composes with `f`: `o f`
	- Results in left-composition (need to initialize with identity)
- Reverse mode AD: generalized AD category parametrized by continuation transform version of matrixes