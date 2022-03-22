---
layout: post
title:  "Deep learning notes 10: Diffusion models - noise to nice in few steps"
date:   2022-02-20 23:10:35 +0100
author: Petr Houška
categories: papers
#truncate: 3600
---  
> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

### [DDPM - Diffusion Models Beat GANs on Image Synthesis](https://www.youtube.com/watch?v=W-O7AZNzbzQ)
- Input + sampled little bit of noise; repeated multiple times (~1000s) -> pure noise
  - `x_0 = x`; `noise(x_t+1|x_t)`; process input image from data distr.: `x`, applied `noise(…)` multiple times -> image of noise 
- If we could invert this process -> generative model: random normal noise image -> original image
  - Learn to undo one "little bit of noise" step at a time: distribution `noise(x_t-1|x_t)`
  - Sample random noise image, undo noise 1000s times (each time get one step cleaner image) -> sample clean data distr.
  - Reversal gives us process of normal noise to data distribution
- Noising up: `q`: `noise(x_t+1|x_t)` well-defined process of adding noise from Normal distribution
  - Each step depends only on output of previous step
  - Added noise has diagonal covariance matrix, is centered at last sample but down-scaled 
  - Given large `T` and well behaved schedule, last step is nearly isotropic Gaussian distribution
  - Produces vast amount of data pairs of `x_t-1`, `x_t`
- Denoising: `p`: `noise(x_t-1|x_t)` requires entire data distribution -> approximated via neural network 
  - Reversal doesn't predict single image but a whole distribution of images (that could've been previous step)
  - The output distribution is assumed to be gaussian (mean, covariance)
  - The gaussian distribution assumption is maintained for small noise-up steps
- Combination of `p` and `q` is ~VAE (variational auto-encoder) -> just train it
  - The true distribution can be easily computed out of the both known training pairs
  - Loss forces the denoising network predicted distribution to be close do the true distribution 
- The predicted covariance can be either statically set (actually doesn't work super-bad) or also predicted
  - If fixed: can be fixed based on the forward noise-up step parameters 
- Combination of two loss functions are used, for stability also resampled (early noise-up steps are more impactful)
  - Simple objective: L2 difference between true and predicted picture / noise
  - Variational loss: proper KL divergence VAE loss, including variance, … 
- Class-label guided generation can improve performance
  - Train class classifier not only for clean images, but also for noised images -> use them to steer the generation
  - Analogous to ~GANs; ~shifts the predicted distribution of the step-denoised-images to where specified label is likelier
- Idea: Have GANs that have multiple discriminators along the path from noise to final image ~ merge these two approaches


### [Autoregressive Diffusion Models](https://www.youtube.com/watch?v=2h4tRsQzipQ)
- New type of auto-regressive models: variables can be decoded in arbitrary order
- Autoregressive models: produces tokens (words/patches/pixels) one after another
  - E.g. First word, based on priming with it a second word, based on first two a third, …
  - Usually a fixed order, for sentences starts with a first one, …
  - Repeat until the whole output has been generated
- ARDMs: Don't have to go first to last, order could be arbitrary
  - Can also produce multiple tokens at once reducing number of steps for lower accuracy
- At the beginning all tokens are initialized (?randomly/zero?)
  - DNN (usually transformer) processes them -> per token output (e.g. distribution over categories)
  - A portion of them are sampled and decoded (argmax for categorization) -> concrete outputs for few tokens
  - Concrete outputs replace random inputs for the sampled tokens, DNN, new subset of tokens are decoded, …
  - Repeat until all tokens are sampled & set
- ~Similar to BERT
  - Trained with random word within sentence masking -> predicts distribution over words for masked tokens
  - Training is similar to BERT, just with non-fixed blanked tokens ratio
- During training: mask a portion of tokens, average losses for all at once
  - Sampling one timestep of one ordering where we decode & loss all of the remaining/maked tokens
  - Left to right allows taking only the next (one) tokens's loss -> less noisy
- Why can't we sample all tokens at once?
  - Tokens aren't independent -> argmax on one token (collapsing its distribution) influences other tokens' disr.
  - Sampling multiple at once is faster (less steps necessary) but possibly less ideal outputs
- Extensions:
  - Tokens could be re-sampled
  - Multiple pixels at a time can be sampled -> to get the order/token groups dynamic programming 
- Initially sample only more rough values (e.g. out of few colors), only later revisit & predict specific color