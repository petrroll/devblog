---
layout: post
title:  "SWE notes 01: Types as weather"
date:   2021-05-11 21:50:42 +0200
author: Petr Houška
categories: swe
#truncate: 3600
---  

> This post if from a series of quick notes written primarily for personal usage while reading random ML/SWE/CS papers. As such they might be incomprehensible and/or flat out wrong.

### [Types are like the Weather, Type Systems are like Weathermen - Matthias Felleisen](https://www.youtube.com/watch?v=XTl7Jn_kmio)
- Types are language of prediction by the programmer what the program will do
- Type systems check these prediction 

- Code is written for others to understand but also to be run on computers
- All developers think types while their create code (more or less precise, but still)
  - Capturing these thoughts in comments is problematic -> not checked -> become wrong
  - Types are checked automatically 
  
- Only type inference added to untyped language fundamentally doesn't work 
  - If things go wrong -> superhard to have reasonable error messages
- Instead add gradual typing system
  - Allow adding types incrementally throughout codebase
  - Idiomatic: just adding types, not changing code
  - Strive for reasonable error messages
- What should happen when part is types and there's error in untyped land
  - In typed racket: It tells user what happened on the typed/untyped boundary (through value proxies) 
  - Can also provide profiling info w.r.t to specific values
- Contracts are good but they are very much not free during runtime
  - Problem with higher order objects (lazy streams, first class functions, ...) -> need to allocate
  - Good for more complex checking hard to encode in types
- Idea: JITs could exploit dependent types (just like compilers exploit static types)
