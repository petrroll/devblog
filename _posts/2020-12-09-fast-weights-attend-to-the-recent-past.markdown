---
layout: post
title:  "Fast weights: attend to the recent past"
date:   2020-12-09 23:22:16 +0100
author: Petr Houška
categories: papers
#truncate: 1900
---	

> This post if from a series of notes written for personal usage while reading random ML/SWE/CS papers. The notes weren't originally intended for the eyes of other people and therefore might be incomprehensible and/or flat out wrong.

Paper in question: [1610.06258](https://arxiv.org/abs/1610.06258). Relevant lectures [here](https://www.youtube.com/watch?v=Hd20zGKAdoI) and [here](https://syncedreview.com/2017/02/08/geoffrey-hinton-using-fast-weights-to-store-temporary-memories).

- Traditionally D/RNN have two types of memory:
	- Standard weights (W): long term memory of the whole dataset
	- Hidden state (h(t)): maintained by active neurons / directly storing activ., limited, very immediate
		- Remembered things heavily influence currently processed stuff, limited capacity
- New intermediate "fast weights" (A): weights/synapses but faster learning, rapid decay of temp. information
	- Higher capacity associative "network" that stores past hidden states (e.g. Hopfield network)
- New (hidden) state is a combination of traditional new RNN state and its repeated modulation with fast weights
	- Two steps: preliminary vector h\_0(t+1) = f(Wh(t) + Cx(t)) and s:1..S steps of inner loop with h\_S(t+1) == h(t+1)
	- h\_s+1(t+1) = f([Wh(t) + Cx(t)] + A(t)\*h\_s(t+1)) | […] is the same for all s:1…S, preliminary vector without non-lin.
		- Multiple steps s allow the new state to settle
	- Fast weights A(t+1) updated with h(t+1) at the end of timestamp e.g. using Hopfield rule + heavy decay
	- Backprop can go (even) through fast weights  (doesn't update them) -> network learns to work it them
- Problem with minibatches: different fast weights for each sequence in a batch -> expl. attention over past hidden states
	- Unclear details how that solves minibatch problem but less comp. intensive: k\*n vs n^2
	- A(t)\*h\_s(t+1) ~= sum\_i=1..t λ^(t-i) h(i)\*\<h(i),h\_s(t+1)\> 
	- Non-parametrized attention with strength ~  scalar product between the past state and current hidden state
- Notes:
	- Interpretation: Attracts each new state towards recent hidden states
	- Benefit: frees hidden state to learn good representation for final classification
    - Needs fast weights output layer normalization 

