---
layout: post
title:  "Deep learning notes 08: Fastformer - additive or static (self)attention?"
date:   2021-10-11 22:12:40 +0200
author: Petr Houška
categories: papers
#truncate: 3600
---  
> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

### [Fastformer - Additive attention can(not) be all you need](https://www.youtube.com/watch?v=qgUegkefocg)
- Modeling pairwise interaction between all pairs of tokens is expensive 
- Fastformer promises to use "additive attention" that's linear in complexity via tokens-global aggregation
- Presented in terms of `queries`, `keys`, `values` but could be just in terms of `n` (in this case 3) columns: `a`, `b`, …, `z`
- Computation goes sequentially, starts with computing the output of the second column, then third, …, last
  - For each column, create per-token input values, e.g. `a1`..`an`, `b1…bn`; the same way `q`,`k`,`v` are produced in transformer
  - For computing the per-token outputs of second column `Bi`, start with `Ai` = `ai` 
  - For each `Ai` value, produce `αi` weight via softmax after transformation with learned `wa`, `αi= exp(wa*Ai)/∑exp(wa*Aj)`
  - Produce global `A` as weighted average of `Ai`, `A = ∑ αi * Ai`
  - The output of column b is then pointwise multiplication, `Bi = bi x A`
  - In case there's column c, we aggregate `Bi` to a single `B`, pointwise multiply with `ci` to get `Ci`
- Still essentially quadratic `i=0..n`: `Bi = bi x A = bi x ∑ αi * Ai = ∑ bi x αi * Ai` 
  - Given there's no softmax -> global a can be computed first -> linear in computation
- The aggregation weights `αi` are essentially self-attention with per-column/layer static learned query `wa`
  - Also could be viewed as soft classification according to learned static separation boundary vector `wa`
- No information sharing between tokens apart from pointwise multiplication between global aggregate of prev. column
  - Not really a proper attention; sort-of static query self-attention in the aggregation step
  - It is statically learned what sort of tokens each layer/column should globally attend to; not dynamic per each token
  - Good for tasks with global information, e.g. topic classification 
- Seems to just be framed in terms of the words of attention mechanism
- In practice fast and with relatively good results on certain NLP tasks 