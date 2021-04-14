---
layout: post
title:  "Deep learning notes 04: Perceivers and Branch specialization"
date:   2021-04-14 23:10:21 +0200
author: Petr Houška
categories: papers
#truncate: 3600
---  

> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

### [Perceiver: General Perception with Iterative Attention](https://www.youtube.com/watch?v=P_xeshTnPZg) ([arxiv](https://arxiv.org/abs/2103.03206))
- CNN: Locality exploited by sliding window 
- ViT: Divide picture into (local) patches, attend over them 
- Traditional: self-attention computation and memory `n^2` in the number of tokens (`|K|*|Q|`)
  - NLP: 1000s tokens
  - CV: ideally >> 50k pixels
- Originally NLP transformers: encoder (cross attention) & decoder (self attention)
  - Encoder on input: attends only to input tokens, same number of `keys`, `values` and `queries`
  - Decoder on output: attends to both input and output tokens, input only produces keys and values; not queries 
  - -> different amount of (`keys`, `values`) and (`queries`): computational requirements are not strictly quadratic
- Perceiver: split (`queries`) and (`keys`, `values`) for vision classification models
  - Stack of cross-attention (with input), and few self-attentions (mix, compute) repeated multiple times
  - Cross-attention: `queries` not based on input, but with arbitrarily smaller dimension `N*D` | `N is ~1000`
    - Dim of `N*M`: way smaller than `M^2`, only linearly on input -> allows video, not-patched images, sound, …
  - Self-attention: `queries` as well as `keys`, `values` based on cross-att.'s `queries` dim -> arbitrarily small
    - Dim of `N^2`: independent on input dimensions; uses output of prev. step for `values`, `keys`
- Multiple layers of this cross attentions, self-attentions stack 
  - Each cross-attention uses the same input image for calculating (using different weights) `keys`, `values` 
  - Weights for `keys`, `values` (from input), and queries can be shared across repeats -> essentially recurrent neural network
- Initial `queries` can be random or learned; queries in later layers are calculated based on earlier layer results
- Interpretation:
  - `Queries`: what we would want to know; represent channels
  - `Keys`: what each pixel represents/offers
- Fourier features for positional encoding, not learned 
- Results comparable to ResNet without any picture assumptions (apart from 2d positional encoding)
  - ~50 layers, number of parameters comparable to ResNet 
- Attention maps possibly static / dependent only on location instead of input content


### [Branch specialization](https://distill.pub/2020/circuits/branch-specialization/): Similar features cluster together
- When CNNs are branched into multiple sets of channels that don't allow cross-information sharing -> specialization
  - E.g. on initial portion of `AlexNet` (split into streams two due to GPU memory limits)
  - Features are not organized randomly as within a normal layer, but grouped/clustered for each branch
  - First group: Black and white Gabor filters, second group: low frequency color detectors
- Possible explanation:
  - First part of branch is incentivized to form features relevant to second part 
  - <=> 
  - Second part prefers features which the first half provides primitives for
- Inception (multiple parallel blocks) and residual networks (unroll parallelly) also feature separate sets of channels
  - Residual networks sidestep requirement to have a lot of parameters to mix values between branches
  - Bigger convolution (i.e. smaller branches) tend to be more specialized (e.g. 5x5 for Inception)
  - Inception happens even across multiple depths:
    - `mixed3a_5x5`: BW vs Color, brightness, …
    - `mixed3b_5x5`: curve related, boundary detectors, fur/eye/face detectors, …
    - `mixed4a_5x5`: complex 3D shapes/geometry 
    - -> Very unlikely to happen by chance e.g. for `mixed3a_5x5` ~ 1/10^8
- Specialization is consistent across architectures and tasks
  - The two groups on `Alexnet` no matter what you train it on (Places, …)
  - Specialized curvature group also common across architectures / datasets
- Hypothesis: Branching just surfaces structure that already exists
  - Test: weights between 1st and 2nd conv layers -> SVD -> singular vectors: frequency and colors
  - The largest dimension of variation in which neurons connect to which in the next layer
- Idea: parallels to neuroscience and brain region specialization