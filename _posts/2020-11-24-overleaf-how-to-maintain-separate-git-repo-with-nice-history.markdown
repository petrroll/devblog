---
layout: post
title:  "Overleaf: how to maintain separate git repo with nice history"
date:   2020-11-24 17:17:09 +0100
author: Petr Houška
categories: misc
truncate: 1880
---	

Overleaf is an awesome online editor for LaTeX. It comes with [git integration](https://www.overleaf.com/learn/how-to/Using_Git_and_GitHub) where your project serves as a git repository. You can pull updates made online to your local repo and also create new commits locally and push them to overleaf, where they immediately appear. Unfortunately, there are two limitations. 

- Only one branch - `master`, that cannot be force pushed to.
- Changes made through the online editor are automatically committed at relatively random intervals with static message `Update on Overleaf.`.

A consequence of that is that changes made online result in series of commits with non-destriptive messages that are relatively arbitrarily portioned. While that's perfectly fine from a usability standpoint, it just doesn't work for the pedants among us who want to have nice[^1] history[^2]. Luckily, there's an easy way to maintain a separate repo with a perfectly nice history and keep it in sync with overleaf both ways.

You can have a separate local branch `ol` that tracks overleaf's `master`, only make commits on that branch, and then cherry-pick all its new commits (both created locally and pushed to overleaf and pulled from overleaf) to your local `master`, where you can change its history as you see fit.

0. Have local repo with the same content as is on your overleaf project. Depending on what you already have either:
    - Download overleaf content and initialize a new repo with it.
    - Create a new overleaf project and upload all local files.
1. Add the `overleaf` repository as additional remote for your local repo.
    - `git remote add overleaf <link from Menu/Sync/Git>`
2. Create local `ol` branch that tracks `overleaf`'s `master`.
    - `git branch --track ol overleaf/master`
3. (Optionally): Update `ol` branch with new commits and push them to overleaf.
    - `git checkout ol`
    - `vim XYZ`
    - `git add . && git commit -m "Update"`
    - `git push overleaf HEAD:master # You need to specify HEAD:master because the remote's branch has different name.` 
4. (Optionally): Make changes on Overleaf.com and pull those locally on `ol` branch.
    - `git checkout ol`
    - `git pull`
5. Cherry pick all updates from `ol` (either made locally and pushed or online and pulled) to local `master`.
    - `git checkout master`
    - `git cherry-pick <commit-from>..<commit-to> # The range of commits transferred is in the first line of git pull/push output e.g.: bb22cee..fb4a3df.`
6. Rewrite the `cherry-pick`-ed commits on `master` with commits of your choosing. Alternatively, replace this step with [interactive rebase](https://git-scm.com/book/en/v2/Git-Tools-Rewriting-History).
    - `git reset <oldest-cherry-picked-commit>~1 # Resets just before the first cherry-picked commit. Use the hash reported by cherry-pick on master, not by pull/push on ol (otherwise it resets to commit in master (different hash) -> merge).`
    - `git add . && git commit -m "My nice commit msg"`
7. Push local `master` to `origin` (or any other remote) with its perfectly tidy git log.


[^2]: At least on some projects.
[^1]: I'm not saying a useful one, just a nice one.
