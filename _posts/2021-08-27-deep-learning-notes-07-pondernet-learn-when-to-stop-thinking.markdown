---
layout: post
title:  "Deep learning notes 07: PonderNet - Learn when to stop thinking"
date:   2021-08-27 21:49:51 +0200
author: Petr Houška
categories: papers
#truncate: 3600
---  

> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

### [PonderNet - Learn when to stop thinking](https://www.youtube.com/watch?v=nQDZmf2Yb9k)
- Recurrent(ly run) network that can decide when to stop computation 
- In standard NN the amount of computation grows with size of input/output and/or is static; not with problem complexity
- End-to-end trained to compromise between: computation cost (# of steps), training prediction accuracy, and generalization
  - Halting node: predicts probability of halting on conditional of not halting before
  - The rest of the network can be any architecture (rnn, cnn, transformer, ..., capsule network, ...)
- Input `x`; `x` processed to hidden state `h_i`; processed via `s(...)` function; `(h_i+1, y_i, λ_i) = s(h_i)`
  - Each steps returns next hidden state (`h_i+1`), output (`y_i`), and probability of stopping (`λ_i`)
  - Probability to stop at step n: `p_n = λ_n * TT_1..n-1 (1- λ_i)`
- At inference `λ` is used probabilistically (i.e. the probability is sampled)
- Training loop:
  - Input `x` into encoder, get `h_0`, ... unroll the network for n steps regardless of `λ`
  - Consider all outputs at the same time; `loss = p_1*L(y_1)+p_2*L(y_2)+...+p_n*L(y_n)`
  - -> Possibly unstable -> two goals: make `y_i` better or make `p_i` smaller
  - Regularization for `KL(p_i || geometricDistirbution(λp))` -> forces lambdas to be similar to hyperparameter
- Contrast vs ACT: 
  - Considers the output a weighted average of outputs: `loss = L(p_1 * y_1 + ... + p_n * y_n)`
  - Early results need to be compatible with later results
  - Less dynamic; needs more steps in experiments, worse in extrapolation
  - Pondernet correctly needs more steps for more complex problems
  
