---
layout: post
title:  "Asserts with custom messages in Burst Unity"
date:   2020-07-09 10:43:26 +0200
author: Petr Houška
categories: misc
truncate: 3100
---
While helping with [little something](https://twitter.com/OndraPaska/status/1280192030463995908) that uses Unity I came across another interesting thing. If you try to use normal `UnityEngine.Assertions.*` in your [Burst jobs](https://docs.unity3d.com/Packages/com.unity.burst@1.3/manual/index.html) you'll find out they're (as of Burst `1.3.3` and Unity `2020.1.0b9`) being silently optimized away and are not checked, not even in debug Builds. 

A quick google search for `unity burst assert` will yield you [this amazing blog-post](https://jacksondunstan.com/articles/5292) about making your own asserts that work well with Burst. I encourage everyone to read it. Unfortunately, there's one small deficiency with the code suggested, it doesn't allow custom assertion-failed messages.  

### No log message:

~~~ csharp
using System;
using UnityEngine;
using Unity.Collections;

static class BurstAssert
{
    // based on: https://jacksondunstan.com/articles/5292
    public static void IsTrue(bool condition)
    {
        #if UNITY_ASSERTIONS
        if (!condition)
        {
            throw new Exception("Assertion failed");
        }
        #endif
    }
}
~~~

### What doesn't work:

While it [is possible](https://docs.unity3d.com/Packages/com.unity.burst@1.3/manual/index.html#language-support) to instantiate and throw an `Exception` with a custom message directly from a burst'ed method (see the `"Assertion failed"` message), you can't pass a managed `string` to a method, even if it is only used as an argument for a newly created and immediately thrown `Exception`.

~~~ csharp
public static void IsTrue(bool truth, string message = "") // Burst error BC1033: Loading a managed string literal is not supported.
{
	...
    if (!condition)
    {
        throw new Exception(string.Format(message));
	...
}
~~~

 Luckily Burst comes with a non-managed counterpart to strings, `FixedStringXZY` that work well as an argument within burst'ed methods. The simplest approach of using it directly doesn't work, however, because Unity (as far as I know) doesn't provide any `Exception` that would accept `FixedStringXZY` so we can't just do following.

~~~ csharp
public static void IsTrue(bool truth, in FixedString128 message)
{
	...
    if (!condition)
    {
        throw new Exception(message);	// Doesn't compile.
	...
}
~~~

Despite the fact that [the docs don't mention](https://docs.unity3d.com/Packages/com.unity.burst@1.3/manual/index.html#language-support) it being possible explicitly, one might want to try to circumvent this problem through string interpolation. 

~~~ csharp
throw new Exception($"{message}"); // the same as `string.Format("{0}", message)`
~~~

And if you try it once it will (most probably) work, at least in Editor. But it won't work the second time, and anytime after that. I suspect the interpolation for `FixedStringXYZ` simply doesn't work with Burst but the first time it is run as normal Unity code while the Burst JITs the method. But to be perfectly honest, I didn't look into it much.

### What finally works:

Since going purely with `Exception` won't work we'll have to use another logging method for our custom message. The simplest approach is to just use Unity's `Debug.LogError(...)` that [is guaranteed](https://docs.unity3d.com/Packages/com.unity.burst@1.3/manual/index.html#language-support) to work with `FixedStringXZY` from burst'ed methods.

> Be sure you're not on `Burst 1.3.3` (e.g. `Burst 1.3.2` works fine). It [disables](https://docs.unity3d.com/Packages/com.unity.burst@1.3/changelog/CHANGELOG.html#known-issues) `Debug.XZY` calls through silently optimizing them away and you might spend few hours looking at IL, LLVM IRs, and assembly trying to figure out why the first run logs properly (probably the same reason as above) but the subsequent don't.

~~~ csharp
using Unity.Collections;
using System;
using UnityEngine;

static class BurstAssert
{
    // based on: https://jacksondunstan.com/articles/5292
    public static void IsTrue(bool condition, in FixedString128 message)
    {
        #if UNITY_ASSERTIONS
        if (!condition)
        {
            Debug.LogError(message);
            throw new Exception("Assertion failed");
        }
        #endif
    }
}
~~~

This solution has a downside in producing two entries in Console, one for generic `Exception("Assertion failed")`, second for the custom Log message but since this is for errors only it shouldn't be all that big of a problem. And having `Debug.Log(..)` there is useful since unlike exceptions it contains the information about its precise code location.
