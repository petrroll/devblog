---
layout: post
title:  "Gated linear networks"
date:   2020-06-22 22:16:03 +0200
author: Petr Houška
categories: papers
---

> This post if from a series of notes written for personal usage while reading random ML/SWE/CS papers. The notes weren't originally intended for the eyes of other people and therefore might be incomprehensible and/or flat out wrong.

Paper in question: [1910.01526](https://arxiv.org/abs/1910.01526)

- Series of linear filters (weights) on input with non-linearity at the end
	- Non-linearities are on each layer (neuron) but they cancel each other out
- Set of weights per each neuron
	- Specific  weight vector selected via context func. from input (side information)  
	- Each neuron different set of weights, different context function
	- Same side information for all neurons in all layers
	- Weights adjusted during training, only the one weight vector for current input
- Context function: 
	- Usually set of half-space functions (similarity with side inf)
	- Don't change during training, need to be sampled correctly
	- Similar data will (through context func.) force same weights for neurons -> sim. outputs
	- Unsimilar data won't use the same weights -> less forgetting 
- Each neuron is geometric mixture of outputs of previous layer (through weights)
	- Weights initialized randomly, updated via training

- Essentially a multilevel mixture of KNN and linear transformation with point non-lin.

	
	
	
	
	
