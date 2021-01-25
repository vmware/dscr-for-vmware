# Contributing to Desired State Configuration Resources for VMware

Welcome to Desired State Configuration Resources for VMware! We're thrilled that you'd like to contribute!

There are a few different ways you can contribute:

* [Submit an issue](#submitting-an-issue)
* [Fix an issue](#fixing-an-issue)
* [Review pull requests](#reviewing-pull-requests)
* [Proposing DSC Resources](#proposing-dsc-resources)

## Submitting an Issue
Submitting an issue to Desired State Configuration Resources for VMware is easy!

Here are the steps:

1. Make sure the issue is not open already.
2. Open a new issue.
3. Fill in the issue title.
4. Fill in the issue description.
5. Submit the issue.

### Open an Issue
Go to the Issues tab.

**Ensure that the issue you are about to file is not already open.**
If someone has already opened a similar issue, please leave a comment or add a GitHub reaction to the top comment to **express your interest**. You can also offer help and use the issue to coordinate your efforts in fixing the issue.

If you cannot find an issue that matches the one you are about to file, click the New Issue button.
A new, blank issue should open up.

### Fill in Issue Title
The issue title should be a brief summary of your issue in one sentence.

### Fill in Issue Description
The issue description should contain a **detailed** report of the issue you are submitting.
If you are submitting a bug, please include any error messages or stack traces caused by the problem.

Please reference any related issues or pull requests by a pound sign followed by the issue or pull request number (e.g. #11, #72). GitHub will automatically link the number to the corresponding issue or pull request.

Please also tag any GitHub users you would like to notice this issue. You can tag someone on GitHub with the @ symbol followed by their username.(e.g. @sgerginov)

### Submit an Issue
Once you have filled out the issue title and description, click the submit button at the bottom of the issue.

## Fixing an Issue
Here's the general process of fixing an issue in Desired State Configuration Resources for VMware:
1. Pick out the issue you'd like to work on.
2. Create a fork of the repository that contains the issue.
3. Clone your fork to your machine.
4. Create a working branch where you can store your updates to the code.
5. Make changes in your working branch to solve the issue.
6. Write Unit and Integration tests to ensure that the issue is fixed.
7. Submit a pull request to the master branch of the official repository for review.
8. Make sure all tests are passing in Travis CI for your pull request.
9. Make sure your code does not contain merge conflicts.
10. Address any comments brought up by the reviewer.

For more information about Github Issues, please read [here](https://help.github.com/articles/creating-an-issue/).

### Fork a Respository
A 'fork' on GitHub is your own personal copy of a repository.
GitHub's guide to forking a repository is available [here](https://help.github.com/articles/fork-a-repo/).
You will need a fork to contribute to Desired State Configuration Resources for VMware since only the maintainers have the ability to push to the official repositories.

### Clone your Fork
You will want to clone your fork so that you can edit code locally on your machine.
GitHub's guide to cloning is available [here](https://help.github.com/articles/cloning-a-repository/).

### Create a Working Branch
Your fork is your personal territory.
You may set it up however best suits your workflow, but we recommend that you set up a working branch separate from the default master branch.
Creating a working branch separate from the default master branch will allow you to create other working branches off of master later while your original working branch is still open for code reviews.
Limiting your current working branch to a single issue will also both streamline the code review and reduce the possibility of merge conflicts.

The Git guide to branching is available [here](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging).

### Make Code Changes
If you are creating new DSC Resource for VMware, you need to get familiar with the following guidelines: [Coding Guidelines](https://github.com/vmware/dscr-for-vmware/blob/master/CODING_GUIDELINES.md)
Pay attention to any new code merged into the master branch of the official repository. If this occurs, you will need to pick-up these changes in your fork.

### Submit a Pull Request
A [pull request](https://help.github.com/articles/using-pull-requests/) (PR) allows you to submit the changes you made in your fork to the official repository.

To open a pull request, go to the Pull Requests tab of either your fork or the official repository.

Click the New Pull Request button.

The base is the repository and branch the pull request will be merging **into**.
The target is the repository and branch the pull request will be merging **from**.
For Desired State Configuration Resources for VMware, always create a pull request with the base as the **master** branch of the official repository.
The target should be your working branch in your fork.

Once you select the correct base and target, you can review the file and commits that will be included in the pull request by selecting the tabs below the Create Pull Requests Button.

If GitHub tells you that your branches cannot automatically be merged, you probably have merge conflicts. These should be fixed before you submit your pull request.

Once you are ready to submit your pull request, click the Create Pull Request button.

#### Pull Request Title
The title of your PR should *describe* the changes it includes in one line.
Simply putting the issue number that the PR fixes is not acceptable.
If your PR deals with *one* specific resource, please prefix the title with the resource name followed by a colon.
If your PR fixes an issue please do still include "(Fixes #issue number)" in the title.
For example, if a PR fixes issues number 11 and 16 which adds the Ensure parameter to the VMHostTpsSettings resource, the title should be something like:
"VMHostTpsSettings: Added Ensure parameter (Fixes #11, #16)".

If you open a pull request with the wrong title, you can easily edit it by clicking the Edit button.

#### Pull Request Description
The description of your PR should include a detailed report of all the changes you made.
If your PR fixes an issue please include the number in the description.
Please tag anyone you would specifically like to see this PR with the @ symbol followed by their GitHub username (e.g. @sgerginov).

The description of your PR should follow the [template](https://github.com/vmware/dscr-for-vmware/blob/master/CHANGELOG_TEMPLATE.md). The Pull Request description should have one new line at the end so that in the [CHANGELOG.md](https://github.com/vmware/dscr-for-vmware/blob/master/CHANGELOG.md) each section is separated from the others with one empty line. The description will go through review as well because its content will go to the [CHANGELOG.md](https://github.com/vmware/dscr-for-vmware/blob/master/CHANGELOG.md) after merging the Pull Request and it is important to follow the desired structure. From the [template](https://github.com/vmware/dscr-for-vmware/blob/master/CHANGELOG_TEMPLATE.md) the first line with the module version and the date will be populated by the build and does not need to be part of the Pull Request description.

Once you are satisfied with the title, description and file changes included, submit the pull request.

### Get your Code Reviewed
Only maintainers can *review* your code and only maintainers can *merge* your code.
If you have specific maintainers you want to review your code, be sure to tag them in your pull request.

## Reviewing Pull Requests
**Pull requests should not be reviewed while tests are failing.**
If you are confused why tests are failing, tag a maintainer or ask the community for help.

### Making Review Comments
Some things to pay attention to while reviewing:

* Does the code logic make sense?
* Does the code structure make sense?
* Does this make the resource better?
* Is the code easy to read?
* Do all variables, parameters, and functions have **descriptive** names? (e.g. no $params, $args, $i, $a, etc.)
* Does every function have a help comment?
* Does the code follow the [Coding Guidelines](https://github.com/vmware/dscr-for-vmware/blob/master/CODING_GUIDELINES.md)?
* Has the author included test coverage for their changes?

## Proposing DSC Resources
Each proposed new **DSC Resource** should be announced via an **Issue**. The proposed resources will be reviewed by the maintainers of the repository. The person who proposes the new resource can start developing it right after it is approved by the maintainers of the repository or leave it to other contributors who want to work on the new resource.

For more complex resources it may be neccessary to have more than one contributor working on it - this will be reviewed by the maintainers: how many people are needed for the development of the resource.

Everyone who wants to contribute to new resources can volunteer - For example if the person who submitted the issue needs assistance or does not have time to continue working on the resource.

If the assignee of the **Issue** has any questions, they can ask a maintainer or other members from the community.

When the assignee is ready with the new Resource, **PR** should be opened which will then be reviewed by the maintainers.
