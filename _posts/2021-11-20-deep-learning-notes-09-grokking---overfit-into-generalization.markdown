---
layout: post
title:  "Deep learning notes 09: Grokking - overfit into generalization"
date:   2021-11-20 16:49:59 +0100
author: Petr Houška
categories: papers
#truncate: 3600
---  
> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

### [Grokking: Generalization beyond Overfitting on small algorithmic datasets](https://www.youtube.com/watch?v=dND-7llwrpw)
- Neural network suddenly generalizes way beyond the point of overfitting with proper regularization
  - Train accuracy rises with training steps, eventually NN overfits on training data, training continues…
  - After orders of magnitude more steps, the network suddenly generalizes and test accuracy shoots up as well
- Similar to the idea of double descent, just with training steps instead of number of parameters
- In DD - when trained to convergence the relationship between test accuracy and number of parameters
  - With higher capacity models test accuracy first increases as the model is becoming capable
  - Then it starts going down when the network is big enough to remember dataset -> overfitting
  - Increasing the number of parameters further leads to increase of accuracy again, surpassing previous best 
  - Interpretation: at some point there are enough parameters to nicely match all datapoints but smoothy (with proper regularization) 
- This paper dataset: variables + binary operation (e.g. polynomial operations) without any noise 
  - Dataset is a table of all pairs of variables + the result of the operation
  - The network predicts the result of the operation for specific variables (portion blanked for trained data)
  - Dataset is very specific & without noise, on real world issues the phenomena is hard to induce / see
- Multiple variables of the dataset
  - Size of the dataset
  - Complexity of the operation
  - Train dataset ratio 
- Training accuracy shoots to 100 % soon (10^2 steps), test accuracy to 100 % also but later (10^5)
  - The higher the train set ratio, the faster the snap on test accuracy happens
  - The easier the operation is (e.g. there are symmetries) the easier it happens
  - The bigger the dataset, the harder it is to induce the phenomena
- Weight decay seems to be very important to make the phenomena appear faster
  - ? Prefers simple solutions vs remembering whole dataset 
  - So many train steps that a good solution is eventually discovered & then preferred because ^^
  - Maybe weight decay is good-ish but not the best regularization 
- Visualization of the weights (t-SNE) shows structure that could be interpreted via the operation
