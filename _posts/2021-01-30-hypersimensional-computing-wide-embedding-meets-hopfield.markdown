---
layout: post
title:  "Hypersimensional computing: wide embedding meets Hopfield"
date:   2021-01-30 21:13:11 +0100
author: Petr Houška
categories: papers
#truncate: 3600
---	

> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

- [2004.11204](https://arxiv.org/pdf/2004.11204.pdf), [Symbolic Representation and Learning With Hyperdimensional Computing](https://www.frontiersin.org/articles/10.3389/frobt.2020.00063/full)
- Main primitive - hypervector: ~10 000+ bits vectors (variations with integer/float vectors exist)
  - Information related to each object/concept represented in distributed manner across whole vector (equally significant bits)
  - Recombination of these vectors preserves information -> allows entities composition using well defined vector operations
  - Super wide bit embedding + composition operators with explicit similarity-like classification/Hopfield-like asociativity
- Benefits:
  - Wide representation brings robustness against noise 
  - Only three operators: addition (normal), multiplication (xor), permutation (actual permutation)
  - Very easily super-HW accelerated 
- Initial step: encoding to hypervectors - essentially embedding problem - very important for final accuracy
  - Goal pre-trained DNNs (e.g. initial layers of CNNs)
  - Random gram-based encoding;
    - Random level hypervectors are generated (e.g. per letter)
    - Rotationally permutated by their spatial location (e.g. position in n-gram)
    - Result for whole n-gram is binding (multiplication) all of these together, result for text is summation of n-grams
  - Random record-based encoding; e.g. for encoding speech using per time-bucket: 
    - Position hypervectors: generated orthogonal to each other 
    - Quantized level hypervectors: correlated based on distance (next higher level only portion of random bits flipped)
    - Result for whole speech clip is summation of all (position, level) pairs bound together (multiplication)
- Allows quantization, compression (cut & replace w. sum of short orth. vectors), adaptive tain. (~iterative update on missclass.)
- Procedure (e.g. image classification):
  - Training
    - Training images hashed (using pre-trained DNN) to binary representation, transformations are made
    - Aggregate per class to form hypervectors (e.g. consensus sum: most frequent bit at every pos. wins) 
    - Class hypervectors are stored in associative memory (e.g. Hopfield-like, explicit list) 
  - Inference: 
    - Hash input image, same transformations as during training
    - Query closest class hypervector (~KNN-like) and output most similar -> class with closest hypervector (distance metric)
    - Possible explicit small NN to transform outputs of similarity query (per class similarity) instead of argmax 
