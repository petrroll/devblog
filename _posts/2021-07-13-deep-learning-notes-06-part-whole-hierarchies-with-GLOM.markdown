---
layout: post
title:  "Deep learning notes 06: Part-whole hierarchies with GLOM"
date:   2021-07-13 22:34:27 +0200
author: Petr Houška
categories: papers
#truncate: 3600
---  

> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

## [GLOM: How to represent part-whole hierarchies in a neural network](https://www.youtube.com/watch?v=cllFzkvrYmE)
- Idea paper, not an actual implementation 
  - How does fixed architecture parse various pictures into part/whole hierarchy that's different for each input
    - E.g. car is made of cabin, motor, …, cabin out of windows, doors, …
- Dynamic image parsing sort-of handled by capsule networks
  - First layer capsules represent/recognize lowest level features; capsule for window, door, …; second layer cabin, …
  - Door and window activates cabin capsule, …
  - ~discretization (active/nonactive) over implicit feature hierarchy of CNNs
- GLOM architecture: large number of same weights columns, one for each spatial location
- Each column is stack of spatially local autoencoders
  - Each vertically divided into multiple (~5) levels
  - Each level represents patch of image at different resolution/abstraction level
    - Cat's ear ->  furr, part of ear, cat's head, cat, ... ; neck -> furr, part of neck, cat's neck, cat
    - All locations of cat's ear will have similar second level activation, all locations in image similar last level activation
  - At each level the activation is embedding vector of that feature at that location ~ CNNs but differently implemented 
- Communication/inference is iterative
  - Between levels (layers) of each column through explicit neural networks
  - Between columns through attention mechanism 
  - Iterative approach/eventual consistency forces all locations of a feature to share 
- For layer `l`, location `x`, timestep  `t+1` embedding is: 
  - `e_t+1,l,x = e_t,l,x + f_td(e_t,l+1,x) f_bu(e_t,l-1,x)` + `<acrossLoc::below>`
    - Last timestep + through NN (`f_td`, `f_bu`) above and below level
    - NN functions (`f_td`, `f_bu`) weights shared for the same level of all locations
  - Positional encoding added to each input (similar to transformers) 
- Through message passing all locations for certain feature (e.g. Cat's ear locations) converge on ~appropriate level activation
  - Multiple locations sharing n-th level activation -> an island 
  - Following islands from topmost level to the bottom gives us parse hierarchy
    - The higher the bigger features -> the bigger islands; topmost: one island represents the whole image: class
- For across-location/cross columns information sharing: attention over the same level of all columns 
  - Attends not using keys/queries but similarity: Instead of `sm(QK^T)V` -> `sm(XX^T)X` 
  - -> attends within islands -> converges towards clustering -> similar vectors forced toward similar vectors
- Issue: on lower level similar things can share information even if they are in different parts of parse tree higher
  - Possible solution: Module attention based on closeness in higher levels of parse tree (higher levels of columns) as well 
  - ~the further the less influential: `sm(SUM_k=0..L-l  λ^k X_l+k * X_l+k^T)X`
- Iterative algorithm, eventual consensus -> embeddings also update -> doesn't  discover clusters but creates them 
- Designed decisions: 
  - Locations per patches (CNN) or even per pixel
  - Bottom-up network could look at nearby location but spatial locality could also be done only by the attention mechanism
- Training
  - Denoising autoencoder: reconstructing corrupted image (missing certain regions)
  - To encourage islands of new identity: regularizer based on contrast learning 
    - Crops from same image should agree, from different images disagree -> needs to be done on scene level not lower
- Represent coordinate transformations: it's not necessary to have explicit part-whole coordinate transformations
  - Better have it implicit in higher dimensional embedding than explicit in low level (can't model uncertainty) 
- For video: don't need to converge for each frame, can move in time within video during convergence 
  - I.e. Few iteration steps per each video frame, if changes not too rapid -> should still reach stable higher levels