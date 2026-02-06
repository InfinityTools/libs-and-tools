#!/usr/bin/env bash

# Copyright 2026 Argent77
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom
# the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

########################################
# Automated installation of WeiDU mods #
########################################

# Version of mod_batcher
app_version="1.1-20260206"

# Function: Prints the help text to standard output.
# Parameters: none
# Return value: none
show_help() {
  echo "Usage: $0 [OPTION]... [<weidu-log>]"
  echo ""
  echo "Install all mod components listed in the specified WeiDU log file,"
  echo "optionally uninstalling currently installed mods first."
  echo ""
  echo "WeiDU log parameter can be omitted to remove only currently installed mods"
  echo "without installing any new mods."
  echo ""
  echo "Options:"
  echo "  -a              Appends mods to an existing mod installation. Omit this option"
  echo "                  to remove all currently installed mods first."
  echo "  -b <path>       Path of the WeiDU binary to use for the operation. Omit this"
  echo "                  option to use the WeiDU binary found in the current directory"
  echo "                  or system path instead."
  echo "  -g <path>       Specifies the game directory (where chitin.key can be found)."
  echo "                  Omit this option to use the current directory instead."
  echo "  -l              Print output of the mod operations to a timestamped log file."
  echo "  -p              Just print the mod components for installation and exit."
  echo "  -x              Also log output from external commands invoked by WeiDU."
  echo "  --              Does nothing. Use this option as placeholder to uninstall"
  echo "                  all currently installed mod components without installing any"
  echo "                  new mods. May be omitted if other options are specified."
  echo "  -h | --help     Print this help to the standard output and exit."
  echo "  -v | --version  Print the version number and exit."
}

# Function: Prints version information to standard output.
# Parameters: none
# Return value: none
show_version() {
  echo "mod_batcher.sh version $app_version by Argent77"
}

# Function: Attempts to find the WeiDU binary in the system path or the current directory.
# Parameters: none
# Return value: full path to weidu binary if available, empty string otherwise.
find_weidu() {
  (test -x "$PWD/weidu" && echo "$PWD/weidu") || (which weidu) || (echo "")
}

