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