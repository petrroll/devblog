---
layout: post
title:  "SWE notes 02: SIFT - detect features regardless of scale without DNNs"
date:   2022-04-30 23:53:40 +0200
author: Petr Houška
categories: swe
#truncate: 3600
---  

> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

### [SIFT: Scale invariant feature transform](https://www.youtube.com/watch?v=KgsHoJYJ4S8&list=PL2zRqk16wsdqXEMpHrc4Qnb5rA1Cylrhx&index=13)
- Interest point: 
  - Rich content (brightness and color variation, …)
  - Well defined representation for matching comparison with other points
  - Well defined position in the image
  - Scale, orientation, brightness, … invariant 
- What are good interest points?
  - Not edges -> not descriptive / unique enough
  - Corners only good for simpler images
  - "Blobls" actually relatively good: location, orientation, size & possible to assign signature
- Detecting blobs
  - Detecting edges: first/second derivative of gaussian convolution (removes noise)
    - Extrema locations correspond to position of a blobs (edges on either side)
    - The larger the extrema the more prominent blob 
  - Changing sigma (for the gaussian): changing detection scale (Detecting Blobs | SIFT Detector 6:20)
  - Try multiple sigmas -> create stack of feature maps, each corresponding of trying to find blobs at different scale
- Extracting interest points
  - Get stack of feature maps per blob scale
  - Compute differences of all two adjacent scale feature maps (smaller and bigger) 
  - Find extrema across all difference-featuremap featuremaps (3d max operator; 2d across space, 1d across scales)
  - Filter one only high extrema (threshold) 
  - -> SIFT interest points
- Scale invariance: 
  - We know the scale of interest points -> rescale them 
- Orientation invariance: 
  - For every pixel compute gradient (edge)
  - Look just at orientation (magnitude is about lightning), create histogram
  - Take principal (largest) orientation and use it to normalize location (rotate the patch through the orientation)
- SIFT descriptor
  - Create histogram per normalized (orientation, scaling) point of interest (usually divided into 4 subplots)
  - Distance between histograms can be normalized correlation / L2 / …
- Allows many applications: s.a. matching features from one picture to another picture (different scale/orientation, ...)