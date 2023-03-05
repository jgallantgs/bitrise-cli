if [ ! -f ~/bitrise-cli/settings.cfg ]; then
  echo "First run detected, opening preferences."
  # Write to config
  echo "BITRISE_API_TOKEN=" >>~/bitrise-cli/settings.cfg
  echo "BITRISE_APP_SLUG=" >>~/bitrise-cli/settings.cfg
  echo "NIGHTLY_WORKFLOW_ID=" >>~/bitrise-cli/settings.cfg
  echo "QA_BUILD_WORKFLOW_ID=" >>~/bitrise-cli/settings.cfg
  echo "MONITOR_SLEEP=30" >>~/bitrise-cli/settings.cfg
  echo "LIMIT=5" >>~/bitrise-cli/settings.cfg
  echo "DEFAULT_BRANCH=develop" >>~/bitrise-cli/settings.cfg
  # Open the file for editing
  open ~/bitrise-cli/settings.cfg
  exit
else
  source ~/bitrise-cli/settings.cfg
  # Check if any variables are empty
  if [ -z "$BITRISE_API_TOKEN" ] || [ -z "$BITRISE_APP_SLUG" ] || [ -z "$NIGHTLY_WORKFLOW_ID" ] || [ -z "$QA_BUILD_WORKFLOW_ID" ] || [ -z "$DEFAULT_BRANCH" ]; then
    # Open the file for editing
    open ~/bitrise-cli/settings.cfg
    exit
  fi
fi

function help() {
  echo "Bitrise CLI"
  echo ""
  echo "If run without any parameters, the command will trigger a nightly build for the current branch."
  echo "If not in a current branch, it will default to develop per user preferences."
  echo ""
  echo "Usage: build [-nightly|-qa|-get| <branch_name>]"
  echo "Usage: build [-status|-stop|-monitor <build_number>]"
  echo "Options:"
  echo "  -get <branch_name>     Get build info for the last few builds of the specified branch."
  echo "                         If branch_name is not provided, it uses the current branch."
  echo "                         Example: build -get feature/new-feature"
  echo ""
  echo "  -nightly <branch_name> Trigger a nightly build for the specified branch."
  echo "                         If branch_name is not provided, it uses the current branch."
  echo "                         Example: build -nightly feature/new-feature"
  echo ""
  echo "  -qa <branch_name>      Trigger a qa build for the specified branch."
  echo "                         If branch_name is not provided, it uses the current branch."
  echo "                         Example: build -qa feature/new-feature"
  echo ""
  echo "  -stop <build_number>   Stop a build specified by the build number."
  echo "                         Requires a build number as the second argument."
  echo "                         Example: build -stop 123456"
  echo ""
  echo "  -status <build_number> Check the status of a build specified by the build number."
  echo "                         Requires a build number as the second argument."
  echo "                         Example: build -status 123456"
  echo ""
  echo "  -monitor <build_number> Monitor a build specified by the build number."
  echo "                           Requires a build number as the second argument."
  echo "                           Example: build -monitor 123456"
  echo ""
  echo "  -h, -help               Display this help message."
  echo ""
  echo "  -reset                  Deletes the settings file that stores keys"
  echo ""
  return 0
}

