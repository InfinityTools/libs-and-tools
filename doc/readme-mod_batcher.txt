Mod Batcher (Shell Script)
~~~~~~~~~~~~~~~~~~~~~~~~~~

Version:  1.2-20260209
Author:   Argent77
License:  MIT

Overview
--------

Mod Batcher (mod_batcher.sh) is a Bash shell script that automates the installation of mod components from a given
WeiDU log file. Already installed mods may be optionally uninstalled first.

For the shell script to work successfully, mods for installation must be present in the game directory. Otherwise,
they will be skipped. Further options allow to specify the WeiDU binary, game directory, and various logging options.

The script should be compatible with any platforms that can run a recent version of GNU Bash (v5.0 or later), which
includes Linux, macOS, and Windows (e.g. via Cygwin or WSL).


Usage
-----

mod_batcher.sh [OPTION]... [<weidu-log>]

Install all mod components listed in the specified WeiDU log file, optionally uninstalling currently installed mods first.

WeiDU log parameter can be omitted to remove only currently installed mods without installing any new mods.

Options:
  -a              Appends mods to an existing mod installation. Omit this option to remove all currently installed mods
                  first.
  -b <path>       Path of the WeiDU binary to use for the operation. Omit this option to use the WeiDU binary found in
                  the current directory or system path instead.
  -g <path>       Specifies the game directory (where chitin.key can be found). Omit this option to use the current
                  directory instead.
  -l              Print output of the mod operations to a timestamped log file.
  -p              Just print the mod components for installation and exit.
  -x              Also log output from external commands invoked by WeiDU.
  --              Does nothing. Use this option as placeholder to uninstall all currently installed mod components
                  without installing any new mods. May be omitted if other options are specified.
  -h | --help     Print this help to the standard output and exit.
  -v | --version  Print the version number and exit.


Examples
--------

Note: Unless specified otherwise, all script use examples expect the WeiDU executable to be found either in the current
working directory or in the system PATH.

This call installs all listed mod components in the file "weidu-new.log". Currently installed mod components are
uninstalled first:

  mod_batcher.sh weidu-new.log

This call removes all currently installed mod components without installing anything new:

  mod_batcher.sh --

This call prints all mod components that are about to be uninstalled and any new mod components from the given WeiDU
log to the standard output without performing any further actions:

  mod_batcher.sh -p weidu-new.log

This call reinstalls all currently installed mod components and logs the result to the file "mod_batcher-<timestamp>.log",
including output from external commands invoked by WeiDU:

  mod_batcher.sh -l -x weidu.log

This call uses a custom WeiDU binary to install mod components for a game in a specified directory without uninstalling
currently installed mods first, and logs the whole operation to the file "mod_batcher-<timestamp>.log":

  mod_batcher.sh -a -b $HOME/bin/weidu -g $HOME/games/bg2 -l weidu-new.log


Changelog
---------

Version 1.2
- Changed default logging method to create individual debug logs for each mod component
- Changed default log file directory to "debugs" folder
- Changed debug file prefix for uninstalled mod components to "remove"
- Added option to combine logs for all components of a mod into a single file
- Added option to specify an output directory for log files

Version 1.1
- Added readme
- Improved validation of WeiDU log entries

Version 1.0
- Initial release
