<script src="https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/1.5.12/clipboard.min.js"></script>
<script>new Clipboard('.copy-to-clipboard');</script>
<style>.copy-to-clipboard {position: relative;}</style>
# Bitrise CLI

A command-line interface (CLI) for interacting with Bitrise, a continuous integration and delivery platform. The script allows you to trigger builds, monitor their progress, and check the status of previous builds, among other things.

## Installation

Wrap the file in a function call and put in your .zshrc or run the following to save as a binary.
<div class="copy-to-clipboard">
    <code>
        sudo rm -rf bitrise-cli &&
        git clone git@github.com:jgallantgs/bitrise-cli.git &&
        cd bitrise-cli &&
        sudo cp -f bitrise.zsh /usr/local/bin/bitrise &&
        sudo chmod +x /usr/local/bin/bitrise
    </code>
    <button class="btn copy-btn" data-clipboard-target="#copy-to-clipboard">Copy</button>
</div>

The script can be invoked by typing `bitrise` in your terminal. The command takes several optional parameters, as described below.

## Options
`-nightly <branch_name>`: Triggers a nightly build for the specified branch. If no branch name is provided, the build is triggered for the current branch.

`-qa <branch_name>`: Triggers a QA build for the specified branch. If no branch name is provided, the build is triggered for the current branch.

`-get <branch_name`>: Gets build information for the last few builds of the specified branch. If no branch name is provided, the information is fetched for the current branch.

`-stop <build_number>`: Stops a build specified by the build number.

`-status <build_number>`: Checks the status of a build specified by the build number.

`-monitor <build_number>`: Monitors a build specified by the build number.

`-h, -help`: Displays the help message.

`-reset`: Deletes the file storing keys.

## Auth/Preferences
The following preferences can be set within the `~/.bitriseCLI` file.

- BITRISE_API_TOKEN: your api token for bitrise
- BITRISE_APP_SLUG: your token for the bitrise app
- NIGHTLY_WORKFLOW_ID: The ID of the workflow to use for nightly builds.
- QA_BUILD_WORKFLOW_ID: The ID of the workflow to use for QA builds.
- MONITOR_SLEEP: The number of seconds to wait between monitoring checks.
- LIMIT: The maximum number of builds to retrieve in the get command.
- DEFAULT_BRANCH: The default branch to use if no branch is specified.

## Example Usage

Trigger a nightly build for the current branch
`$ $ bitrise -nightly`

Trigger a nightly build for a specific branch
`$ bitrise -nightly feature/new-feature`

Trigger a QA build for the current branch
`$ bitrise -qa`

Get build information for the last few builds of the current branch
`$ bitrise -get`

Get build information for the last few builds of a specific branch
`$ bitrise -get feature/new-feature`

Stop a build by build number
`$ bitrise -stop 123456`

Check the status of a build by build number
`$ bitrise -status 123456`

Monitor a build by build number
`$ bitrise -monitor 123456`

Display the help message
`$ bitrise -h`

Deletes the config file
`$ bitrise -reset`