# Main loop that parses params
function main() {
  echo ""
  if [[ $# -eq 0 ]]; then
    trigger_build "$BITRISE_API_TOKEN" "$BITRISE_APP_SLUG" "$NIGHTLY_WORKFLOW_ID" "${2:-$(get_current_branch)}"
  elif [[ "$1" == "-h" || "$1" == "-help" ]]; then
    help
  elif [[ "$1" == "-nightly" ]]; then
    trigger_build "$BITRISE_API_TOKEN" "$BITRISE_APP_SLUG" "$NIGHTLY_WORKFLOW_ID" "${2:-$(get_current_branch)}"
  elif [[ "$1" == "-qa" ]]; then
    trigger_build "$BITRISE_API_TOKEN" "$BITRISE_APP_SLUG" "$QA_BUILD_WORKFLOW_ID" "${2:-$(get_current_branch)}"
  elif [[ "$1" == "-stop" ]]; then
    if [[ -z "$2" ]]; then
      message_helper "Error" "Please specify a build number"
    else
      stop "$2"
    fi
  elif [[ "$1" == "-status" ]]; then
    if [[ -z "$2" ]]; then
      message_helper "Error" "Please specify a build number"
    else
      status "$2"
    fi
  elif [[ "$1" == "-get" ]]; then
    get ${2:-$(get_current_branch)}
  elif [[ "$1" == "-monitor" ]]; then
    if [[ -z "$2" ]]; then
      message_helper "Error" "Please specify a build number"
    else
      monitor "$2"
    fi
  elif [[ "$1" == "-reset" ]]; then
    rm -f ~/bitrise-cli/settings.cfg
    echo "Deleted ~/bitrise-cli/settings.cfg"
  else
    help
  fi
  echo ""
  exit
}

# Branch functions
function trigger_build() {
  local token="$1"
  local app_slug="$2"
  local workflow_id="$3"
  local branch="$4"

  local response=$(curl --fail -sS -H "Authorization: token $token" \
    -H "Content-Type: application/json" \
    -d '{
      "hook_info":{
        "type":"bitrise"
      },
      "build_params": {
        "branch": "'"$branch"'",
        "workflow_id": "'"$workflow_id"'"
      }
    }' "https://app.bitrise.io/app/$app_slug/build/start.json")

  if [[ "$response" == *"\"status\":\"ok\""* ]]; then
    local build_number=$(echo "$response" | sed -nE 's/.*"build_number":([0-9]+).*/\1/p')
    echo "Building '$branch' with '$workflow_id' on \033[0;32m$build_number\033[0m"
    echo "Do you want to monitor the build (m), abort it (a), or exit (e)? "
    read -r input

    case $input in
    "m")
      monitor "$build_number"
      ;;
    "a")
      stop "$build_number"
      ;;
    *)
      return 0
      ;;
    esac
  else
    return 1
  fi
}

function get() {
  local response=$(curl -s "https://api.bitrise.io/v0.1/apps/$BITRISE_APP_SLUG/builds?branch=$2&limit=$LIMIT" \
    -H "Authorization: token $BITRISE_API_TOKEN")

  local builds=$(echo $response | grep -o '{.*}' | sed 's/},{/}\n{/g')

  while IFS= read -r build; do
    local build_number=$(echo $build | sed -n 's/.*"build_number":\([0-9]*\).*/\1/p')
    local triggered_at=$(echo $build | sed -n 's/.*"triggered_at":"\([^"]*\)".*/\1/p')
    local build_status=$(echo $build | sed -n 's/.*"status":\([0-9]*\).*/\1/p')
    local time_elapsed=""

    if [[ "$status" -eq 0 ]]; then
      start_seconds=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$triggered_at" +%s)
      current_seconds=$(date +%s)
      elapsed_seconds=$((current_seconds - start_seconds))
      time_elapsed=$(printf '%dm:%ds\n' $(($elapsed_seconds / 60)) $(($elapsed_seconds % 60)))
    fi

    local status_text=""
    local status_color=""

    if [[ "$build_status" -ne 0 ]]; then
      echo "Build $build_number - $(print_status_text $build_status)"
    else
      echo "Build $build_number - $(print_status_text $build_status) - Time elapsed: $time_elapsed"
    fi
  done <<<"$builds"

  return 0
}

# Build number functions
function monitor() {
  echo "Monitoring build $1..."
  echo "Press any key to stop monitoring."

  local build_details=$(get_build_details "$1")
  local status_code=$(echo "$build_details" | sed -n 's/.*"status":[[:space:]]*\([0-9]*\).*/\1/p')
  local status_text=$(echo "$build_details" | sed -n 's/.*"status_text":"\([^"]*\)".*/\1/p')

  while [[ "$status_code" -eq 0 ]]; do
    read -rsn1 -t 1 key
    if [ -n "$key" ]; then
      echo "Monitoring stopped."
      return 1
    fi

    sleep $MONITOR_SLEEP
    build_details=$(get_build_details "$1")
    status_code=$(echo "$build_details" | sed -n 's/.*"status":[[:space:]]*\([0-9]*\).*/\1/p')
    status_text=$(echo "$build_details" | sed -n 's/.*"status_text":"\([^"]*\)".*/\1/p')
  done

  status $1
  if [ $status_code -eq 2 ]; then
    osascript -e 'tell application "Terminal" to activate'
  fi
  osascript -e "display notification \"Status: $status_text\" with title \"Bitrise $1\" sound name \"Blow\""
  return 0
}

