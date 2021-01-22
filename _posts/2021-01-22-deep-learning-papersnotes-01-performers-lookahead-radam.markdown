---
layout: post
title:  "Deep learning papers/notes 01: Performers, Lookahead, rADAM"
date:   2021-01-22 23:16:38 +0100
author: Petr Houška
categories: papers
#truncate: 3600
---	

> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

### Performers: Faster approximation of Transformers
- [Rethinking Attention with Performers (Paper Explained)](https://www.youtube.com/watch?v=xJrKIPwVwGM)
- Problem with attention `L`: number of tokens, `d`: dimensionality of `Q`, `K`, `V` -> `L^2` attention matrix
- Attention: `softmax(Queries * Keys^T) * Values` => `softmax(L,d * d,L) * L,d` => `softmax(L, L) * L,d`
- Solution -> factorize `softmax(Q * K^T)` => `Q' * K'^T` => `Q' * (K' * V)`
  - -> more efficient computation: `L,d * (d,L * L,d)` -> linear in `L`
- Factorization through positive Orthogonal Random features approach 
  - Potentially not only softmax, can be more generic

### Lookahead: Smart wrapper over any optimizer 
- [Lookahead Optimizer: k steps forward, 1 step back \| Michael Zhang](https://www.youtube.com/watch?v=TxGxiDK0Ccc)
- Wraps around any optimizer `O`
  - Creates weights checkpoint `c_i`, makes `n` steps with `O`
  - Interpolates between current state and (`n` steps of `O` ago) saved `c_i` -> `c_i+1`
- Intuitively: Tries `n` steps with arbitrary optimizer, then goes in the final location direction

### Rectified ADAM:
- [https://arxiv.org/pdf/1908.03265.pdf](https://arxiv.org/pdf/1908.03265.pdf)
- ADAM has large variance during warmup
- Solution: low initial learning rate, negligible momentum for first few batches

### Image transformer: Attend to image patches
- [An Image is Worth 16x16 Words: Transformers for Image Recognition at Scale (Paper Explained)](https://www.youtube.com/watch?v=TrdevFK_am4)
- Transformer on images -> too big attention matrix (n^2 for n pixels) 
  - -> cut into 16x16 patches -> attend to patches (way smaller number)
- Use linear embedding for individual patches - didn't work worse than embedding with CNN