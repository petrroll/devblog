---
layout: post
title:  "Deep learning notes 11: All is Kernels - but not those in ring0"
date:   2022-03-22 22:26:37 +0100
author: Petr Houška
categories: papers
#truncate: 3600
---  

> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

[Deep Networks Are Kernel Machines](https://www.youtube.com/watch?v=ahRPdiCop3E) 
- Deep learning success is attributed to automatic discovery of new data representation
- Paper's proposal: 
  - Deep learning training: stores training data
  - Deep learning inference: compares with stored data -> outputs closest -> ~kernel machine
  - -> Deep network weights ~ superposition of training examples
  - -> Network architecture incorporates knowledge of target function into kernel (similarity function)
- Kernel machine: `y = g ( sum_i: ai * K(x, xi) + b)`
  - `K`: similarity kernel function
  - `xi`: remembered training set 
  - `ai`: gold labels 
  - -> essentially global nearest neighbor classifier 
  - The biggest question is how to choose the Kernel function
- Gradient descent NN is equivalent to path-kernel Kernel machine
  - Two datapoints are similar if gradients of the (network) output w.r.t to weights are similar (similar - inner product)
  - Gradient of the (network) output w.r.t to weights: for particular input `xi`, how to change the weights to e.g. increase output
  - Classify a datapoint 
    - Retrace along all versions of the network (after each GD update)
    - Classify by whichever training datapoints had similar effect on the network (sensitivity) over the course of training
    - Get output of initial model and accumulate differences made by each GD step -> output of final
  - Proof datapoint `x`, its classification `y`, training datapoints `xi -> yi`, weights `wj`, loss `L`:
    - Change in output for `x` w.r.t to steps of GD: `dy/dt = sum_j..d dy/dwj * dwj/dt`
    - = `sum_j..d dy/dwj * (-dL/dwj)`
    - = `sum_j..d dy/dwj (-sum_i..m dL/dyi * dyi/dwj)`
    - = `-sum_i..m dL/dyi * sum_j..d dy/dwj * dyi*dwj`
    - = `-sum_i..m L'(yi, yi) K_f, w(t)(x, xi)`
    - => `y = y0 - Integral_t sum_i..m L'(yi, yi) K_f,w(t) (x, xi) dt`
    - …some normalization, … 
  - Notes: `ai`, `b` depends on `x,` also connects to boosting, generally another way of looking at DNNs

[Kernels!](https://www.youtube.com/watch?v=y_RjsDHl5Y4)
- Refresher on concepts:
  - Kernel functions: symmetric, positive semi-definitive ~ similarity measure
  - Kernel matrix (e.g. gram matrix): pairwise distances of all points in dataset
- Kernel: get kernel matrix without doing explicit feature map expansion on each datapoint and then dot product
  - E.g. using simple elementwise kernel function -> way cheaper (or even actually possible) to evaluate
- E.g.: Polynomial expansion with polynomial dimensionality `p` and datapoint dimensionality `d`:
  - Full expansion: each datapoint `d` expanded to `d*p` (could be worse, inf. for other kernels), then dot product on these 
  - Kernel method: immediately computes the same kernel matrix out of two raw `d`-dim inputs 
- Hilbert spaces: imagine vector spaces but with generalized base vectors (functions, polynomials, …)
  - Vector space needs to be linear and have scalar inner product
  - ~Space of functions where the point evaluation functional is linear and continuous 
  - When converging in the function space -> also converging in outputs
- Reproducing kernel, `F` set of functions `fi: E->C`, `F` is Hilbert space; `K: ExE->C` is reproducing kernel when:
  - `K(., t) € H`, `Vt€E`
  - `<fi, K(., t)> = fi(t)`, `Vt€E, Vfi € H` \| the value of `fi(t)` is reproduced by inner product of `fi` with `K(., t)`
  - [Reproducing Kernel Functions \| IntechOpen](https://www.intechopen.com/chapters/59898), [7.pdf (berkeley.edu)](https://people.eecs.berkeley.edu/~bartlett/courses/281b-sp08/7.pdf), [rkhs2.pdf (berkeley.edu)](https://people.eecs.berkeley.edu/~jordan/courses/281B-spring04/lectures/rkhs2.pdf), [optimization - Connection between SVM and Representer theorem - Cross Validated (stackexchange.com)](https://stats.stackexchange.com/questions/246255/connection-between-svm-and-representer-theorem), [functional analysis - Connection between Representer Theorem and Mercer's Theorem? - Mathematics Stack Exchange](https://math.stackexchange.com/questions/3535962/connection-between-representer-theorem-and-mercers-theorem)
  - Two reproducing kernels for two points -> equivalence between inner product of their reproducing kernels and its single evaluation
    - E.g.: `<k(.,x), k(.,x')> = k(x, x')` \| for `<f, g> = sum_i,j ai * bj * k(xi, xj)` \| `H = ( f(x) = sum_i..m ai * k(xi, x) )`
  - Every reproducing kernel induces unique reproducing-kernel Hilbert space, and vice versa
  - Every reproducing kernel is positive definite, and every positive definite kernel function defines unique reproducing kernel Hilbert space
- Kernel methods ~ soft nearest neighbor 
- Any matrix of inner products (style transfer, attention, …) can be exploited through kernel lens 
- Various ways of looking at things
  - SVM: Learn global separation planes 
  - DNN: Learn sequence of processing
- Ridge regression with kernels: RBF, …
  - Does regression in transformed space instead of original efficiently 
  - Seems to work good because regressing in those spaces seems to be good/better than original spaces
- Representor theorem: 
  - ~Optimal function `f*: x->y` can be represented as linear comb. on the kernel functions `k(x1, .)`, `k(x2, .)` of the dataset
  - `f*(.) = sum_1..n ai * k(., xi)` 
    - To get optimal `ai` coefficient: Take kernel products of our data (kernel matrix) & linear regression  
    - Across all training points: find combination of similarities with all others that produces lowest error to its output
  - Even assuming all possible datapoints, solution still lives in linear combination of only points from dataset
  - Kernel method allows us to do this effectively -> coefficient on datapoints (their kernels) instead of their feature(s\| maps)
    - Datapoints are the model 
- Usages:
  - Style transfer: gram matrix in style
  - Super-resolution: similarity patches 
- You could view DNN as implicit kernel method, indirectly also learns the similarity matrix 
