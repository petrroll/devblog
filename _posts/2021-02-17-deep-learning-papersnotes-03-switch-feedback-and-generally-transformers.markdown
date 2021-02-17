---
layout: post
title:  "Deep learning notes 03: Switch, Feedback, and generally transformers"
date:   2021-02-17 21:29:08 +0100
author: Petr Houška
categories: papers
#truncate: 3600
---  

> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

### Switch Transformers: Scaling to Trillion Parameter Models with Simple and Efficient Sparsity
- [Switch Transformers: Scaling to Trillion Parameter Models with Simple and Efficient Sparsity](https://www.youtube.com/watch?v=iAR8LkkMMIM)
- 1 trillion parameters (sparse) vs 175B parameters dense of GPT-3
- Mixture of experts, each token routed to only single expert per layer 
  - Few experts per machine, allows parallel execution: indiv. Token to different experts -> machines
- On large NLP test loss goes down with more parameters even with the same:
  - Training dataset, number of steps, FLOPs per forward pass (due to sparsity)
  - -> tradeoff distributable memory for training speed / performance (demonstrated on super-huge models)
- Transformer:
  - MHA: relates tokens within layer to each other
  - Feed forward layer (for all tokens): relates layers to each other
- Switching transformer: Multiple feed forward layers, each token uses one of them
  - Routing matrix, dot product with token -> softmax -> routing weight (soft) -> hard clip "argmax"
  - In forward pass -> only one FF "expert" is used per token
- Previously thought impossible to use just one "argmaxed" expert due to instability
  - Better initialization, adaptive precision (float16 on communication, float32 for within node computation), better dropout

### Transformers dimensionality via [Attention is all you need](https://papers.nips.cc/paper/2017/file/3f5ee243547dee91fbd053c1c4a845aa-Paper.pdf)
- Multiple dimensionalities:
  - Model dimension (`Dmodel`): initial embedding dimension, input/output of both attention and feed forward network layers
  - Value, key dimensions (`Dk`, `Dv`): dimensionality of individual keys (and thus queries) and values
  - Hidden FFN size (`Dff`): dimensionality of first out of two (second has dimensionality of `Dmodel`) layers of FFN
  - Heads (`H`): number of attention heads
  - Layers (`N`): number of attention, feed forward network stacks
- Network computation
  - `Dmodel` token vector projected per attention head to `Dk`, `Dk`, and `Dv` vectors for keys, queries, and values, attention happens
  - After attention finishes, concatenation of `Dv` outputs per attention head projected to `Dmodel`
  - `Dmodel` sized vector is projected through a single hidden layer (`Dff`) and then reprojected to `Dmodel` 
- `Dmodel`: `512`, `Dk`: `64`, `Dv`: `64`, `H`: `8`, `Dff`: `2048`, Bert is similar; more thorough description
  - Not insignificant portion of parameters is in FFN portion (`2048*512 * 2`) that recombines indiv. heads info

### Feedback Transformers: Addressing Some Limitations of Transformers with Feedback Memory
- [Feedback Transformers: Addressing Some Limitations of Transformers with Feedback Memory (Explained)](https://www.youtube.com/watch?v=zdb8MM94A5c)
- RNN: Data flows one step per time in shared hidden state
- Transformer: Data flows each token to all tokens on every layer
  - Each layer very limited ~linear parallel recombination 
  - Casual masking: Only let transformers see "previous" tokens (big in NLP)
- Normal transformer: only feed forward, can recombine left-previous-layer tokens
- Memory transformer: allow lateral (left same layer) and also feed-forward (left-upper) connections
  - Disables parallel training, need to compute left tokens fully first (even upper layers) to compute current
  - Representations of all layers of a token are combined (weighted sum) to a single per-token memory representation
  - Tokens to the right attend to individual left tokens' memory representations
- In a way attention over multiple-layer RNN (not super-new idea, attention originated in RNNs in similar way)
- It seems that connection from past-tokens top (highest layer) representation is responsible for most gains