function stop() {
  local build_details=$(get_build_details "$1")
  local build_slug=$(echo "$build_details" | sed -n 's/.*"slug":"\([^"]*\)".*/\1/p')
  local abort_output=$(curl -s -X POST -H "Authorization: token $BITRISE_API_TOKEN" -H "Content-Type: application/json" -d '{}' "https://api.bitrise.io/v0.1/apps/$BITRISE_APP_SLUG/builds/$build_slug/abort")

  if [[ "$abort_output" == '{"status":"ok"}' ]]; then
    message_helper "Success" "Build $1 aborted."
    return 0
  else
    message_helper "Error" "Could not abort build $1."
    return 1
  fi
}

function status() {
  local build_details=$(get_build_details "$1")
  local status_code=$(echo "$build_details" | sed -n 's/.*"status":[[:space:]]*\([0-9]*\).*/\1/p')

  if [[ $status_code -eq 0 ]]; then
    local triggered_at=$(echo "$build_details" | sed -n 's/.*"triggered_at":"\([^"]*\)".*/\1/p')
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local triggered_at_seconds=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" -u "$triggered_at" "+%s")
    local current_time_seconds=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" -u "$current_time" "+%s")
    local elapsed_time=$((current_time_seconds - triggered_at_seconds))

    local minutes=$((elapsed_time / 60))
    local seconds=$((elapsed_time % 60))
    echo "Elapsed time: ${minutes}m:${seconds}s"
  elif [[ $status_code -eq 2 ]]; then
    local build_slug=$(echo "$build_details" | sed -n 's/.*"slug":"\([^"]*\)".*/\1/p')
    local BUILD_URL="https://api.bitrise.io/v0.1/apps/$BITRISE_APP_SLUG/builds/$build_slug/log"
    local response=$(curl -s -H "Authorization: $BITRISE_API_TOKEN" -H "Content-Type: application/json" $BUILD_URL)
    local log_chunks=$(echo "${response}" | sed -E 's/.*"chunk":"([^"]+)".*/\1/g' | tr -d '\\' | tr '\r' '\n')

    while read -r chunk; do
      if echo "${chunk}" | grep -q -i -e "Failure:" -e "❌" -e "⚠️" -e "failed to"; then
        echo "${chunk}"
      fi
    done <<<"${log_chunks}"
  fi

  print_status_text $status_code
}

# Helper Functions
function message_helper() {
  local status_type="$1"
  local message="$2"
  local color_code="\033[0m"

  if [[ "$status_type" == "Error" ]]; then
    color_code="\033[0;31m"
  elif [[ "$status_type" == "Success" ]]; then
    color_code="\033[0;32m"
  fi
  echo "${color_code}${status_type}\033[0m: ${message}"
}

function print_status_text() {
  local status_code=$1
  case $status_code in
  0)
    echo "Status: \033[33mIn progress\033[0m" # yellow
    ;;
  1)
    echo "Status: \033[32mSuccessful\033[0m" # green
    ;;
  2)
    echo "Status: \033[31mFailed\033[0m" # red
    ;;
  3)
    echo "Status: \033[36mAborted\033[0m" # blue
    ;;
  4)
    echo "Status: \033[36mAborted with success\033[0m" # blue
    ;;
  *)
    echo "Status: Unknown"
    ;;
  esac
}

function get_current_branch() {
  branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ -n "${branch_name}" ]]; then
    echo "${branch_name}"
  else
    echo "$DEFAULT_BRANCH"
  fi
}

function get_build_details() {
  local build_details=$(curl -s -X GET -H "Authorization: token $BITRISE_API_TOKEN" "https://api.bitrise.io/v0.1/apps/$BITRISE_APP_SLUG/builds?build_number=$1")

  if [[ "$build_details" == *"data\":[]"* ]]; then
    message_helper "Error" "No build found with build number $1."
    exit 1
  fi

  echo $build_details
}

main "$@"
