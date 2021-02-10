---
layout: post
title:  "Deep learning papers/notes 02: GPT3, data extraction, Dall-E"
date:   2021-02-10 20:27:29 +0100
author: Petr Houška
categories: papers
#truncate: 3600
---  

> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

### GPT-3
- [Language Models are Few-Shot Learners (Paper Explained)](https://www.youtube.com/watch?v=SY5PvZrJhLE&t=1s)
- Language model: model that generates continuation of text
- ~100 attention layers, ~100 heads, ~100 dimensionality, 3.2M batch size
- Not bidirectional, goes from left to right (autoregressive)
- Bert-approach:
  - Pretrain on general data: generic language model
  - Finetune (gradient updates) on specific task (e.g. Sentiment analysis)
- GPT-approach:
  - Zero shot: take pre-trained model, give it textual task description, prompt, expect output
  - GPT does one/few shot: give it few pairs of description, prompt and output
  - -> no gradient update on concete task
    - Just relies on absolutely huge training set that included these tasks somehow somewhere
- Language model is just trained to finish a text that looks as "description, prompt, answer, prompt, ...."
  - The output can be restricted to be out of a set of possible answers -> easier
- Closed book system
  - Good for trivia, not good for e.g. natural questions
- Hypothesis:
  - Large transformers are almost storing the training data
  - Inference: sort of fuzzy KNN/interpolation of training data with language model
  - Would be good to see what training examples were used for current output
    - ~index of what training samples influenced what weights 
- Not great performance on: 
  - Reading tasks (prompt contains text + question connected to it) that require reasoning 
  - Better for reading tasks where model selects more probable answer (out of 2): correlated
  - -> suggest interpolation hypothesis
- Very good language model, almost perfect grammar ~ fuzzy search
  - No tasks that would try to make poor English out of good, scramble words, …
  - A lot of presented tasks can be explained by being good English model
  
### Extracting Training Data from Large Language Models
- [Extracting Training Data from Large Language Models (Paper Explained)](https://www.youtube.com/watch?v=plK2WVdLTOY)
- GPT2/3
- Querying large black-box language model for data that appear only once/few times in training data
  - It's ok to remember good spelling, general info (e.g. correct zip codes, …), bad to remember specific datapoints
  - Eidetic memorialization: if string is extractable and appears k-times in training data (possibly many times in k docs)
- Not focused on targeted training data extraction but general "any rememebred data" 
- Intuition: easy to extract datapoints far from other datapoints 
  - Model can't extract patterns w.r.t to them -> remembers the datapoints exactly
  - For example GUIDs, random urls, random strings, … 
  - Does not mean all training data is extractible 
- Generate a lot of data, select highly likely outputs, deduplicate, manually check if on web few times
  - Data generation improvements: tweaks to priming and temprature to generate more diverse outputs
  - Selection improvements: train smaller model on similar (not same) datasets, take likely on targeted model but unlikely on new
    - Smaller new model is unlikely to remember the same few-shot datapoints
- Note: Distillation models: not all datapoints loose their performance equally
  - Assumption: Most affects rememebred single-training-datapoint examples
- Memorization is context specific: heavily depends on prompt
- Even if datapoint is only in one doc, it might need to be repeated multiple times in the doc to be remembered
  - Number of repeats required is higher with smaller models
  - Not clear relationship between documents, batches, ... 

### OpenAI DALL·E: Creating Images from Text
- [OpenAI DALL·E: Creating Images from Text (Blog Post Explained)](https://www.youtube.com/watch?v=j4xgkjWlfL4)
- Generating pictures out of textual description
- Idea: GPT-3 generates image tile hieroglyphs tokens, VQ-VAE's decoder uses them as latent repres. to create images
- GPT-3 like language model: 
  - One stream of tokens: first textual description tokens, then autocompletes/generates image tile hieroglyphs tokens 
  - Image tile hieroglyphs from vocabulary of VQ-VAE latent space codebook
  - Each tile token attends to only specific tile tokens (row, column, neighborhood) and all text tokens
- VQ-VAE 
  - Encoder: per image tile projects to latent space, selects closest vector (hieroglyph) from codebook
    - Pretrained as normal VAE, decoder possibly fine-tuned together with GPT-3 part
  - Decoder: creates image out of matrix of codebook latent vectors produced either by encoder (training) or GPT-3 (inference)
  - Codebook also trained w. encoder ~ essentially tile embedding to latent space, decoder ~ reverse embedding
- Blog mentions continuous relaxation of the codebook, no need for it to be explicit, not sure what it means
- 8192 Codebook vectors, trained; 32x32 tiles per image, image resolution 256x256
- Outputs 512 images, re-reranked with another text :: image matching model 
