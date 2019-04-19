# Committing Guidelines

By **default** when committing to the repository you need to Sign-Off all your commits.

You can use the following template via the command line when committing to the repository:

```
 git add .
 git commit -s -m <Your commit message>
 git push origin <Your working branch>
```

The '-s' flag automatically adds the following line to the commit message:

```
 Signed-off-by: <Your Name> <Your Email>
```

You can set your name and email with the following template:

```
 git config --global user.name <Your Name>
 git config --global user.email <Your Email>
```

## Keeping a fork up to date

### 1. Clone your fork:
```
git clone git@github.com:YOUR-USERNAME/YOUR-FORKED-REPO.git
```

### 2. Add remote from original repository in your forked repository:
```
cd into/cloned/fork-repo
git remote add upstream git://github.com/ORIGINAL-DEV-USERNAME/REPO-YOU-FORKED-FROM.git
git fetch upstream
```

### 3. Updating your fork from original repo to keep up with their changes:

#### 3.1 Keep your master branch up to date:
```
git rebase upstream/master
```

#### 3.2 Keep your feature branch up to date:
```
git stash
git checkout master
git rebase upstream/master
git checkout <your-feature-branch>
git rebase master
```
