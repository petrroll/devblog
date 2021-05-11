---
layout: post
title:  "Deep learning notes 05: unsupervised vision with GLOM"
date:   2021-05-11 21:50:44 +0200
author: Petr Houška
categories: papers
#truncate: 3600
---	

> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

### [DINO: Emerging Properties in Self-Supervised Vision Transformers](https://www.youtube.com/watch?v=h3ij3F3cPIk)
- Unsupervised learning regime for vision (self attention, 8x8 patches) transformers
  - Intermediate representation clusters pictures of similar labels together (without seeing labels)
  - Capable of object detection and masking (attention mask segments objects very well)
  - Capable of classification (output KNN to known labeled examples)
  - Copy detection, image retrieval, … -> good similarity measure
- Attention masks for CLS token: the token that contains final representation (doesn't have image patch on input, to not bias)
- Self-supervised learning: self-distillation without labels
- Negative samples learning: 
  - Take anchor patch and patch A from one image, and patch B from second image
  - Give all three patches to the model, tell it which is anchor patch
  - Ask whether A or B is from the same as anchor 
- Self-supervised without negative samples learning
  - Use only one image, augment in multiple ways (BYOL) -> produce two versions for teacher and student
    - Global crops: > 50 % of the image
    - Local crops: < 50 % of the image
    - Rotations, color-jitters, ...
  - Pass each one version through teacher, one through student 
    - Note: Actually pass both through both, loss is combination of cross-difference
  - Loss is the difference between end image representations (CLS output)
    - Same image, only differently augmented -> should have similar representation
    - To mitigate collapse to single repre. -> different models for teacher and student
  - Only train (backprop) student, build teacher as exponential average of students 
- Teacher only uses global cropping
  - If student has local crop -> student learns that its patch should match the whole with more context
  - -> forces the model to learn part-whole relationship & representing the whole image
- Teacher maintains running average of all representations it sees -> subtracts it from its representation
  - ~normalization, helps against collapse 
- Representation has softmax with temperature at the end 
  - Dimensionality of softmax is arbitrary: don't have explicit labels (unsupervised) -> who knows how many
  - Teacher has sharpening -> more peaked distribution -> forcer larger differences between diff. outputs
  - Softmax is not common in unsupervised -> forces model to come up with "its own classes" 
- Versus supervised learning
  - Supervised has way more noisy / overfitted attention mask -> hyper optimization on the task at hand
- Why does it work?
  - Augmentations: in computer vision they're super important ~ that's where the human prior is
    - What's augmented away doesn't matter 
- Dataset: there's always an explicit object of interest -> how we take pictures brings prior