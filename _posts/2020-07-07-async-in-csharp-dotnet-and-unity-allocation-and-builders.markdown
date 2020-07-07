---
layout: post
title:  "Async in C#, .NET, and Unity: Allocation and state machine builders"
date:   2020-07-07 02:23:11 +0200
author: Petr Houška
categories: misc
truncate: 3600
---

While helping with [little something](https://twitter.com/OndraPaska/status/1280192030463995908) that uses Unity I came across the rabbit hole `async`/`await` support is in Unity. Historically Unity used `generators` (known as [coroutines](https://docs.unity3d.com/Manual/Coroutines.html) in Unity's world) to support async/multiple-frames-spanning computation. In 2017 they added initial support for `async`/`await` but without any meaningful libraries support and with potential performance pitfalls (hello GC, how are you?). To be fair, at that time async had performance implications even in mainland .NET (Core), mainly around allocations which - (un)fortunately aren't anywhere as problematic for (mostly) throughput oriented .NET Core apps as they can be for near-real-time applications like Unity games.

Luckily for .NET, with the release of .NET Core 2.1 in 2018 a lot of those [issues got solved](https://devblogs.microsoft.com/dotnet/async-valuetask-pooling-in-net-5/) and allocations were decreased substantially. But what was the change actually about? And how does it relate to Unity and/or 3rd party Unity focused `async`/`await` libraries such as [UniTask](https://github.com/Cysharp/UniTask) or [UnityAsync](https://github.com/muckSponge/UnityAsync)? Let's find out.

I'll assume some (relatively deep) knowledge about `async`/`await`. If you're not sure you have it, be sure to check this [awesome blog-post](https://devblogs.microsoft.com/premier-developer/dissecting-the-async-methods-in-c/) about the topic.

### State machine rewrite:

When you write an `async` method, [Roslyn](https://github.com/dotnet/roslyn) will rewrite it to a method that does following. As this rewrite is done by the compiler it will happen regardless of your runtime, be it full framework, .NET Core 2.1, or Unity. 

{:start="0"}
0. Compiler [synthesizes](https://sharplab.io/#v2:EYLgtghgzgLgpgJwDQBMQGoA+ABATARgFgAobABgAJt8BWAbhJOwGYrcKBhCgbxIv6qtsADioA2ADwBLAHYwAfBQCyACgCUPPgO3YAnOIB0ATSlwANinUNi2nfl0qARPkdrrtgXsMnzlt1o8A22wAdgp8dwEAXxIooA=) an `IAsyncStateMachine` struct containing the original implementation of the method cut into a state machine (as its `MoveNext(..)` method) and locals lifted as fields.
1. Compiler generated `IAsyncStateMachine` struct is initialized (`stateMachine`) with:
	- `This` pointer.
	- Parameters.
	- Newly initialized `XYZMethodBuilder` (`methodBuilder`) struct corresponding to the Task-like object that is being awaited.
2. The `methodBuilder` is retrieved out of the `stateMachine`.
3. `methodBuilder.Start(ref stateMachine)`.
	1. Runs the `stateMachine.MoveNext(..)`.
	2. Get `awaiter` out of the awaited expression.
	3. If completed synchronously -> `methodBuilder.setResult(..)`, done.
		- Allocates `methodBuilder.Task` if it doesn't exist already, sets its result ([^1]).
	4. If not completed -> `methodBuilder.AwaitUnsafeOnCompleted(ref awaiter, ref stateMachine)`
4. `return methodBuilder.Task`.
	- Allocates `methodBuilder.Task` if it doesn't exist already ([^1]).

Individual runtimes can then differ in that they do in the `methodBuilder.AwaitUnsafeOnCompleted(..)` method. The method that actually does the continuation registration and therefore where all the important bits happen.

### Old .NET Core, Unity, full framework:

The most allocate-y of the three I'm going to talk about is .NET prior to Core 2.1 and old Unity (honestly not sure how [much that's still the case](https://github.com/Demigiant/dotween/issues/387#issuecomment-608371554) by default).

When `methodBuilder.AwaitUnsafeOnCompleted(ref awaiter, ref stateMachine)` runs:
1. Allocates `this.Task` if it doesn't exist already.
2. Allocates `this.Runner` (`runner`) if it doesn't exist already, initializes it with:
	- Boxed version of `stateMachine` (that actually contains this `methodBuilder` as a field).
	- Delegate to `stateMachine.MoveNext(..)` proxy that lives on the `runner` (`cachedDelegate`).
	- Current execution context. 
3. Registers the `runner.cachedDelegate` on `awaiter.UnsafeOnCompleted(..)`.

Therefore several allocations happen:
1. The `stateMachine` is boxed to be stored in the `runner`.
2. Capturing execution context can/might allocate.
3. `cachedDelegate` needs to be allocated, it's tied to execution context so it might have to be re-allocated if it changes.
4. `Task` needs to be allocated.


### Modern .NET Core, (possibly?) Unity:

.NET Core 2.1 improves on this situation quite a bit:

Instead of `Task` a [special derived type](https://source.dot.net/#System.Private.CoreLib/AsyncTaskMethodBuilderT.cs,f8f35fd356112b30) `AsyncStateMachineBox` is used that enables substantially lower overhead with strongly typed `stateMachine` field.
1. Allocates `this.Task` as `AsyncStateMachineBox` if it doesn't exist already, initializes it with:
	- Strongly typed version of `stateMachine` (that actually contains this `methodBuilder` as a field) without boxing.
	- Immutable (it is in .NET Core) version of Execution context.
2. Special cases all awaiters it knows about and passes `stateMachine` directly without the need for delegate.
	- Optionally allocates one immutable delegate to `stateMachine.MoveNext(..)` if needed by an unknown awaiter.

Therefore we only allocate two things at worst and never re-allocate on multiple awaits within the same method. Quite a big improvement.

### UniTask:

UniTask, an `async`/`await` library for Unity, takes a [slightly different](https://medium.com/@neuecc/unitask-v2-zero-allocation-async-await-for-unity-with-asynchronous-linq-1aa9c96aa7dd) but goes even further.  

Instead of `Task` it uses `UniTask` which is a value type (similar to .NET's `ValueTask` I didn't have space to talk about). Instead of `Runner` it uses heavily pooled (rarely newly allocated) `RunnerPromise` with strongly typed `stateMachine` field.
1. Initializes `UniTask`  if it doesn't exist already with:
2. Gets `runnerPromise` (~`runner` in .NET) from object pool and initializes it with:
	- Strongly typed copy of the `stateMachine`.
3. Registers a [on-allocation-created](https://github.com/Cysharp/UniTask/blob/d6a056331933ca776799bb205475f4ea40493f08/src/UniTask/Assets/Plugins/UniTask/Runtime/CompilerServices/StateMachineRunner.cs#L63) delegate to `runnerPromise.Run()` that calls into `this.stateMachine.MoveNext(..)` on `awaiter.UnsafeOnCompleted(..)`. 

Thus, it can avoid all allocations in most situations. The delegate is allocated only once per lifetime of the `runnerPromise` and since those are pooled new ones are created rarely. The pooling brings some limitations in terms of robustness (can't await it twice, ...) but - after all - everything is a tradeoff in software engineering.

Big thanks to [these](https://medium.com/@neuecc/unitask-v2-zero-allocation-async-await-for-unity-with-asynchronous-linq-1aa9c96aa7dd) two [blog](https://devblogs.microsoft.com/dotnet/async-valuetask-pooling-in-net-5/) posts.

[^1]: Not synthesized by Roslyn but this will happen in the majority of implementations so I left it here.



	
	
	
	
	
