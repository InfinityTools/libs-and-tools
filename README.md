# Modding Resources

Loose collection of tools, scripts, libraries, functions, documentation, and other modding resources.

## Tools

*Binaries and shell scripts are located in the `bin` subfolder.*

### mod_batcher.sh

A Bash shell script for automating installation of whole mod setups from any given weidu.log in one go.


## Libraries and functions

*Libraries are located in the `lib` subfolder.*

### a7_are_lib.tph

A library that provides a great number of functions for patching ARE resources.

### a7_wed_lib.tph

A library that provides a great number of functions for patching WED resources.

### a7_profiling/a7_profiling.tph

A library with diagnostic functions for profiling WeiDU code.

### find_free_anim_slot.tph

Action and patch function for finding unoccupied creature animation slots.

### add_areas_lua.tpa

Action function that adds areas with their names to the area list of the debug console.

### number_convert.tpa

Action functions that convert numbers of arbitrary size between decimal and hexadecimal notation.

### format_number.tpa

Action and patch functions that convert a numeric value into a notation based on the specified parameters and back to a numeric value.

### add_splprot_entry.tpa

Action function that adds a new entry to SPLPROT.2DA and returns its index. If an identical entry already exists it will return the index of that entry instead.

### auto_apply_spl_effect.tpp

A wrapper function for batch-adding spell effects to items or spells based on a code string.

### get_file_list.tpa

Action and patch function that scans the given folder, optionally recursively, for files matching a regular expression pattern and returns them in a list.

### lookup_2da_entries.tpp

Patch function that scans the current 2DA file for a matching entry (value) in the specified column and returns the associated first column value.

### regex.tpa

Collection of popular regular expression character codes and classes.

### res_types.tpa

Resource types supported by Infinity Engine games.
