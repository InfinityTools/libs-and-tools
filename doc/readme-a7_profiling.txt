WeiDU Profiling Library
~~~~~~~~~~~~~~~~~~~~~~~

Version:  1.0
Author:   Argent77
License:  MIT


************
* Overview *
************

This library provides basic diagnostic functionality for WeiDU mods. It allows the user to measure execution time
of individual WeiDU functions as well as the number of function calls.

The main file of the library "a7_profiling.tph" used different implementations for tracking function calls based on the
version of the WeiDU binary that executes the mod:
- For WeiDU version 249 and older it uses a slower implementation that may lead to heavy memory usage if it has to track
  a huge number of function calls.
- For WeiDU version 250 and later it uses a faster implementation that doesn't suffer from any memory usage issues.

IMPORTANT:
If the mod path of the library files differs from "%MOD_FOLDER%/lib" then open "a7_profiling.tph" and adjust the path specified
by the "a7#profiling_include_path" variable accordingly.


****************
* Code example *
****************

Given the following mod structure:
- mymod/mymod.tp2
- mymod/lib/a7_profiling.tph  (this library)
- mymod/lib/functions.tph     (with functions to profile)

File mymod/lib/functions.tph:
DEFINE_ACTION_FUNCTION my_action
INT_VAR value = 0
BEGIN
  PRINT "Calling action function with argument value=%value%"
  OUTER_PATCH ~~ BEGIN
    LPF my_patch INT_VAR value RET number END
  END
END

DEFINE_PATCH_FUNCTION my_patch
INT_VAR value = 0
RET number
BEGIN
  SET number = value + value
  PATCH_PRINT "Calling patch function with return value number=%number%"
END

File mymod/mymod.tp2:
BACKUP "weidu_external/backup/mymod"
AUTHOR "Mod Author"

BEGIN "Profiling test"
NO_LOG_RECORD

// Preparing include file "functions.tph"
INCLUDE "mymod/lib/a7_profiling.tph"
LAF a7#profiling_include
  INT_VAR enable_trace = 1
  STR_VAR include_path = "mymod/lib/functions.tph"
  RET include_path
END
INCLUDE "%include_path%"

// Calling our mod functions
LAF my_action INT_VAR value = 2 END

OUTER_PATCH "" BEGIN
  LPF my_patch INT_VAR value = 3 RET number END
END

// Generating log output
LAF a7#profiling_print_function_call_stats
  STR_VAR title = "MyMod function call statistics:"
END

LAF a7#profiling_print_function_hierarchy_stats
  STR_VAR title = "MyMod function hierarchy statistics:"
END

Logged output in the generated SETUP-MYMOD.DEBUG file if mod was invoked by the "setup-mymod" binary:
Calling action function with argument value=2
Calling patch function with return value number=4
LPF my_patch(value=2) => number=4
LAF my_action(value=2) => 

Calling patch function with return value number=6
LPF my_patch(value=3) => number=6

MyMod function call statistics:
LAF my_action                    1
LPF my_patch                     2

MyMod function hierarchy statistics:
LAF my_action     1
    LPF my_patch  1
LPF my_patch      1

    Mod Timings
LPF my_patch                     0.016
LAF my_action                    0.007


***********************
* Profiling functions *
***********************

DEFINE_ACTION_FUNCTION a7#profiling_include
-------------------------------------------
Action function that patches the specified WeiDU include file with diagnostic functionality.

The include file must follow a well-formed structure:
- Function header as well as BEGIN and END keywords of the function body:
   - must each be defined in a single line
   - must not be indented
   - must not contain other code or comments
- If "enable_trace" is enabled then parameter definitions and return value definitions must follow this structure:
   - must each be defined in a single line
   - must not contain other code or comments
- No incomplete or ill-formed function/macro definitions in block comments
- If recursive=1: lines with INCLUDE/PATCH_INCLUDE statements must not contain other code or comments

INT_VAR recursive         Specifies whether to patch INCLUDE'd function in "include_path" as well. (Default: 0)
INT_VAR log_only          Specify 0 to print data to the standard output, or 1 to print data only to the log.
                          This parameter is only effective if "enable_trace" is enabled. (Default: 1)
INT_VAR enable_call       Specifies whether code for counting function/macro calls should be inserted. (Default: 1)
                          CAUTION: Enabling this parameter for a huge number of function calls may lead to a stack overflow
                          eventually on WeiDU 249 or older.
INT_VAR enable_stack      Specifies whether code for tracking function call hierarchies (which function calls which) should
                          be inserted. (Default: 1)
                          CAUTION: Enabling this parameter for a huge number of function calls may lead to a stack overflow
                          eventually on WeiDU 249 or older.
INT_VAR enable_trace      Specifies whether code for printing function calls with their parameter and return values should be
                          inserted. (Default: 0)
                          CAUTION: Enabling this parameter for a huge number of function calls may lead to a stack overflow
                          eventually on WeiDU 249 or older.
INT_VAR enable_timing     Specifies whether code for measuring execution time of the function/macro should be inserted.
                          (Default: 1)
STR_VAR include_path      Path of the include file to patch.
STR_VAR prefix            Optional prefix for calling and timing labels. Prefix is separated by double colons (::) from the
                          timing label, if defined. (Default: empty)
RET include_path          Path of the temporary include file with diagnostic functionality.


DEFINE_DIMORPHIC_FUNCTION a7#profiling_print_function_call_stats
----------------------------------------------------------------
Action and patch function that produces a summary of the logged functions calls and prints it to the log or standard output.

INT_VAR log_only          Whether to print the output only to the log file. (Default: 1)
STR_VAR title             Title of the statistics. (Default: "Statistics:")
STR_VAR call_map_name     Name of the function call statistics map. Leave empty to generate automatically. (Default: empty)


DEFINE_DIMORPHIC_FUNCTION a7#profiling_print_function_hierarchy_stats
---------------------------------------------------------------------
Action and patch function that produces a summary of the logged function hierarchy calls and prints it to the log or standard
output.

INT_VAR log_only          Whether to print the output only to the log file. (Default: 1)
INT_VAR indent_size       Width (in spaces) of a single function indentation level. (Default: 4)
STR_VAR title             Title of the statistics. (Default: "Statistics:")
STR_VAR call_map_name     Name of the function hierarchy statistics map. Leave empty to generate automatically. (Default: empty)


DEFINE_DIMORPHIC_FUNCTION a7#profiling_get_call_map
---------------------------------------------------
Returns a map of function labels and their number of calls. It can be used to get access to the raw statistics.
This function is implicitly called by "a7#profiling_print_function_call_stats".

RET_ARRAY call_map        Map of ("<function_label> => <call_count>) entries.


DEFINE_DIMORPHIC_FUNCTION a7#profiling_get_hierarchy_map
--------------------------------------------------------
Returns a map of function call hierarchies and their number of calls. It can be used to get access to the raw statistics.
This function is implicitly called by "a7#profiling_print_function_hierarchy_stats".

RET_ARRAY hierarchy_map   Map of ("<function_call_chain> => <call_count>) entries.
                          A function call chain consists of function labels separated by right angle brackets (>).


*************
* Changelog *
*************

Version 1.0
- Initial release
