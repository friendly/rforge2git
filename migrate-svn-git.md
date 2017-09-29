---
title: "Migrating svn/R-Forge packages to git/Github"
author: Michael Friendly and Phil Chalmers
date: Sept. 25, 2017
output:
  github_document:
    toc: true
    toc_depth: 2
---




> Migration \Mi*gra"tion\, n. [L. _migratio_: cf. F. _migration_]

> 1: The movement of persons or groups from one country or locality to another.   
> 2: The passage of software developers from one platform, language or environment to another for the purpose of feeding, breeding or enhanced health of their offspring.

Context
-------

I have ~ 16 R packages I maintain or contribute to.  I have a Ubuntu Linux workstation
and several Windows machines, but for R work and package development, I mostly use
Windows, because most things work more easily there.

In the past, I've maintained
the repositories for these on [R-Forge](https://r-forge.r-project.org/), and used the [eclipse](http://www.eclipse.org/) / [StatET](http://www.walware.de/goto/statet) IDE for development,
testing, and submission of new versions to CRAN directly from R-Forge.  This has generally worked fairly well,
but I've come to want to switch to using git for version control and Github for my
package repositories.  As well, [RStudio](http://www.rstudio.com/) offers an
increasingly attractive IDE for R package development, and I've been using
RStudio more and more.

Why do this?  It violates the Lazy Developer's Golden Rule: "If it ain't broke, don't fix it" (phrase attributed to [Bert Lance](http://en.wikipedia.org/wiki/Bert_Lance) in a different setting)  Well, R-Forge does have some advantages:

* In theory, it automatically builds and checks R packages on Linux and Windows platforms, and for the both the current and devel releases.
* It provides a _Submit to CRAN_ link on the R packages page for each project, but that
doesn't appear if the package failed R CMD check.
* Each package automatically gets a `pkg/` directory as well as a `www/` directory, in case you want to also maintain a parallel set of web pages related to a package.
I haven't used this much, but it was useful for the `Lahman` package, whose
R-Forge pages are at http://lahman.r-forge.r-project.org/.

However, I've found that package building and checking on R-Forge is often extremely
slow (one day or more) and the checking for the devel releases has been disabled for some time.  R-Forge also offers some tools for collaborative work (but only for project members), an email list, bug-tracking, but these have seemed (to me) quite hard to use.

git/Github on the other hand (particularly with RStudio), offers the following significant advantages:

* git (once you understand how it works) is a far better tool for version management
and collaborative work
* much easier collaboration with other users and developers:  people can edit your code
or documentation and easily create a pull request that you can view and act on, and inline discussions
about pull requests can be initiated in case the maintainer is not happy with proposed pull request
* Hadley Wickham's [devtools](https://github.com/hadley/devtools) package makes it extremely simple to develop and test R packages within R itself and it is tuned to
Github.
* Github provides related wiki and gh-pages sites, graphical history of repositories and contributors, as well as providing gist's for creating coding examples that are not necessarily package related
* Github repositories may be treated as public or private, depending on the purpose (R packages are generally public given that R and its extensions are open-source). 
Therefore, repositories do not have to be restricted to just R packages, and may include other scripting languages and documents
* feature requests and bug tracking are user friendly and also integrate directly with the git work-flow (e.g., using `git commit -a -m
'closes issue #24'` will automatically close the respective issue #24, and send an email
to the proposer)
* integration with open source testing machines such as [travis-ci](https://travis-ci.org) allow the execution of user defined shell and make files. These
are useful for checking R packages with multiple R versions (including the latest development), and executing internal tests that are defined with the
[testthat](https://github.com/hadley/testthat) or [testit](https://github.com/yihui/testit) packages
* ... more features ???

How to migrate?
---------------

I posted a query to R-Help, and Yihui Xie replied:

> In the past Github allows one to import from an existing SVN
> repository automatically via its web interface, but I just checked it
> and it seems to have gone. What is left is:
> https://help.github.com/articles/importing-from-subversion . Perhaps it
> is best for you to do the conversion under Linux and then work under
> Windows.

This document suggests using [svn2git](https://github.com/nirvdrum/svn2git), 
a ruby package that is a wrapper for `git svn`.  Unfortunately, I could
never get this to work for me with R-Forge projects.  I got errors
no matter what options I tried.  Instead, I ended up using 
`git svn` directly, which was designed to provide
bidirectional operation between a Subversion repository (e.g., R-Forge) and git
(e.g., a local git-based repository)

This means that I did the migration on my Ubuntu Linux machine, first installing
the `git-svn` package, which is an add-on for `git`.
```
sudo aptitude install git-svn
```

Then, the plan for migrating one R package from SVN/R-Forge to git/Github consists
of the following steps:

1. Create an empty Github project for the package.  Github suggests to create a `README.md` file for the package, so it can be cloned locally from Github.  
But **don't do this now**, because it will create problems when you first try to push your
converted git repo to Github: it will be considered non-fast-forward, since there is content
on Github not in your local repo.
2. Use `git svn clone` to copy the existing SVN repository with its history to a local
git repo on Linux.
3. Fix up the directory structure to accord with Github conventions, as described in the
section *Repository directory structures*.
4. Setup git to track the remote Github repository using `git add remote`.
5. Push the local repository to Github using `git push -u origin master`

At this point, I can setup eclipse/StatET or RStudio to work with the new
Github repository, and abandon further work on the R-Forge repository ---
but only if no one working on the package project updates the R-Forge
repo.

### Initial migration from R-Forge to git

The general form to use with `git svn clone` is
```
git svn clone svn+ssh://developername@svn.r-forge.r-project.org/svnroot/packagename/pkg/
```
By default, this will import *all* revisions in the history of the project,
and may take a long time.  If you don't want this, you can use the `-r` option,
e.g.,
```
git svn clone -r 100:HEAD svn+ssh://developername@svn.r-forge.r-project.org/svnroot/packagename/pkg/
```
to include only the revisions from rev. 100 forward. But then you will not be able
to use `git blame` to find out when an earlier problem was introduced, and you should
probably also use
```
git svn rebase
```
to update the local repository to HEAD.

Here is an example of using `git svn clone` for one package, `tableplot`.
For testing purposes, I did this in `tmp/`, first creating a folder,
```
euclid: /tmp % mkdir tableplot
euclid: /tmp % cd tableplot
```
Then run `git svn clone`, making sure to use the URL pointing to the `pkg/` folder
of the R-Forge project.


```
euclid: /tmp/tableplot % git svn clone svn+ssh://friendly@svn.r-forge.r-project.org/svnroot/tableplot/pkg/
Initialized empty Git repository in /tmp/tableplot/pkg/.git/
friendly@svn.r-forge.r-project.org's password: 
r1 = 3612d5bd4d900f0a8a23527f31fcfd3b885b61c9 (refs/remotes/git-svn)
        A       R/utility.R
        A       R/cellgram.R
        A       R/tableplot.R
        A       R/make.specs.R
        A       R/make.specs0.R
        A       DESCRIPTION
        A       data/NEO.n.RData
...
r13 = ba56a0a752e151ac4de56e9f5cfc0bb5fb3fe93f (refs/remotes/git-svn)
        A       .Rbuildignore
        M       DESCRIPTION
        M       man/tableplot-package.Rd
r14 = a57ed845d62270b2ff0f9bd619bab02bf68d4cd0 (refs/remotes/git-svn)
Checked out HEAD:
  svn+ssh://friendly@svn.r-forge.r-project.org/svnroot/tableplot/pkg r14

euclid: /tmp/tableplot % ls -la
total 24
drwxr-xr-x  4 friendly staff  4096 Oct 28 22:23 .
drwxrwxrwt 17 root     root  12288 Oct 28 22:17 ..
drwxr-xr-x  8 friendly staff  4096 Oct 28 22:23 pkg
```

Note that the package is now in `/tmp/tableplot/pkg/`.  I'll fix that up as described
below, then move the package to my `~/R/projects` tree for subsequent work.

### Repository directory structures


In migrating from svn/R-Forge to git/gihub, it is important to
consider the differences in directory structure in the remote repositories
and the implications this has for how you refer to them using 
references to their locations using svn or git, and when setting them
up in IDEs like eclipse/StatET or RStudio.

When a new project is created on R-Forge, the following (initially empty) directory structure is created at the project root:

```
pkg/
www/
README
```
where `pkg/` is to be filled with the normal content of an R package, e.g.,

```
pkg/
  data/
  demo/
  inst/
  man/
  R/
  DESCRIPTION
  NAMESPACE
```

In normal operation, when I checkout a new R package project in eclipse / StatET,
I use `File -> Import... -> SVN -> Checkout projects from SVN -> Create a new repository
location` and then give the URL in one of the following forms
```
svn://svn.r-forge.r-project.org/svnroot/package/
svn+ssh://friendly@svn.r-forge.r-project.org/svnroot/package/
```
where the first form is for anonymous access and the second for developer access
using SSH with password or other authentication. One **key thing** here is that
eclipse looks at the folder structure and offers the choice to checkout either the
root structure (`/`) or `pkg/` (or `www/`). I generally checkout **only** the `pkg/` folder,
so that `R CMD` tools work at this level.

On Github, on the other hand, R packages do not have that outer structure, and simply look
like the contents of an ordinary package:
```
data/
demo/
inst/
man/
R/
DESCRIPTION
NAMESPACE
```

This means that to migrate from SVN/R-Forge to git/Github, it is necessary to 
convert **only** the `pkg/` directory, but then adjust that using git to move
the contents **up one level** (removing the `pkg/` folder).  That is,
after migrating from svn to git as described below, execute

```
% git mv pkg/* pkg/.[a-zA-Z]* .
% rmdir pkg/
```
Note that `mv pkg/* .` alone won't move 'dot' files like `pkg/.Rbuildignore`
and `mv pkg/.* .`  will complain about wanting to `mv pkg/..` to the current
directory.

Then, create an empty `README.md` file, and  update the local repo with git:
```
touch README.md
git add --all
git commit -m `fixup initial migration from svn'
```


### Connect to Github and push 

Once the local repository is in shape, you need to tell git to track
and sync with the Github repository.  `git remote add` sets up the
remote Github repository to be tracked.  The form of the URL can be
in HTTPS form, i.e., 
`https://github.com/friendly/tableplot.git`
or SSH form,
`git@github.com:friendly/tableplot.git`.

In the `package` directory, the commands take the following form for me:
```
git remote add origin git@github.com/friendly/package.git
git push -u origin master
```

Now, point your browser to the Github repo, e.g.,
`https://github.com/friendly/tableplot`, to see what is there.  At this
point, you will probably want to create/edit the `.gitignore` file
to exclude any files in the local repo you don't want under git control
(e.g., `.Rhistory`, etc.) and create/edit the `README.md` file for
the package page on Github.

### Problems with git

You can run into problems with `git` on the initialization of your local repo
if the repo on Github has content not in your local repo, for example
a `README.md` or `.gitignore` that was added when the repo on Github was created.
This will prevent the `git push -u origin master` from working. It looks like this:

```
euclid: Rgit/vcdextra % git push -u origin master
To git@github.com:friendly/vcdExtra.git
 ! [rejected]        master -> master (non-fast-forward)
error: failed to push some refs to 'git@github.com:friendly/vcdExtra.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.

```

To solve this, you first have to `git pull` the remote content, but also set your current
repo to track upstream against the repo on Github.

```
euclid: Rgit/vcdextra % git branch --set-upstream-to=origin/master master
Branch master set up to track remote branch master from origin.
euclid: Rgit/vcdextra % git pull
Merge made by the 'recursive' strategy.
 README.md | 2 ++
 1 file changed, 2 insertions(+)
 create mode 100644 README.md
euclid: Rgit/vcdextra % git status
On branch master
Your branch is ahead of 'origin/master' by 285 commits.
  (use "git push" to publish your local commits)
nothing to commit, working directory clean
```

Now, `git push` should work, and you are in happy land.

### Putting it all together

It is relatively simple to write a shell or `perl` script or R function
that uses system commands to perform these operations.  For example, this
repository contains an R function, 
[`rforge2git()`](https://github.com/friendly/rforge2git/blob/master/rforge2git.R) that carries out these steps.
It allows you to specify the source `svn.repo` and/or the remote `git.repo`
and does the appropriate things. 

Here is an example of its use, just for the `git svn clone` related steps:

```
> source("~/R/functions/rforge2git.R")
> setwd('/tmp')
> svn.repo='svn://svn.r-forge.r-project.org/svnroot/tableplot'
> rforge2git(svn.repo)
Initialized empty Git repository in /tmp/tableplot/.git/
        A       www/index.php
        A       README
 ...

r13 = 45279467a6f9b02aaaf48294cee53300eb4989d4 (refs/remotes/git-svn)
        A       pkg/.Rbuildignore
        M       pkg/DESCRIPTION
        M       pkg/man/tableplot-package.Rd
r14 = d5c0eaac6a29e66c37a54acd043cd66baa226068 (refs/remotes/git-svn)
Checked out HEAD:
  svn://svn.r-forge.r-project.org/svnroot/tableplot r14
[master 12724da] fixup initial migration from svn
 60 files changed, 806 deletions(-)
```

Contents of the `tableplot` directory:

```
euclid: /tmp % ll -a tableplot
total 56
drwxr-xr-x  8 friendly staff  4096 Nov  4 10:19 .
drwxrwxrwt 17 root     root  12288 Nov  4 10:19 ..
drwxr-xr-x  2 friendly staff  4096 Nov  4 10:19 data
drwxr-xr-x  2 friendly staff  4096 Nov  4 10:19 demo
-rw-r--r--  1 friendly staff   845 Nov  4 10:19 DESCRIPTION
drwxr-xr-x  9 friendly staff  4096 Nov  4 10:19 .git
drwxr-xr-x  2 friendly staff  4096 Nov  4 10:19 inst
drwxr-xr-x  2 friendly staff  4096 Nov  4 10:19 man
-rw-r--r--  1 friendly staff   135 Nov  4 10:19 NAMESPACE
-rw-r--r--  1 friendly staff   123 Nov  4 10:19 NEWS
drwxr-xr-x  2 friendly staff  4096 Nov  4 10:19 R
-rw-r--r--  1 friendly staff    10 Nov  4 10:19 .Rbuildignore
-rw-r--r--  1 friendly staff     0 Nov  4 10:19 README.md
```



Updating a git/Github repo from SVN/R-Forge
-------------------------------------------

In the transition between using SVN/R-Forge and git/Github, it may happen that
you or other collaborators continue to make changes in the R-Forge SVN repository.
For example, someone may still be using eclipse/StatET or RStudio, with the
remote repository set to the R-Forge path.

Here's where things can get a little tricky, and dealing with this situation is
best avoided.
In general, it is possible  to create a local branch which tracks an svn repo 
(from R-Forge) such that you can merge changes from your git repo in and then commit them to svn (using `git svn dcommit`), or vice-versa: merge changes in the svn repo back to git.  But doing so probably requires some black-belt git skills.

In the latter case (merge svn changes to git), you can try to fix this up as shown below:

1.  Fetch the latest commits from svn
2.  Rebase the local repo to include the commits from svn
3.  Push the changes back to Github

```
git svn fetch
git svn rebase
git push
```


This won't work nicely if you have modified the directory structure of the 
`git svn clone` for the `pkg/` folder as described above.  There are 
some options for the `git svn fetch` step that will take account of this,
but they are not described here.  Additional useful information for using git with
R-forge can be found at Cameron Bracken's blog post: 
[Using Git with R-Forge ...](http://cameron.bracken.bz/git-with-r-forge).



