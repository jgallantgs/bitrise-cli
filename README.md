# Bitrise CLI

A command-line utility for interacting with [Bitrise](https://bitrise.io/ "Bitrise"), the continuous integration and delivery platform. With this interface, you can trigger builds, check their status, and receive alerts when they complete, along with specific error messages in case of failure. Plus more!



## Installation

Run this in your terminal:
```sh
sudo rm -rf bitrise-cli &&
git clone git@github.com:jgallantgs/bitrise-cli.git &&
cd bitrise-cli &&
sudo cp -f bitrise.zsh /usr/local/bin/bitrise &&
sudo chmod +x /usr/local/bin/bitrise
```
(Or wrap the .zsh file in a function and put it in your .zshrc)

## Auth/Preferences
The following preferences can be set within the `settings.cfg` file.

No quotes are needed, unless your strings contain spaces.

(Ex: `BITRISE_APP_SLUG=2j1k3h1289aslkdj`)


- `BITRISE_API_TOKEN` - Your api token for bitrise

- `BITRISE_APP_SLUG` - Your token for the bitrise app

- `NIGHTLY_WORKFLOW_ID` - The ID of the workflow to use for nightly builds.

- `QA_BUILD_WORKFLOW_ID` - The ID of the workflow to use for QA builds.

- `MONITOR_SLEEP` - The number of seconds to wait between monitoring checks.

- `LIMIT` - The maximum number of builds to retrieve in the get and list commands.

- `DEFAULT_BRANCH` - The default branch to use if no branch is specified.



## Example Usage

#### Building
- `$ bitrise` - Trigger a nightly build for $DEFAULT_BRANCH

- `$ bitrise -nightly` - Trigger a nightly build for the current branch

- `$ bitrise -nightly feature/new-feature` - Trigger a nightly build for a specific branch

- `$ bitrise -qa` - Trigger a QA build for the current branch

- `$ bitrise -qa feature/new-feature` - Trigger a qa build for a specific branch


#### Working with Existing Builds
- `$ bitrise -list` - List the last few builds based on $LIMIT

- `$ bitrise -get` - Get build information for the last few builds of the current branch

- `$ bitrise -get feature/new-feature` - Get build information for the last few builds of a specific branch

- `$ bitrise -stop 123456` - Stop a build by build number

- `$ bitrise -status 123456`  -  Check the status of a build by build number

- `$ bitrise -alert 123456` -  Monitor a build by build number


#### Other
- `$ bitrise -h` -  Display the help message

- `$ bitrise -reset` -   Deletes the config file