# Function: Resolves a given path string to an existing path. Path is assumed to be relative to $game_dir.
# Parameters: @1=tp2_path; @2=game_path
# Return value: resolved "tp2_path" string if available, empty string otherwise.
eval_path() {
  # resolve path string
  if [[ $# -gt 1 ]]; then
    local game_dir="$1"
    local path="$2"
    path=$(find "$game_dir" -ipath "$game_dir/$path" 2>/dev/null)
    path=${path#"$game_dir/"}
    echo "$path"
  else
    echo ""
  fi
}

# Function: Generates an array of WeiDU.log lines from the given WeiDU.log path string.
# Parameters: $1=WeiDU.log path string; $2=array name for log entries (default: entries)
# Return value: none
# Global: Array "$2" with raw log entries from "$1"
parse_log() {
  if [[ $# -gt 0 ]]; then
    local array_name=
    if [[ $# -gt 1 ]]; then
      array_name="$2"
    else
      array_name="entries"
    fi

    declare -n loglines="$array_name"
    loglines=()

    if [[ -f "$1" ]]; then
      # extracting valid log entries line by line
      local line=
      while IFS= read -r line; do
          # Skip lines starting with two slashes
          [[ "$line" =~ ^// ]] && continue

          # Remove trailing line feed
          line=$(echo "$line" | tr -d '\r')

          loglines+=("$line")
      done < "$1"
    fi
  fi
}

# Function: Splits the content of a given WeiDU.log entry into three items: 0=tp2_path, 1=lang_id, 2=comp_id
# Parameters: $1=game directory; $2=WeiDU.log entry as string; $3=array name for entry items (default: entry)
# Return value: none
# Global: Array "@2" with 4 items extracted from "$1": tp2_path, lang_id, component_id, component label (optional)
#         if successful, 0 items otherwise.
parse_log_entry() {
  if [[ $# -gt 0 ]]; then
    local array_name=
    if [[ $# -gt 2 ]]; then
      array_name="$3"
    else
      array_name="entry"
    fi
    declare -n logitems="$array_name"
    logitems=()

    if [[ $# -gt 1 ]]; then
      local game_dir="$1"
      local line="$2"

      # Split line into tokens
      # Expecting: ~tp2_path~ #lang_id #comp_id [// comment]
      local tp2_path=
      local lang_id=
      local comp_id=
      local comment=
      read -r tp2_path lang_id comp_id comment <<< "$line"

      # Remove surrounding tildes from first token
      tp2_path="${tp2_path#\~}"
      tp2_path="${tp2_path%\~}"

      # Remove leading hash from numeric tokens
      lang_id="${lang_id#\#}"
      comp_id="${comp_id#\#}"

      # Optional comment
      comment="${comment#// }"

      # basic log entry validation
      if [[ "$tp2_path" =~ ^.+\.[tT][pP]2$ && "$lang_id" =~ ^-?[0-9]+$ && "$comp_id" =~ ^-?[0-9]+$ ]]; then
        # resolve tp2 path
        tp2_path=$(eval_path "$game_dir" "$tp2_path")
        if [[ -n "$tp2_path" ]]; then
          logitems+=("$tp2_path")
          logitems+=("$lang_id")
          logitems+=("$comp_id")
          logitems+=("$comment")
        fi
      fi
    fi
  fi
}

# Function: Generates a .DEBUG filename from the specified tp2 file path.
# Parameters: $1=TP2 file path
# Return value: *.debug filename
get_debug_filename() {
  if [[ $# -gt 0 ]]; then
    local filename=$(basename -- "$1" | tr '[:upper:]' '[:lower:]')
    local filename="${filename#setup-}"
    local filename="${filename%.*}"
    echo "setup-${filename}.debug"
  fi
}

# Associative array as cache for tracking debug file usage
declare -A debug_files

# Function: Determines whether a .debug file should be appended or not.
# Parameters: @1=debug file
# Return value: "--logapp" if debug file is already in use, empty string otherwise.
# Global: Updates associative array "debug_files" accordingly.
append_debug_file() {
  if [[ $# -gt 0 ]]; then
    if [[ -v debug_files["$1"] ]]; then
      echo "--logapp"
    else
      debug_files["$1"]=1
    fi
  fi
}

# Function: Returns the current timestamp (date and time) as a string.
# Parameters: none
# Return value: formatted timestamp (format: "YYYYMMDDhhmmss")
get_timestamp() {
  date "+%Y%m%d%H%M%S"
}

# Function: Prints the given string to standard out and, depending on script options, to a log file.
# Parameters: $1=string to print; $2=severity [0=message, 1=warning, 2=error] (default: 0)
# Return value: input string with optional severity prefix
log() {
  if [[ $# -gt 0 ]]; then
    local prefix=""
    if [[ $# -gt 1 ]]; then
      case $2 in
        1)
          prefix="WARNING: "
          ;;
        2)
          prefix="ERROR: "
          ;;
        *)
          ;;
      esac
    fi

    local msg="${prefix}${1}"
    if [[ -n "$batcher_log" ]]; then
      echo "$msg" >>$batcher_log
    fi
    echo "$msg"
  fi
}


# Check for required parameter
if [[ $# -eq 0 ]]; then
  show_help
  exit 0
fi

# Store game directory
game_dir="$PWD"

# Retrieve system's WeiDU binary
weidu_bin=$(find_weidu)

# Store global log file (Default: Don't log to a file)
batcher_log=
# Store 'tee' output file (Default: Discard output)
batcher_redirect=/dev/null

# Store whether to remove currently installed mods (Default: remove installed mods first)
remove_first=1

# Store whether to only print mod components to standard output (Default: install mod components for real)
print_only=0

# Store weidu log with mod components to install (Default: empty log file path)
logfile=

# Store WeiDU option for including output from external commands (Default: do not log output from external commands)
opt_extern=

# Evaluate options and parameters
while [[ $# -ne 0 ]]; do
  case $1 in
    -a)
      remove_first=0
      ;;
    -b)
      shift
      if [[ $# -ne 0 ]]; then
        if [[ -x "$1" ]]; then
          weidu_bin="$1"
        else
          log "Specified WeiDU binary not found. Skipping." 1
        fi
      else
        log "Option -b specified without WeiDU binary path." 2
        exit 1
      fi
      ;;
    -g)
      shift
      if [[ $# -ne 0 ]]; then
        if [[ -d "$1" ]]; then
          game_dir="$1"
        else
          log "Specified path is not a directory. Skipping." 1
        fi
      else
        log "Option -g specified without game directory." 2
        exit 1
      fi
      ;;
    -l)
      batcher_log="mod_batcher-$(get_timestamp)"
      batcher_redirect="$batcher_log"
      ;;
    -p)
      print_only=1
      ;;
    -x)
      opt_extern="--log-extern"
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    -v|--version)
      show_version
      exit 0
      ;;
    --)
      # pseudo option
      ;;
    -*)
      log "Unknown option: $1" 2
      ;;
    *)
      # only the first specified log file is used
      if [[ -z "$logfile" ]]; then
        if [[ -f "$1" ]]; then
          logfile="$1"
        else
          log "Log file not found: $1" 2
          exit 1
        fi
      fi
      ;;
  esac
  shift
done

# Check if valid game directory
if [[ -z "$(find "$game_dir" -maxdepth 1 -iname chitin.key)" ]]; then
  log "Not a valid game directory: $game_dir" 2
  exit 1
fi

# WeiDU.log file is required
if [[ -n "$logfile" && ! -f "$logfile" ]]; then
  log "Log file not found: $logfile" 2
  exit 1
fi

# WeiDU binary is required
if [[ -z "$weidu_bin" ]]; then
  log "WeiDU binary not found." 2
  exit 1
fi

# performing operation
log "WeiDU binary: $weidu_bin"
log "Game directory: $game_dir"

# WeiDU operations don't work from outside of the game directory
if [[ -n "$weidu_bin" ]]; then
  weidu_bin=$(realpath -s "$weidu_bin")
fi
if [[ -n "$logfile" ]]; then
  logfile=$(realpath -s "$logfile")
fi
if [[ -n "$game_dir" ]]; then
  game_dir=$(realpath -s "$game_dir")
fi
pushd "$PWD" >/dev/null
cd "$game_dir"

# preparing mod components from given WeiDU.log (part 1)
if [[ -n "$logfile" ]]; then
  parse_log "$logfile" "log_weidu"
fi

# removing installed mods
if [[ $remove_first -ne 0 && -f "$game_dir/weidu.log" ]]; then
  parse_log "$game_dir/weidu.log" "log_uninstall"

  # print list of mods to uninstall only
  if [[ $print_only -ne 0 ]]; then
    log ""
    log "Mod components marked for uninstallation: ${#log_uninstall[@]}"
    for (( i = ${#log_uninstall[@]} - 1; i >= 0 ; i-- )); do
      index=$((${#log_uninstall[@]} - i))
      parse_log_entry "$game_dir" "${log_uninstall[i]}" "entry_uninstall"
      if [[ ${#entry_uninstall[@]} -gt 0 ]]; then
        line="${index}) tp2: \"${entry_uninstall[0]}\", language: #${entry_uninstall[1]}, component: #${entry_uninstall[2]}"
        if [[ -n ${entry_uninstall[3]} ]]; then
          line="${line} (${entry_uninstall[3]})"
        fi
        log "$line"
      else
        log "Not found: Skipping entry: ${log_uninstall[i]}"
      fi
    done
  fi

  if [[ $print_only -eq 0 && ${#log_uninstall[@]} -gt 0 ]]; then
    log ""
    log "Operation: Removing existing mod components..."
    for (( i=${#log_uninstall[@]} - 1; i >= 0; i-- )); do
      parse_log_entry "$game_dir" "${log_uninstall[i]}" "entry_uninstall"
      if [[ ${#entry_uninstall[@]} -gt 0 ]]; then
        debug_file=$(get_debug_filename "${entry_uninstall[0]}")
        opt_append=$(append_debug_file "$debug_file")
        if [[ ! -f "$debug_file" ]]; then
          touch "$debug_file" # workaround to fix file access modes
        fi

        # log "Executing: $weidu_bin --force-uninstall ${entry_uninstall[2]} $opt_append $opt_extern --log \"$debug_file\" \"${entry_uninstall[0]}\""
        output="Uninstalling: \"${entry_uninstall[0]}\" #${entry_uninstall[1]} #${entry_uninstall[2]}"
        if [[ -n ${entry_uninstall[3]} ]]; then
          output="$output (${entry_uninstall[3]})"
        fi
        log "$output"

        "$weidu_bin" --force-uninstall ${entry_uninstall[2]} $opt_append $opt_extern --log "$debug_file" "${entry_uninstall[0]}" 2>&1 | tee -a $batcher_redirect
        if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
          log "Failed to uninstall \"${entry_uninstall[0]}\", component ${entry_uninstall[2]}." 2
          popd >/dev/null
          exit 1
        fi
      else
        log "Not found: Skipping uninstallation: ${log_uninstall[i]}"
      fi
    done
  elif [[ -z "$logfile" ]]; then
    log ""
    log "No mod components to uninstall found."
  fi
fi

if [[ -n "$logfile" ]]; then
  # preparing mod components from given WeiDU.log (part 2)
  if [[ ${#log_weidu[@]} -eq 0 ]]; then
    log ""
    log "No valid mod components found in \"$logfile\"."
    popd >/dev/null
    exit 0
  fi

  # print list of mod components only
  if [[ $print_only -ne 0 ]]; then
    log ""
    log "Mod components found for installation: ${#log_weidu[@]}"
    for (( i = 0; i < ${#log_weidu[@]}; i++ )); do
      index=$((i + 1))
      parse_log_entry "$game_dir" "${log_weidu[i]}" "entry_weidu"
      if [[ ${#entry_weidu[@]} -gt 0 ]]; then
        line="${index}) tp2: \"${entry_weidu[0]}\", language: #${entry_weidu[1]}, component: #${entry_weidu[2]}"
        if [[ -n ${entry_weidu[3]} ]]; then
          line="${line} (${entry_weidu[3]})"
        fi
        log "$line"
      else
        log "Not found: Skipping entry: ${log_weidu[i]}"
      fi
    done
  fi

  # install for real
  if [[ $print_only -eq 0 ]]; then
    log ""
    log "Operation: Installing mod components from \"$logfile\"..."
    for (( i = 0; i < ${#log_weidu[@]}; i++ )); do
      parse_log_entry "$game_dir" "${log_weidu[i]}" "entry_weidu"
      if [[ ${#entry_weidu[@]} -gt 0 ]]; then
        debug_file=$(get_debug_filename "${entry_weidu[0]}")
        opt_append=$(append_debug_file "$debug_file")
        if [[ ! -f "$debug_file" ]]; then
          touch "$debug_file" # workaround to fix file access modes
        fi

        # log "Executing: $weidu_bin --language ${entry_weidu[1]} --force-install ${entry_weidu[2]} $opt_append $opt_extern --log \"$debug_file\" \"${entry_weidu[0]}\""
        output="Installing: \"${entry_weidu[0]}\" #${entry_weidu[1]} #${entry_weidu[2]}"
        if [[ -n ${entry_weidu[3]} ]]; then
          output="$output (${entry_weidu[3]})"
        fi
        log "$output"

        "$weidu_bin" --language ${entry_weidu[1]} --force-install ${entry_weidu[2]} $opt_append $opt_extern --log "$debug_file" "${entry_weidu[0]}" 2>&1 | tee -a $batcher_redirect
        if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
          log "Failed to install \"${entry_weidu[0]}\", component ${entry_weidu[2]}." 2
          popd >/dev/null
          exit 1
        fi
      else
        log "Not found: Skipping installation: ${log_weidu[i]}"
      fi
    done

    log ""
    log "Mod installation finished."
  fi
fi

popd >/dev/null
exit 0
