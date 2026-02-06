WeiDU ARE Library
~~~~~~~~~~~~~~~~~

Version:  1.0
Author:   Argent77
License:  MIT


*********************
* Table of Contents *
*********************

1. Overview
2. ARE functions
  2.1. Standalone functions
    - a7#are_create
  2.2.Open/close functions for batch processing
    - a7#are_open
    - a7#are_close
  2.3. Query functions
    - a7#batch_are_get_info
    - a7#batch_are_get_actor
    - a7#batch_are_get_region
    - a7#batch_are_get_spawnpoint
    - a7#batch_are_get_entrance
    - a7#batch_are_get_container
    - a7#batch_are_get_container_item
    - a7#batch_are_get_ambient
    - a7#batch_are_get_variable
    - a7#batch_are_get_explored
    - a7#batch_are_get_door
    - a7#batch_are_get_animation
    - a7#batch_are_get_songs
    - a7#batch_are_get_rest
    - a7#batch_are_get_automap
    - a7#batch_are_get_projectile
  2.4. Patch functions
    - a7#batch_are_alter_attributes
    - a7#batch_are_add_actor
    - a7#batch_are_alter_actor
    - a7#batch_are_remove_actor
    - a7#batch_are_move_actor
    - a7#batch_are_add_region
    - a7#batch_are_alter_region
    - a7#batch_are_remove_region
    - a7#batch_are_move_region
    - a7#batch_are_scale_region
    - a7#batch_are_add_spawnpoint
    - a7#batch_are_alter_spawnpoint
    - a7#batch_are_remove_spawnpoint
    - a7#batch_are_move_spawnpoint
    - a7#batch_are_add_entrance
    - a7#batch_are_alter_entrance
    - a7#batch_are_remove_entrance
    - a7#batch_are_move_entrance
    - a7#batch_are_add_container
    - a7#batch_are_alter_container
    - a7#batch_are_remove_container
    - a7#batch_are_move_container
    - a7#batch_are_scale_container
    - a7#batch_are_add_container_item
    - a7#batch_are_alter_container_item
    - a7#batch_are_remove_container_item
    - a7#batch_are_add_ambient
    - a7#batch_are_alter_ambient
    - a7#batch_are_remove_ambient
    - a7#batch_are_move_ambient
    - a7#batch_are_add_variable
    - a7#batch_are_alter_variable
    - a7#batch_are_remove_variable
    - a7#batch_are_set_explored
    - a7#batch_are_clear_explored
    - a7#batch_are_alter_explored
    - a7#batch_are_add_door
    - a7#batch_are_alter_door
    - a7#batch_are_remove_door
    - a7#batch_are_move_door
    - a7#batch_are_scale_door
    - a7#batch_are_add_animation
    - a7#batch_are_alter_animation
    - a7#batch_are_remove_animation
    - a7#batch_are_move_animation
    - a7#batch_are_alter_songs
    - a7#batch_are_alter_rest
    - a7#batch_are_add_automap
    - a7#batch_are_alter_automap
    - a7#batch_are_remove_automap
    - a7#batch_are_move_automap
    - a7#batch_are_add_projectile
    - a7#batch_are_alter_projectile
    - a7#batch_are_remove_projectile
    - a7#batch_are_move_projectile
3. Changelog


***************
* 1. Overview *
***************

This library provides WeiDU functions for creating, querying, and patching ARE resources.

Parsing ARE files by the WeiDU interpreter can be slow. For that reason the library allows to batch-process ARE files
in one go by the functions described below.

Example of patching an ARE file:
// Patching BG2 "Athkatla City Gates" ARE file 
COPY_EXISTING "AR0020.ARE" "override"
  // prepares the ARE data for patching
  LPF a7#are_open RET success RET_ARRAY are END

  // adds a new automap note
  LPF a7#batch_are_add_automap
    INT_VAR
      loc_x = 936
      loc_y = 226
      note_strref = RESOLVE_STR_REF("City Gates")
      color = IDS_OF_SYMBOL("MAPNOTES" "PURPLE")
    RET success index
    RET_ARRAY are   // "are" handle must be returned to make the changes visible to subsequent operations
  END
  PATCH_IF (success) BEGIN
    PATCH_PRINT "Added new automap note at index %index%"
  END ELSE BEGIN
    PATCH_WARN ~WARNING: Automap note could not be added.~
  END

  // writes any changes back to the ARE file
  LPF a7#are_close RET success END
BUT_ONLY


********************
* 2. ARE functions *
********************

The following function can be found in the library "a7_are_lib.tph".


2.1. Standalone functions
*************************

DEFINE_ACTION_FUNCTION a7#are_create
------------------------------------
Action function that creates an empty ARE file.

INT_VAR preset            Specify 1 to populate the "Songs" and "Rest Encounters" structures with sane default values.
                          (Default: 0)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR resref            Resource reference of the resulting ARE file. Length must not exceed 8 characters.
STR_VAR path              Destination folder for ARE file. (Default: "override")
STR_VAR version           ARE version to create. Supported versions are "V1.0" and "V9.1". (Default: autodetected)
RET success               Returns 1 if the operation was successful, 0 otherwise.


2.2. Open/close functions for batch processing
**********************************************

These functions are required to perform batch operations on the ARE file. "a7#are_open" is required for any query
or patch functions. "a7#are_close" is only required after calling patch functions.

DEFINE_PATCH_FUNCTION a7#are_open
---------------------------------
Patch function that opens the current ARE file and returns an ARE handle for further editing.

IMPORTANT: Only after calling "a7#are_open" batch functions can be used to modify ARE content.

RET success               Returns 1 on success and 0 on error.
RET_ARRAY are             Returns a handle of the initialized ARE structure if "success" returns 1.
                          The name of this handle must be specified as parameter for the "a7#batch_xxx" functions.

DEFINE_PATCH_FUNCTION a7#are_close
----------------------------------
Patch function that writes all modifications made by batch functions back to the ARE file.

STR_VAR are               Name of the ARE array structure. (Default: "are")
RET success               Returns 1 on success and 0 on error.


2.3. Query functions
********************

These function perform only read operations on the specified ARE handle and therefore don't require a final call
of "a7#are_close".

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_info
-----------------------------------------------
Action and patch function that returns general information about the ARE handle.

STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET version               Returns the version string of the ARE handle.
RET num_actors            Returns the number of available actor structures.
RET num_regions           Returns the number of available region structures.
RET num_spawnpoints       Returns the number of available spawn point structures.
RET num_entrances         Returns the number of available entrance structures.
RET num_containers        Returns the number of available container structures.
RET num_ambients          Returns the number of available ambient sound structures.
RET num_variables         Returns the number of available variable structures.
RET num_doors             Returns the number of available door structures.
RET num_animations        Returns the number of available animation structures.
RET num_tile              Returns the number of available tiled object structures.
RET num_automaps          Returns the number of available automap note structures.
RET num_projectiles       Returns the number of available projectile trap structures.

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_actor
--------------------------------------------------
Action and patch function that returns actor information from the ARE handle.

INT_VAR index             Index of the actor structure to query information about. Omit if you specify the actor structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the actor structure to query. Omit if you specify the actor structure by index.
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY actor           Returns an associative array with information about the specified actor structure.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_add_actor" function,
                          e.g. $actor("loc_x").
                          Exceptions:
                          - $actor("cre_embedded") Returns the CRE data buffer as string if available.
                          - $actor("cre_name_alt"): Returns the alternate actor name for embedded CRE resources (V1.0 only).
                          Note: Some fields are version-specific.

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_region
----------------------------------------------------
Action and patch function that returns region information from the ARE handle.

INT_VAR index             Index of the region structure to query information about. Omit if you specify the region structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the region structure to query. Omit if you specify the region structure by index.
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY region          Returns an associative array with information about the specified region structure.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_add_region" function,
                          e.g. $region("type"). Field names for the bounding box are named "min_x", "max_x", ...
                          Region vertices are stored as combined X/Y coordinates in $region("vertex" "<idx>").
                          $region("vertex") contains the number of vertex entries.

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_spawnpoint
-----------------------------------------------
Action and patch function that returns spawn point information from the ARE handle.

INT_VAR index             Index of the spawn point structure to query information about. Omit if you specify the spawn point structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the spawn point structure to query. Omit if you specify the spawn point structure by index.
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY spawnpoint      Returns an associative array with information about the specified spawn point structure.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_add_spawnpoint" function,
                          e.g. $spawnpoint("loc_x").

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_entrance
----------------------------------------------------
Action and patch function that returns entrance information from the ARE handle.

INT_VAR index             Index of the entrance structure to query information about. Omit if you specify the entrance structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the entrance structure to query. Omit if you specify the entrance structure by index.
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY entrance        Returns an associative array with information about the specified entrance structure.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_add_entrance" function,
                          e.g. $entrance("loc_x").

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_container
----------------------------------------------------
Action and patch function that returns container information from the ARE handle.

INT_VAR index             Index of the container structure to query information about. Omit if you specify the container structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the container structure to query. Omit if you specify the container structure by index.
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY container       Returns an associative array with information about the specified container structure.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_add_container" function,
                          e.g. $container("loc_x"). Field names for the bounding box are named "min_x", "max_x", ...
                          Container items are stored in $container("item" "<idx>") entries. They provide the same fields as item arrays returned
                          by "a7#batch_are_get_container_item". $container("item") contains the number of item entries.
                          Container vertices are stored as combined X/Y coordinates in $container("vertex" "<idx>").
                          $container("vertex") contains the number of vertex entries.

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_container_item
---------------------------------------------------------
Action and patch function that returns container item information from the ARE handle.

INT_VAR container_index   Index of the container structure. Omit if you specify the container structure by name.
INT_VAR index             Index of the container item structure to query information about. (Default: -1)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR container_name    Name of the container structure. Omit if you specify the container structure by index.
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY item            Returns an associative array with information about the specified container item structure.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_add_container_item" function,
                          e.g. $item("item_resref").

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_ambient
--------------------------------------------------
Action and patch function that returns ambient sound information from the ARE handle.

INT_VAR index             Index of the ambient sound structure to query information about. Omit if you specify the ambient sound structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the ambient sound structure to query. Omit if you specify the ambient sound structure by index.
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY ambient         Returns an associative array with information about the specified ambient sound structure.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_add_ambient" function,
                          e.g. $ambient("loc_x").

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_variable
---------------------------------------------------
Action and patch function that returns variable information from the ARE handle.

INT_VAR index             Index of the variable structure to query information about. Omit if you specify the variable structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the variable to query. Omit if you specify the variable structure by index.
RET success               Returns 1 if the query was successful, 0 otherwise.
RET name                  Returns the name of the variable.
RET value                 Returns the value of the variable.

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_explored
---------------------------------------------------
Action and patch function that returns explored bitmap data from the ARE handle.

INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
RET success               Returns 1 if the query was successful, 0 otherwise.
RET explored              Returns explored bitmap information as a string. Returns an empty string if the area
                          doesn't have any explored bitmap data defined.

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_door
-----------------------------------------------
Action and patch function that returns door information from the ARE handle.

INT_VAR index             Index of the door structure to query information about. Omit if you specify the door structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the door structure to query. Omit if you specify the door structure by index.
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY door            Returns an associative array with information about the specified door structure.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_add_door" function,
                          e.g. $door("flags"). Field names for bounding boxes are named "min_x_open", "max_x_open", "min_x_closed", ...
                          Container vertices and impeded cells are stored as combined X/Y coordinates in $container("vertex_open" "<idx>"),
                          $container("vertex_closed" "<idx>"), $container("cell_closed" "<idx>"), and $container("cell_closed" "<idx>") respectively.
                          $container("vertex_open"), etc., contains the number of vertex or cell entries.

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_animation
----------------------------------------------------
Action and patch function that returns animation information from the ARE handle.

INT_VAR index             Index of the animation structure to query information about. Omit if you specify the animation structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the animation structure to query. Omit if you specify the animation structure by index.
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY animation       Returns an associative array with information about the specified animation structure.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_add_animation" function,
                          e.g. $animation("loc_x").

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_songs
------------------------------------------------
Action and patch function that returns songs information from the ARE handle.

INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY songs           Returns an associative array with information about the songs structure of the area.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_alter_songs" function,
                          e.g. $songs("song_day").

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_rest
-----------------------------------------------
Action and patch function that returns rest encounter information from the ARE handle.

INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY rest            Returns an associative array with information about the rest encounter structure of the area.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_alter_rest" function,
                          e.g. $rest("spawn_num").

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_automap
--------------------------------------------------
Action and patch function that returns automap note information from the ARE handle.

INT_VAR index             Index of the automap note structure to query information about. (Default: -1)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY automap         Returns an associative array with information about the specified automap note structure.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_add_automap" function,
                          e.g. $automap("loc_x").

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_get_projectile
-----------------------------------------------------
Action and patch function that returns projectile trap information from the ARE handle.

INT_VAR index             Index of the projectile trap structure to query information about. (Default: -1)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
RET success               Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY projectile      Returns an associative array with information about the specified projectile trap structure.
                          Array fields are the same as the structure-specific parameters from the "a7#batch_are_add_projectile" function,
                          e.g. $projectile("missile_num").
                          Projectile trap effects are stored as raw EFF V2 data strings in $projectile("embedded_eff" "<idx>").
                          Their content can be accessed by the INNER/OUTER_PATCH commands.
                          $projectile("embedded_eff") contains the number of effect entries.



2.4. Patch functions
********************

These functions perform read and write operations on the specified ARE handle. They must be finalized by a call
of "a7#are_close" to make the changes persistent.

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_attributes
-------------------------------------------------------
INT_VAR last_saved              New time stamp of the last save (seconds, in real time). (Default: no change)
INT_VAR area_flags              New area flags (see AREAFLAG.IDS). (Default: no change)
INT_VAR area_flags_north        New flags for the ARE resref linked to the northern edge of the map. (Default: no change)
INT_VAR area_flags_east         New flags for the ARE resref linked to the eastern edge of the map. (Default: no change)
INT_VAR area_flags_south        New flags for the ARE resref linked to the southern edge of the map. (Default: no change)
INT_VAR area_flags_west         New flags for the ARE resref linked to the western edge of the map. (Default: no change)
INT_VAR area_type               New area type flags (see AREATYPE.IDS). (Default: no change)
INT_VAR probability_rain        New rain probability (range: 0-100). (Default: no change)
INT_VAR probability_snow        New snow probability (range: 0-100). (Default: no change)
INT_VAR probability_fog         New fog probability (range: 0-100). (Default: no change)
INT_VAR probability_lightning   New lightning probability (range: 0-100). (Default: no change)
INT_VAR overlay_transparency    (EE only) New overlay transparency for water and other secondary overlays (range: 0-255). (Default: no change)
INT_VAR area_difficulty_1       (IWD2 only) New average party level
INT_VAR area_difficulty_2       (IWD2 only) New average party level requirement for Area difficulty level 2. (Default: no change)
INT_VAR area_difficulty_3       (IWD2 only) New average party level requirement for Area difficulty level 3. (Default: no change)
INT_VAR silent                  Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                     Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                                Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR version                 New ARE file version. Supported version strings are "V9.1" for IWD2-compatible area and "V1.0"
                                for all other games. Don't change this attribute unless you know what you're doing. (Default: no change)
STR_VAR wed_resref              New WED resref. (Default: no change)
STR_VAR area_resref_north       New ARE resref linked to the northern edge of the map. (Default: no change)
STR_VAR area_resref_east        New ARE resref linked to the eastern edge of the map. (Default: no change)
STR_VAR area_resref_south       New ARE resref linked to the southern edge of the map. (Default: no change)
STR_VAR area_resref_west        New ARE resref linked to the western edge of the map. (Default: no change)
STR_VAR area_script             New BCS resref for a new area script. (Default: no change)
STR_VAR rest_movie_day          (BG2 and EE only) New MVE or WBM movie resref for the morning cinematic. (Default: no change)
STR_VAR rest_movie_night        (BG2 and EE only) New MVE or WBM movie resref for the evening cinematic. (Default: no change)
RET success                     Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%                 Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                                (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_add_actor
------------------------------------------------
Action and patch function that adds a new actor to the ARE handle.

INT_VAR loc_x                 Current X coordinate of the actor. (Default: 0)
INT_VAR loc_y                 Current Y coordinate of the actor. (Default: 0)
INT_VAR dest_x                Destination X coordinate of the actor. (Default: same as "loc_x")
INT_VAR dest_y                Destination Y coordinate of the actor. (Default: same as "loc_y")
INT_VAR flags                 Actor flags. (Default: 1 / CRE not embedded)
INT_VAR is_spawned            Whether the actor is a spawned creature. (Default: 0)
INT_VAR area_difficulty       (IWD2) Area difficulty mask. (Default: 0)
INT_VAR animation             Actor animation id (not used by the engine). (Default: from specified CRE)
INT_VAR orientation           Actor orientation. (0=South, 4=West, 8=North, 12=East). (Default: 0)
INT_VAR expiry                Actor removal timer in absolute ticks. (Default: -1 / never)
INT_VAR wander_distance       Movement restriction distance. (Default: 0)
INT_VAR follow_distance       Movement restriction distance (move to object). (Default: 0)
INT_VAR schedule              Actor hourly appearance schedule. Each bit refers to a specific hour of the day. (Default: always active)
INT_VAR num_times_talked_to   NumTimesTalkedTo() the actor. (Default: 0)
INT_VAR silent                Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                   Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                              Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name                  Name of the actor. May not be longer than 32 characters. (Default: empty string)
STR_VAR dlg_resref            Dialog resref. (Default: empty resref)
STR_VAR bcs_override          Override script. (Default: empty resref)
STR_VAR bcs_general           General script. (Default: empty resref)
STR_VAR bcs_class             Class script. (Default: empty resref)
STR_VAR bcs_race              Race script. (Default: empty resref)
STR_VAR bcs_default           Default script. (Default: empty resref)
STR_VAR bcs_specific          Specific script. (Default: empty resref)
STR_VAR bcs_special1          (IWD2) Special 1 script. (Default: empty resref)
STR_VAR bcs_special2          (IWD2) Special 2 script. (Default: empty resref)
STR_VAR bcs_special3          (IWD2) Special 3 script. (Default: empty resref)
STR_VAR bcs_combat            (IWD2) Combat script. (Default: empty resref)
STR_VAR bcs_movement          (IWD2) Movement script. (Default: empty resref)
STR_VAR bcs_team              (IWD2) Team script. (Default: empty resref)
STR_VAR cre_resref            The actor's CRE resref. (Default: empty resref)
STR_VAR cre_embedded          CRE data string, full path to the CRE file, or resref of the CRE resource that should be embedded in the
                              actor structure. Only considered if "flags" are set to embed CRE data. (Default: uses "cre_resref" if not set)
RET success                   Returns 1 if the operation was successful, 0 otherwise.
RET index                     Returns the index of the added actor structure if successful, -1 otherwise
RET_ARRAY %are%               Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                              (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_actor
--------------------------------------------------
Action and patch function that alters attributes of an existing actor structure on the ARE handle.

INT_VAR actor_index           Index of the actor structure to patch. Omit if you specify the actor structure by name.
INT_VAR loc_x                 New current X coordinate of the actor. (Default: no change)
INT_VAR loc_y                 New current Y coordinate of the actor. (Default: no change)
INT_VAR dest_x                New destination X coordinate of the actor. (Default: no change)
INT_VAR dest_y                New destination Y coordinate of the actor. (Default: no change)
INT_VAR flags                 New actor flags. (Default: no change)
INT_VAR is_spawned            New value for whether the actor is a spawned creature. (Default: no change)
INT_VAR area_difficulty       (IWD2) New area difficulty mask. (Default: no change)
INT_VAR animation             New actor animation id (not used by the engine). (Default: no change)
INT_VAR orientation           New actor orientation (0=South, 4=West, 8=North, 12=East). (Default: no change)
INT_VAR expiry                New actor removal timer in absolute ticks. (Default: no change)
INT_VAR wander_distance       New movement restriction distance. (Default: no change)
INT_VAR follow_distance       New movement restriction distance (move to object). (Default: no change)
INT_VAR schedule              New hourly appearance schedule. Each bit refers to a specific hour of the day. (Default: no change)
INT_VAR num_times_talked_to   New NumTimesTalkedTo() value of the actor. (Default: no change)
INT_VAR silent                Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                   Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                              Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR actor_name            Name of the actor structure to patch. Omit if you specify the actor structure by index.
STR_VAR name                  New name of the actor. May not be longer than 32 characters. (Default: no change)
STR_VAR dlg_resref            New dialog resref. (Default: no change)
STR_VAR bcs_override          New override script. (Default: no change)
STR_VAR bcs_general           New general script. (Default: no change)
STR_VAR bcs_class             New class script. (Default: no change)
STR_VAR bcs_race              New race script. (Default: no change)
STR_VAR bcs_default           New default script. (Default: no change)
STR_VAR bcs_specific          New specific script. (Default: no change)
STR_VAR bcs_special1          (IWD2) New special 1 script. (Default: no change)
STR_VAR bcs_special2          (IWD2) New special 2 script. (Default: no change)
STR_VAR bcs_special3          (IWD2) New special 3 script. (Default: no change)
STR_VAR bcs_combat            (IWD2) New combat script. (Default: no change)
STR_VAR bcs_movement          (IWD2) New movement script. (Default: no change)
STR_VAR bcs_team              (IWD2) New team script. (Default: no change)
STR_VAR cre_resref            New actor's CRE resref. (Default: no change)
STR_VAR cre_embedded          New embedded CRE as data string, full path to the CRE file, or resref of the CRE resource. Only considered
                              if "flags" are set to embed CRE data. (Default: no change)
RET success                   Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%               Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                              (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_remove_actor
---------------------------------------------------
Action and patch function that removes an existing actor structure from the ARE handle.

INT_VAR actor_index       Index of the actor structure to remove. Omit if you specify the actor structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR actor_name        Name of the actor structure to remove. Omit if you specify the actor structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_move_actor
-------------------------------------------------
Action and patch function that moves the position or changes the orientation of an actor on the ARE handle by a specified amount in either direction.

INT_VAR actor_index       Index of the actor structure to move. Omit if you specify the actor structure by name.
INT_VAR x                 Amount to move in horizontal direction. Specify positive values to move to the right and negative values to move to the left.
INT_VAR y                 Amount to move in vertical direction. Specify positive values to move downwards and negative values to move upwards.
INT_VAR turn              Amount of units to advance the actor's orientation. A full turn consists of 16 units. Specify positive values to turn in
                          clockwise direction and negative values to turn in counter-clockwise direction.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR actor_name        Name of the actor structure to move. Omit if you specify the actor structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_add_region
-------------------------------------------------
Action and patch function that adds a new region to the ARE handle.

INT_VAR type                Region type (0=proximity trigger, 1=info point, 2=travel region). (Default: 0)
INT_VAR cursor_idx          Cursor index (CURSORS.BAM). (Default: 0)
INT_VAR flags               Region flags. (Default: 0)
INT_VAR info_point_strref   Strref of information text (for info points). (Default: -1)
INT_VAR trap_detect         Trap detection difficulty (%). (Default: 0)
INT_VAR trap_remove         Trap removal difficulty (%). (Default: 0)
INT_VAR trap_active         Whether the region is trapped. (Default: 0)
INT_VAR trap_status         Whether the region trap has been detected. (Default: 0)
INT_VAR loc_x               X coordinate of the trap launch location. (Default: 0)
INT_VAR loc_y               Y coordinate of the trap launch location. (Default: 0)
INT_VAR alt_x               X coordinate of the alternative use point. (IWD2: X coordinate of the override use point.) (Default: 0)
INT_VAR alt_y               Y coordinate of the alternative use point. (IWD2: Y coordinate of the override use point.) (Default: 0)
INT_VAR alt2_x              (IWD2) X coordinate of the alternative use point. (Default: 0)
INT_VAR alt2_y              (IWD2) Y coordinate of the alternative use point. (Default: 0)
INT_VAR talk_loc_x          (PST/PSTEE) X coordinate of the talk location. (Default: 0)
INT_VAR talk_loc_y          (PST/PSTEE) Y coordinate of the talk location. (Default: 0)
INT_VAR speaker_strref      (PST/PSTEE) Strref of the speaker name. (Default: -1)
INT_VAR num_vertices        Number of region vertices to add. (Default: 0)
INT_VAR vertex_0, ...       Array "vertex" with "num_vertices" vertex coordinates, as "X coordinate | (Y coordinate << 16)".
                            Alternate notation: $vertex("0"), ...
INT_VAR silent              Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                 Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                            Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name                Name of the region. May not be longer than 32 characters. (Default: empty string)
STR_VAR destination_area    Resref of the destination area (for travel regions). (Default: empty resref)
STR_VAR destination_name    Entrance name in the destination area (for travel regions). (Default: empty string)
STR_VAR key_resref          Resref of a key item. (Default: empty resref)
STR_VAR script_resref       Resref of the region script. (Default: empty resref)
STR_VAR sound_resref        (PST/PSTEE) Resref of an associated sound. (Default: empty resref)
STR_VAR dialog_resref       (PST/PSTEE) Resref of a dialog file. (Default: empty resref)
RET success                 Returns 1 if the operation was successful, 0 otherwise.
RET index                   Returns the index of the added region structure if successful, -1 otherwise
RET_ARRAY %are%             Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                            (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_region
---------------------------------------------------
Action and patch function that alters attributes of an existing region structure on the ARE handle.

INT_VAR region_index        Index of the region structure to patch. Omit if you specify the region structure by name.
INT_VAR type                New region type (0=proximity trigger, 1=info point, 2=travel region). (Default: no change)
INT_VAR cursor_idx          New cursor index (CURSORS.BAM). (Default: no change)
INT_VAR flags               New region flags. (Default: no change)
INT_VAR info_point_strref   New strref of information text (for info points). (Default: no change)
INT_VAR trap_detect         New trap detection difficulty (%). (Default: no change)
INT_VAR trap_remove         New trap removal difficulty (%). (Default: no change)
INT_VAR trap_active         New value for whether the region is trapped. (Default: no change)
INT_VAR trap_status         New value for whether the region trap has been detected. (Default: no change)
INT_VAR loc_x               New X coordinate of the trap launch location. (Default: no change)
INT_VAR loc_y               New Y coordinate of the trap launch location. (Default: no change)
INT_VAR alt_x               New X coordinate of the alternative use point. (IWD2: X coordinate of the override use point.) (Default: no change)
INT_VAR alt_y               New Y coordinate of the alternative use point. (IWD2: Y coordinate of the override use point.) (Default: no change)
INT_VAR alt2_x              (IWD2) New X coordinate of the alternative use point. (Default: no change)
INT_VAR alt2_y              (IWD2) New Y coordinate of the alternative use point. (Default: no change)
INT_VAR talk_loc_x          (PST/PSTEE) New X coordinate of the talk location. (Default: no change)
INT_VAR talk_loc_y          (PST/PSTEE) New Y coordinate of the talk location. (Default: no change)
INT_VAR speaker_strref      (PST/PSTEE) New strref of the speaker name. (Default: no change)
INT_VAR num_vertices        New number of region vertices. If this parameter is specified then the current region vertices are updated
                            with the specified vertex definitions. (Default: no change)
INT_VAR vertex_0, ...       Array "vertex" with "num_vertices" vertex coordinates, as "X coordinate | (Y coordinate << 16)".
                            Alternate notation: $vertex("0"), ...
                            Skip entries or assign the constant "A7_ARE_NO_CHANGE" to keep the original vertex value.
                            Skipping definitions or using the constant for non-existing vertices will trigger an error.
                            This array is only considered if "num_vertices" is defined.
INT_VAR silent              Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                 Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                            Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR region_name         Name of the region structure to patch. Omit if you specify the region structure by index.
STR_VAR name                New name of the region. May not be longer than 32 characters. (Default: no change)
STR_VAR destination_area    New resref of the destination area (for travel regions). (Default: no change)
STR_VAR destination_name    New entrance name in the destination area (for travel regions). (Default: no change)
STR_VAR key_resref          New resref of a key item. (Default: no change)
STR_VAR script_resref       New resref of the region script. (Default: no change)
STR_VAR sound_resref        (PST/PSTEE) New resref of an associated sound. (Default: no change)
STR_VAR dialog_resref       (PST/PSTEE) New resref of a dialog file. (Default: no change)
RET success                 Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%             Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                            (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_remove_region
----------------------------------------------------
Action and patch function that removes an existing region structure from the ARE handle.

INT_VAR region_index      Index of the region structure to remove. Omit if you specify the region structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR region_name       Name of the region structure to remove. Omit if you specify the region structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_move_region
--------------------------------------------------
Action and patch function that moves the position of a region on the ARE handle by a specified amount in either direction.

INT_VAR region_index      Index of the region structure to move. Omit if you specify the region structure by name.
INT_VAR x                 Amount to move in horizontal direction. Specify positive values to move to the right and negative values to move to the left.
INT_VAR y                 Amount to move in vertical direction. Specify positive values to move downwards and negative values to move upwards.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR region_name       Name of the region structure to move. Omit if you specify the region structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_scale_region
---------------------------------------------------
Action and patch function that scales a region polygon on the ARE handle by a specified factor in either direction.

INT_VAR region_index      Index of the region structure to scale. Omit if you specify the region structure by name.
INT_VAR scale_x           Indicates whether to scale horizontally. (Default: 1)
INT_VAR scale_y           Indicates whether to scale vertically. (Default: 1)
INT_VAR numerator         Numerator (top value of a fraction) of the scaling factor. (Default: 1)
                          Note: A negative fractional value will mirror the polygon vertex coordinates around the anchor point.
INT_VAR denominator       Denominator (bottom value of a fraction) of the scaling factor. Must not be 0. (Default: 1)
                          Note: A negative fractional value will mirror the polygon vertex coordinates around the anchor point.
INT_VAR x                 If "custom" anchor is specified then this value defines the absolute x coordinate of the anchor point. (Default: 0)
INT_VAR y                 If "custom" anchor is specified then this value defines the absolute y coordinate of the anchor point. (Default: 0)
INT_VAR polygon_only      Specify 1 to scale only the region polygon vertices. Specify 0 to scale location coordinates as well. (Default: 1)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR region_name       Name of the region structure to remove. Omit if you specify the region structure by index.
STR_VAR anchor            Anchor point for the scaling operation. Relative movement of the vertices is centered on this position. (Default: "origin")
                          Supported anchor points:
                          - origin:                 Uses absolute coordinates (0,0) as anchor point
                          - custom:                 Uses parameters x and y as anchor point coordinates
                          - relative_top_left:      Uses top-left bounding box coordinates as anchor point
                          - relative_top_center:    Uses top-horizontal center bounding box coordinates as anchor point
                          - relative_top_right:     Uses top-right bounding box coordinates as anchor point
                          - relative_center_left:   Uses vertical center-left bounding box coordinates as anchor point
                          - relative_center_right:  Uses vertical center-right bounding box coordinates as anchor point
                          - relative_bottom_left:   Uses bottom-left bounding box coordinates as anchor point
                          - relative_bottom_center: Uses bottom-horizontal center bounding box coordinates as anchor point
                          - relative_bottom_right:  Uses bottom-right bounding box coordinates as anchor point
                          - relative_center:        Uses the (horizontal and vertical) center of the bounding box coordinates as anchor point
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_add_spawnpoint
-----------------------------------------------------
Action and patch function that adds a new spawn point to the ARE handle.

INT_VAR loc_x               X coordinate of the spawn point. (Default: 0)
INT_VAR loc_y               Y coordinate of the spawn point. (Default: 0)
INT_VAR spawn_num           Count of spawn creatures. (Default: 0)
INT_VAR difficulty          Base number of creatures to spawn. (Default: 0)
                            Formula: # spawns = (delay * avg. party level) / creature power. Results are rounded down.
INT_VAR delay               Delay between spawning, in seconds. (Default: 10)
INT_VAR method              Spawn method. (Default: 0)
INT_VAR duration            Creature removal timer, in seconds. Specify -1 to avoid removal. (Default: 1000)
INT_VAR wander_distance     Movement restriction distance. (Default: 1000)
INT_VAR follow_distance     Movement restriction distance (move to object). (Default: 1000)
INT_VAR max_num             Max. number of creatures to spawn. (Default: 0)
INT_VAR active              Whether the spawn point is active. (Default: 1)
INT_VAR schedule            Hourly appearance schedule. (Default: always active)
INT_VAR day_prob            Daytime probability. (Default: 100)
INT_VAR night_prob          Nighttime probability. (Default: 100)
INT_VAR spawn_freq          (EE) Spawn frequency, in seconds. (Default: 0)
INT_VAR countdown           (EE) Spawn countdown. (Default: 0)
INT_VAR weight0, ...        Weight of the spawn creatures. Range: weight0 ... weight9. (Default: 0)
INT_VAR silent              Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                 Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                            Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name                Name of the spawn point. May not be longer than 32 characters. (Default: empty string)
STR_VAR cre_resref0, ...    Resref of the creature to spawn. Range: cre_resref0 ... cre_resref9. (Default: empty string)
RET success                 Returns 1 if the operation was successful, 0 otherwise.
RET index                   Returns the index of the added spawn point structure if successful, -1 otherwise
RET_ARRAY %are%             Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                            (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_spawnpoint
-------------------------------------------------------
Action and patch function that alters attributes of an existing spawn point structure on the ARE handle.

INT_VAR spawnpoint_index    Index of the spawn point structure to patch. Omit if you specify the spawn point structure by name.
INT_VAR loc_x               New X coordinate of the spawn point. (Default: no change)
INT_VAR loc_y               New Y coordinate of the spawn point. (Default: no change)
INT_VAR spawn_num           New count of spawn creatures. (Default: no change)
INT_VAR difficulty          New base number of creatures to spawn. (Default: no change)
                            Formula: # spawns = (delay * avg. party level) / creature power. Results are rounded down.
INT_VAR delay               New delay between spawning, in seconds. (Default: no change)
INT_VAR method              New spawn method. (Default: no change)
INT_VAR duration            New creature removal timer, in seconds. Specify -1 to avoid removal. (Default: no change)
INT_VAR wander_distance     New movement restriction distance. (Default: no change)
INT_VAR follow_distance     New movement restriction distance (move to object). (Default: no change)
INT_VAR max_num             New max. number of creatures to spawn. (Default: no change)
INT_VAR active              New value for whether the spawn point is active. (Default: no change)
INT_VAR schedule            New hourly appearance schedule. (Default: no change)
INT_VAR day_prob            New daytime probability. (Default: no change)
INT_VAR night_prob          New nighttime probability. (Default: no change)
INT_VAR spawn_freq          (EE) New spawn frequency, in seconds. (Default: no change)
INT_VAR countdown           (EE) New spawn countdown. (Default: no change)
INT_VAR weight0, ...        New weight of the spawn creatures. Range: weight0 ... weight9. (Default: no change)
INT_VAR silent              Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                 Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                            Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR spawnpoint_name     Name of the spawn point structure to patch. Omit if you specify the spawn point structure by index.
STR_VAR name                New name of the spawn point. May not be longer than 32 characters. (Default: no change)
STR_VAR cre_resref0, ...    New resref of the creature to spawn. Range: cre_resref0 ... cre_resref9. (Default: no change)
RET success                 Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%             Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                            (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_remove_spawnpoint
--------------------------------------------------------
Action and patch function that removes an existing spawn point structure from the ARE handle.

INT_VAR spawnpoint_index    Index of the spawn point structure to remove. Omit if you specify the spawn point structure by name.
INT_VAR silent              Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                 Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                            Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR spawnpoint_name     Name of the spawn point structure to remove. Omit if you specify the spawn point structure by index.
RET success                 Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%             Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                            (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_move_spawnpoint
------------------------------------------------------
Action and patch function that moves the position of a spawn point on the ARE handle by a specified amount in either direction.

INT_VAR spawnpoint_index    Index of the spawn point structure to move. Omit if you specify the spawn point structure by name.
INT_VAR x                   Amount to move in horizontal direction. Specify positive values to move to the right and negative values to move to the left.
INT_VAR y                   Amount to move in vertical direction. Specify positive values to move downwards and negative values to move upwards.
INT_VAR silent              Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                 Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                            Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR spawnpoint_name     Name of the spawn point structure to move. Omit if you specify the spawn point structure by index.
RET success                 Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%             Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                            (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_add_entrance
---------------------------------------------------
Action and patch function that adds a new entrance to the ARE handle.

INT_VAR loc_x             X coordinate of the entrance. (Default: 0)
INT_VAR loc_y             Y coordinate of the entrance. (Default: 0)
INT_VAR orientation       The facing direction. (0=South, 4=West, 8=North, 12=East). (Default: 0)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the entrance. May not be longer than 32 characters. (Default: empty string)
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET index                 Returns the index of the added entrance structure if successful, -1 otherwise
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_entrance
-----------------------------------------------------
Action and patch function that alters attributes of an existing entrance structure on the ARE handle.

INT_VAR entrance_index    Index of the entrance structure to patch. Omit if you specify the entrance structure by name.
INT_VAR loc_x             New X coordinate of the entrance. (Default: no change)
INT_VAR loc_y             New Y coordinate of the entrance. (Default: no change)
INT_VAR orientation       New facing direction. (0=South, 4=West, 8=North, 12=East). (Default: no change)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR entrance_name     Name of the entrance structure to patch. Omit if you specify the entrance structure by index.
STR_VAR name              New name of the entrance. May not be longer than 32 characters. (Default: no change)
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_remove_entrance
------------------------------------------------------
Action and patch function that removes an existing entrance structure from the ARE handle.

INT_VAR entrance_index    Index of the entrance structure to remove. Omit if you specify the entrance structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR entrance_name     Name of the entrance structure to remove. Omit if you specify the entrance structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_move_entrance
----------------------------------------------------
Action and patch function that moves the position of an entrance on the ARE handle by a specified amount in either direction.

INT_VAR entrance_index    Index of the entrance structure to move. Omit if you specify the entrance structure by name.
INT_VAR x                 Amount to move in horizontal direction. Specify positive values to move to the right and negative values to move to the left.
INT_VAR y                 Amount to move in vertical direction. Specify positive values to move downwards and negative values to move upwards.
INT_VAR turn              Amount of units to advance the orientation. A full turn consists of 16 units. Specify positive values to turn in
                          clockwise direction and negative values to turn in counter-clockwise direction.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR entrance_name     Name of the entrance structure to move. Omit if you specify the entrance structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_add_container
----------------------------------------------------
Action and patch function that adds a new container to the ARE handle.

INT_VAR loc_x               X coordinate of container access point. (Default: 0)
INT_VAR loc_y               Y coordinate of container access point. (Default: 0)
INT_VAR type                Container type. (Default: 0)
INT_VAR lock_diff           Lock difficulty. (Default: 100)
INT_VAR flags               Container flags. (Default: 0)
INT_VAR trap_detect         Trap detection difficulty. (Default: 0)
INT_VAR trap_remove_diff    Trap removal difficulty. (Default: 100)
INT_VAR trap_active         Whether container is trapped. (Default: 0)
INT_VAR trap_status         Whether container trap has been detected. (Default: 0)
INT_VAR trap_loc_x          Trap launch X coordinate. (Default: 0)
INT_VAR trap_loc_y          Trap launch Y coordinate. (Default: 0)
INT_VAR trigger_range       Activation range. (Default: 0)
INT_VAR break_difficulty    Lock break difficulty. (Default: 0)
INT_VAR lockpick_strref     Lockpick strref. (Default: -1)
INT_VAR num_items           Number of item definitions to add. (Default: 0)
INT_VAR num_vertices        Number of polygon vertices to add. (Default: 0)
INT_VAR vertex_0, ...       Array "vertex" with "num_vertices" vertex coordinates, as "X coordinate | (Y coordinate << 16)".
                            Alternate notation: $vertex("0"), ...
INT_VAR silent              Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                 Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                            Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name                Name of the container. May not be longer than 32 characters. (Default: empty string)
STR_VAR owner_name          Name of the container owner (script name). May not be longer than 32 characters. (Default: empty string)
STR_VAR trap_script         Resref of the trap script. (Default: empty string)
STR_VAR key_resref          Resref of the "key" item. (Default: empty string)
STR_VAR item_0, ...         Array "item" with "num_items" entries. An item entry consists of:
                            - STR_VAR item_X: The ITM resref itself (required)
                            - INT_VAR item_X_charge1: Item charges added to "item_X_charge1", "item_X_charge2", and "item_X_charge3". (Default: 0)
                            - INT_VAR item_X_flags: Item flags. (Default: 0)
                            - INT_VAR item_X_expiry: Item expiration time. (Not needed for item definitions outside of saved games.) (Default: 0)
                            Alternate notation: $item("0"), $item("0" "charge1"), $item("0" "flags"), ...
RET success                 Returns 1 if the operation was successful, 0 otherwise.
RET index                   Returns the index of the added container structure if successful, -1 otherwise
RET_ARRAY %are%             Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                            (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_container
------------------------------------------------------
Action and patch function that alters attributes of an existing container structure on the ARE handle.

INT_VAR container_index     Index of the container structure to patch. Omit if you specify the container structure by name.
INT_VAR loc_x               New X coordinate of container access point. (Default: no change)
INT_VAR loc_y               New Y coordinate of container access point. (Default: no change)
INT_VAR type                New container type. (Default: no change)
INT_VAR lock_diff           New lock difficulty. (Default: no change)
INT_VAR flags               New container flags. (Default: no change)
INT_VAR trap_detect         New trap detection difficulty. (Default: no change)
INT_VAR trap_remove_diff    New trap removal difficulty. (Default: no change)
INT_VAR trap_active         New value for whether container is trapped. (Default: no change)
INT_VAR trap_status         New value for whether container trap has been detected. (Default: no change)
INT_VAR trap_loc_x          New trap launch X coordinate. (Default: no change)
INT_VAR trap_loc_y          New trap launch Y coordinate. (Default: no change)
INT_VAR trigger_range       New activation range. (Default: no change)
INT_VAR break_difficulty    New lock break difficulty. (Default: no change)
INT_VAR lockpick_strref     New lockpick strref. (Default: no change)
INT_VAR num_vertices        New number of polygon vertices. If this parameter is specified then the current container vertices are updated
                            with the specified vertex definitions. (Default: no change)
INT_VAR vertex_0, ...       Array "vertex" with "num_vertices" vertex coordinates, as "X coordinate | (Y coordinate << 16)".
                            Alternate notation: $vertex("0"), ...
                            Skip entries or assign the constant "A7_ARE_NO_CHANGE" to keep the original vertex value.
                            Skipping definitions or using the constant for non-existing vertices will trigger an error.
                            This array is only considered if "num_vertices" is defined.
INT_VAR silent              Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                 Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                            Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR container_name      Name of the container structure to patch. Omit if you specify the container structure by index.
STR_VAR name                New name of the container. May not be longer than 32 characters. (Default: no change)
STR_VAR owner_name          New name of the container owner (script name). May not be longer than 32 characters. (Default: no change)
STR_VAR trap_script         New resref of the trap script. (Default: no change)
STR_VAR key_resref          New resref of the "key" item. (Default: no change)
RET success                 Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%             Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                            (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_remove_container
-------------------------------------------------------
Action and patch function that removes an existing container structure from the ARE handle.

INT_VAR container_index   Index of the container structure to remove. Omit if you specify the container structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR container_name    Name of the container structure to remove. Omit if you specify the container structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_move_container
-----------------------------------------------------
Action and patch function that moves the position of a container on the ARE handle by a specified amount in either direction.

INT_VAR container_index   Index of the container structure to move. Omit if you specify the container structure by name.
INT_VAR x                 Amount to move in horizontal direction. Specify positive values to move to the right and negative values to move to the left.
INT_VAR y                 Amount to move in vertical direction. Specify positive values to move downwards and negative values to move upwards.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR container_name    Name of the container structure to move. Omit if you specify the container structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_scale_container
------------------------------------------------------
Action and patch function that scales a container polygon on the ARE handle by a specified factor in either direction.

INT_VAR container_index   Index of the container structure to scale. Omit if you specify the container structure by name.
INT_VAR scale_x           Indicates whether to scale horizontally. (Default: 1)
INT_VAR scale_y           Indicates whether to scale vertically. (Default: 1)
INT_VAR numerator         Numerator (top value of a fraction) of the scaling factor. (Default: 1)
                          Note: A negative fractional value will mirror the polygon vertex coordinates around the anchor point.
INT_VAR denominator       Denominator (bottom value of a fraction) of the scaling factor. Must not be 0. (Default: 1)
                          Note: A negative fractional value will mirror the polygon vertex coordinates around the anchor point.
INT_VAR x                 If "custom" anchor is specified then this value defines the absolute x coordinate of the anchor point. (Default: 0)
INT_VAR y                 If "custom" anchor is specified then this value defines the absolute y coordinate of the anchor point. (Default: 0)
INT_VAR polygon_only      Specify 1 to scale only the container polygon vertices. Specify 0 to scale location coordinates as well. (Default: 1)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR container_name    Name of the container structure to remove. Omit if you specify the container structure by index.
STR_VAR anchor            Anchor point for the scaling operation. Relative movement of the vertices is centered on this position. (Default: "origin")
                          Supported anchor points:
                          - origin:                 Uses absolute coordinates (0,0) as anchor point
                          - custom:                 Uses parameters x and y as anchor point coordinates
                          - relative_top_left:      Uses top-left bounding box coordinates as anchor point
                          - relative_top_center:    Uses top-horizontal center bounding box coordinates as anchor point
                          - relative_top_right:     Uses top-right bounding box coordinates as anchor point
                          - relative_center_left:   Uses vertical center-left bounding box coordinates as anchor point
                          - relative_center_right:  Uses vertical center-right bounding box coordinates as anchor point
                          - relative_bottom_left:   Uses bottom-left bounding box coordinates as anchor point
                          - relative_bottom_center: Uses bottom-horizontal center bounding box coordinates as anchor point
                          - relative_bottom_right:  Uses bottom-right bounding box coordinates as anchor point
                          - relative_center:        Uses the (horizontal and vertical) center of the bounding box coordinates as anchor point
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_add_container_item
---------------------------------------------------------
Action and patch function that adds a new item to a container in the ARE handle.

INT_VAR container_index   Index of the container where the item should be added. Omit if you specify the container by name.
INT_VAR item_index        Index of the item to insert. Positive values specify absolute item index. Negative values count downwards
                          from the end of the item list where -1 points to the index after the last item. (Default: -1)
INT_VAR charge1           Number of charges for the first ability or quantity for stackable items. (Default: 0)
INT_VAR charge2           Number of charges for the second ability. (Default: 0)
INT_VAR charge3           Number of charges for the third ability. (Default: 0)
INT_VAR flags             Item flags. (Default: 0)
INT_VAR expiry            Item expiration time. Not needed for item definitions outside of saved games. (Default: 0)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR item_resref       Resref of the item. (Default: empty string)
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET index                 Returns the index of the added item structure if successful, -1 otherwise
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_container_item
-----------------------------------------------------------
Action and patch function that alters attributes of an existing container item structure on the ARE handle.

INT_VAR container_index   Index of the container where the item should be patched. Omit if you specify the container by name.
INT_VAR item_index        Index of the item to patch.
INT_VAR charge1           New number of charges for the first ability or quantity for stackable items. (Default: no change)
INT_VAR charge2           New number of charges for the second ability. (Default: no change)
INT_VAR charge3           New number of charges for the third ability. (Default: no change)
INT_VAR flags             New item flags. (Default: no change)
INT_VAR expiry            New item expiration time. Not needed for item definitions outside of saved games. (Default: no change)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR item_resref       New resref of the item. (Default: no change)
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_remove_container_item
------------------------------------------------------------
Action and patch function that removes an existing container item structure from the ARE handle.

INT_VAR container_index   Index of the container structure. Omit if you specify the container structure by name.
INT_VAR item_index        Index of the container item to remove. Omit if you specify the item by resref.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR container_name    Name of the container structure. Omit if you specify the container structure by index.
STR_VAR item_resref       Resref of the item to remove. Omit if you specify the item by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_add_ambient
--------------------------------------------------
Action and patch function that adds a new ambient sound to the ARE handle.

INT_VAR loc_x             X coordinate of the ambient sound. (Default: 0)
INT_VAR loc_y             Y coordinate of the ambient sound. (Default: 0)
INT_VAR radius            Sound radius. (Default: 500)
INT_VAR loc_z             Z coordinate (height) of the ambient sound. (Default: 0)
INT_VAR pitch_variance    Pitch variance. (Default: 0)
INT_VAR volume_variance   Volume variance. (Default: 0)
INT_VAR volume            Volumne percentage. (Default: 80)
INT_VAR sound_num         Number of active sounds. (Default: 0)
INT_VAR delay             Base interval in seconds between sounds from this ambient list. (Default: 0)
INT_VAR variation         Base deviation from the base interval. (Default: 0)
INT_VAR schedule          Hourly appearance schedule. Each bit refers to a specific hour of the day. (Default: always active)
INT_VAR flags             Ambient flags. (Default: 0)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the ambient sound. May not be longer than 32 characters. (Default: empty string)
STR_VAR wav_resref0, ...  Resref of each sound. Range: wav_resref0 ... wav_resref9. (Default: empty string)
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET index                 Returns the index of the added ambient sound structure if successful, -1 otherwise
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_ambient
----------------------------------------------------
Action and patch function that alters attributes of an existing ambient sound structure on the ARE handle.

INT_VAR ambient_index     Index of the ambient sound structure to patch. Omit if you specify the ambient sound structure by name.
INT_VAR loc_x             New X coordinate of the ambient sound. (Default: no change)
INT_VAR loc_y             New Y coordinate of the ambient sound. (Default: no change)
INT_VAR radius            New sound radius. (Default: no change)
INT_VAR loc_z             New Z coordinate (height) of the ambient sound. (Default: no change)
INT_VAR pitch_variance    New pitch variance. (Default: no change)
INT_VAR volume_variance   New volume variance. (Default: no change)
INT_VAR volume            New volumne percentage. (Default: no change)
INT_VAR sound_num         New number of active sounds. (Default: no change)
INT_VAR delay             New base interval in seconds between sounds from this ambient list. (Default: no change)
INT_VAR variation         New base deviation from the base interval. (Default: no change)
INT_VAR schedule          New hourly appearance schedule. Each bit refers to a specific hour of the day. (Default: no change)
INT_VAR flags             New ambient flags. (Default: no change)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR ambient_name      Name of the ambient sound structure to patch. Omit if you specify the ambient sound structure by index.
STR_VAR name              New name of the ambient sound. May not be longer than 32 characters. (Default: no change)
STR_VAR wav_resref0, ...  New resref of each sound. Range: wav_resref0 ... wav_resref9. (Default: no change)
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_remove_ambient
-----------------------------------------------------
Action and patch function that removes an existing ambient sound structure from the ARE handle.

INT_VAR ambient_index     Index of the ambient sound structure to remove. Omit if you specify the ambient sound structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR ambient_name      Name of the ambient sound structure to remove. Omit if you specify the ambient sound structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_move_ambient
---------------------------------------------------
Action and patch function that moves the position of a ambient sound on the ARE handle by a specified amount in either direction.

INT_VAR ambient_index     Index of the ambient sound structure to move. Omit if you specify the ambient sound structure by name.
INT_VAR x                 Amount to move in horizontal direction. Specify positive values to move to the right and negative values to move to the left.
INT_VAR y                 Amount to move in vertical direction. Specify positive values to move downwards and negative values to move upwards.
INT_VAR z                 Amount to move along the z-axis (height).
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR ambient_name      Name of the ambient sound structure to move. Omit if you specify the ambient sound structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_add_variable
---------------------------------------------------
Action and patch function that adds a new variable to the ARE handle.

INT_VAR value             Value associated with the variable. (Default: 0)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the variable. May not be longer than 32 characters. (Default: empty string)
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET index                 Returns the index of the added variable structure if successful, -1 otherwise
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_variable
-----------------------------------------------------
Action and patch function that alters attributes of an existing variable structure on the ARE handle.

INT_VAR variable_index    Index of the variable structure to patch. Omit if you specify the variable structure by name.
INT_VAR value             New value associated with the variable. (Default: no change)
                          Note: Because of technical reasons the numeric value 2147385342 cannot be assigned to "value
                                unless the parameter "force_assign" is set to 1.
INT_VAR force_assign      Specify 1 to force the content of "value" to be assigned to the specified variable structure.
                          See note of the "value" parameter. (Default: 0)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR variable_name     Name of the variable structure to patch. Omit if you specify the variable structure by index.
STR_VAR name              New name of the variable. May not be longer than 32 characters. (Default: no change)
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_remove_variable
------------------------------------------------------
Action and patch function that removes an existing variable structure from the ARE handle.

INT_VAR variable_index    Index of the variable structure to remove. Omit if you specify the variable structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR variable_name     Name of the variable structure to remove. Omit if you specify the variable structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_set_explored
---------------------------------------------------
Action and patch function that sets the explored bitmap in the ARE handle to specified string data.

INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR bitmask           Bitmap data as string. String may be expanded by unexplored bits or cut off if string size
                          doesn't match the area's explored bitmap size. (Default: empty string)
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_clear_explored
-----------------------------------------------------
Action and patch function that clears the whole explored bitmap buffer from the ARE handle.

INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_explored
-----------------------------------------------------
Action and patch function that alters the explored bitmap to the "explored" or "unexplored" state in the ARE handle.

INT_VAR clear             Specify 1 to explore the whole map. Specify 0 to set the whole map to the unexplored state. (Default: 1)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_add_door
-----------------------------------------------
Action and patch function that adds a new door to the ARE handle.

INT_VAR flags                   Door flags. (Default: 0)
INT_VAR cursor_idx              Cursor index (CURSORS.BAM). (Default: 30)
INT_VAR trap_detect             Trap detection difficulty. (Default: 0)
INT_VAR trap_remove             Trap removal difficulty. (Default: 0)
INT_VAR trap_active             Whether the door is trapped. (Default: 0)
INT_VAR trap_status             Whether the door trap is detected. (Default: 0)
INT_VAR trap_loc_x              Trap launch X coordinate. (Default: 0)
INT_VAR trap_loc_y              Trap launch Y coordinate. (Default: 0)
INT_VAR detect_diff             Detection difficulty for secret doors. (Default: 0)
INT_VAR lock_diff               Lock difficulty. (Default: 0)
INT_VAR open_loc_x              X coordinate for toggling the door's open state. (Default: 0)
INT_VAR open_loc_y              Y coordinate for toggling the door's open state. (Default: 0)
INT_VAR closed_loc_x            X coordinate for toggling the door's closed state. (Default: 0)
INT_VAR closed_loc_y            Y coordinate for toggling the door's closed state. (Default: 0)
INT_VAR lockpick_strref         Lockpick strref. (Default: -1)
INT_VAR dlg_strref              Dialog speaker name strref. (Default: -1)
INT_VAR num_vertices_open       Number of open door polygon vertices to add. (Default: 0)
INT_VAR num_vertices_closed     Number of closed door polygon vertices to add. (Default: 0)
INT_VAR num_cells_open          Number of open door impeded cells to add. (Default: 0)
INT_VAR num_cells_closed        Number of closed door impeded cells to add. (Default: 0)
INT_VAR vertex_open_0, ...      Array "vertex_open" with "num_vertices_open" vertex coordinates, as "X coordinate | (Y coordinate << 16)".
                                Alternate notation: $vertex_open("0"), ...
INT_VAR vertex_closed_0, ...    Array "vertex_closed" with "num_vertices_closed" vertex coordinates, as "X coordinate | (Y coordinate << 16)".
                                Alternate notation: $vertex_closed("0"), ...
INT_VAR cell_open_0, ...        Array "cell_open" with "num_cells_open" vertex coordinates, as "X coordinate | (Y coordinate << 16)".
                                Alternate notation: $cell_open("0"), ...
INT_VAR cell_closed_0, ...      Array "cell_closed" with "num_cells_closed" vertex coordinates, as "X coordinate | (Y coordinate << 16)".
                                Alternate notation: $cell_closed("0"), ...
INT_VAR silent                  Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                     Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                                Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name                    Name of the door. May not be longer than 32 characters. (Default: empty string)
STR_VAR wed_id                  Door ID linked to the door structure in the associated WED resource. May not be longer than 8 characters. (Default: empty string)
STR_VAR open_wav                Open sound of the door. (Default: empty string)
STR_VAR close_wav               Close sound of the door. (Default: empty string)
STR_VAR key_resref              Resref of the key item to unlock the door. (Default: empty string)
STR_VAR door_script             Resref of the door script. (Default: empty string)
STR_VAR travel_trigger          Name of the travel region associated with the door. May not be longer than 24 characters. (Default: empty string)
STR_VAR dlg_resref              Resref of the door's dialog. (Default: empty string)
RET success                     Returns 1 if the operation was successful, 0 otherwise.
RET index                       Returns the index of the added door structure if successful, -1 otherwise
RET_ARRAY %are%                 Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                                (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_door
-------------------------------------------------
Action and patch function that alters attributes of an existing door structure on the ARE handle.

INT_VAR door_index              Index of the door structure to patch. Omit if you specify the door structure by name.
INT_VAR flags                   New door flags. (Default: no change)
INT_VAR cursor_idx              New cursor index (CURSORS.BAM). (Default: no change)
INT_VAR trap_detect             New trap detection difficulty. (Default: no change)
INT_VAR trap_remove             New trap removal difficulty. (Default: no change)
INT_VAR trap_active             New value of whether the door is trapped. (Default: no change)
INT_VAR trap_status             New value of whether the door trap is detected. (Default: no change)
INT_VAR trap_loc_x              New trap launch X coordinate. (Default: no change)
INT_VAR trap_loc_y              New trap launch Y coordinate. (Default: no change)
INT_VAR detect_diff             New detection difficulty for secret doors. (Default: no change)
INT_VAR lock_diff               New lock difficulty. (Default: no change)
INT_VAR open_loc_x              New X coordinate for toggling the door's open state. (Default: no change)
INT_VAR open_loc_y              New Y coordinate for toggling the door's open state. (Default: no change)
INT_VAR closed_loc_x            New X coordinate for toggling the door's closed state. (Default: no change)
INT_VAR closed_loc_y            New Y coordinate for toggling the door's closed state. (Default: no change)
INT_VAR lockpick_strref         New lockpick strref. (Default: no change)
INT_VAR dlg_strref              New dialog speaker name strref. (Default: no change)
INT_VAR num_vertices_open       New number of open door polygon vertices. If this parameter is specified then the current door vertices
                                are updated with the specified vertex definitions. (Default: no change)
INT_VAR num_vertices_closed     New number of closed door polygon vertices. If this parameter is specified then the current door vertices
                                are updated with the specified vertex definitions. (Default: no change)
INT_VAR num_cells_open          New number of open door impeded cells. If this parameter is specified then the current door cells
                                are updated with the specified vertex definitions. (Default: no change)
INT_VAR num_cells_closed        New number of closed door impeded cells. If this parameter is specified then the current door cells
                                are updated with the specified vertex definitions. (Default: no change)
INT_VAR vertex_open_0, ...      Array "vertex_open" with "num_vertices_open" vertex coordinates, as "X coordinate | (Y coordinate << 16)".
                                Alternate notation: $vertex_open("0"), ...
INT_VAR vertex_closed_0, ...    Array "vertex_closed" with "num_vertices_closed" vertex coordinates, as "X coordinate | (Y coordinate << 16)".
                                Alternate notation: $vertex_closed("0"), ...
INT_VAR cell_open_0, ...        Array "cell_open" with "num_cells_open" vertex coordinates, as "X coordinate | (Y coordinate << 16)".
                                Alternate notation: $cell_open("0"), ...
INT_VAR cell_closed_0, ...      Array "cell_closed" with "num_cells_closed" vertex coordinates, as "X coordinate | (Y coordinate << 16)".
                                Alternate notation: $cell_closed("0"), ...
INT_VAR silent                  Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                     Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                                Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR door_name               Name of the door structure to patch. Omit if you specify the door structure by index.
STR_VAR name                    New name of the door. May not be longer than 32 characters. (Default: no change)
STR_VAR wed_id                  New door ID linked to the door structure in the associated WED resource. May not be longer than 8 characters. (Default: no change)
STR_VAR open_wav                New open sound of the door. (Default: no change)
STR_VAR close_wav               New close sound of the door. (Default: no change)
STR_VAR key_resref              New resref of the key item to unlock the door. (Default: no change)
STR_VAR door_script             New resref of the door script. (Default: no change)
STR_VAR travel_trigger          New name of the travel region associated with the door. May not be longer than 24 characters. (Default: no change)
STR_VAR dlg_resref              New resref of the door's dialog. (Default: no change)
RET success                     Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%                 Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                                (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_remove_door
--------------------------------------------------
Action and patch function that removes an existing door structure from the ARE handle.

INT_VAR door_index        Index of the door structure to remove. Omit if you specify the door structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR door_name         Name of the door structure to remove. Omit if you specify the door structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_move_door
------------------------------------------------
Action and patch function that moves the position of a door on the ARE handle by a specified amount in either direction.

INT_VAR door_index        Index of the door structure to move. Omit if you specify the door structure by name.
INT_VAR x                 Amount to move in horizontal direction. Specify positive values to move to the right and negative values to move to the left.
INT_VAR y                 Amount to move in vertical direction. Specify positive values to move downwards and negative values to move upwards.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR door_name         Name of the door structure to move. Omit if you specify the door structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_scale_door
-------------------------------------------------
Action and patch function that scales a door polygon on the ARE handle by a specified factor in either direction.
Impeded cells are not updated by this operation.

INT_VAR door_index        Index of the door structure to scale. Omit if you specify the door structure by name.
INT_VAR scale_x           Indicates whether to scale horizontally. (Default: 1)
INT_VAR scale_y           Indicates whether to scale vertically. (Default: 1)
INT_VAR numerator         Numerator (top value of a fraction) of the scaling factor. (Default: 1)
                          Note: A negative fractional value will mirror the polygon vertex coordinates around the anchor point.
INT_VAR denominator       Denominator (bottom value of a fraction) of the scaling factor. Must not be 0. (Default: 1)
                          Note: A negative fractional value will mirror the polygon vertex coordinates around the anchor point.
INT_VAR x                 If "custom" anchor is specified then this value defines the absolute x coordinate of the anchor point. (Default: 0)
INT_VAR y                 If "custom" anchor is specified then this value defines the absolute y coordinate of the anchor point. (Default: 0)
INT_VAR polygon_only      Specify 1 to scale only the door polygon vertices. Specify 0 to scale location coordinates as well. (Default: 1)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR door_name         Name of the door structure to remove. Omit if you specify the door structure by index.
STR_VAR anchor            Anchor point for the scaling operation. Relative movement of the vertices is centered on this position. (Default: "origin")
                          Note: For the "relative_*" anchor types a bounding box is calculated that encloses both open and closed door polygons.
                                This anchor point is also used for scaling locations if the "polygon_only" parameter is set to 0.
                          Supported anchor points:
                          - origin:                 Uses absolute coordinates (0,0) as anchor point
                          - custom:                 Uses parameters x and y as anchor point coordinates
                          - relative_top_left:      Uses top-left bounding box coordinates as anchor point
                          - relative_top_center:    Uses top-horizontal center bounding box coordinates as anchor point
                          - relative_top_right:     Uses top-right bounding box coordinates as anchor point
                          - relative_center_left:   Uses vertical center-left bounding box coordinates as anchor point
                          - relative_center_right:  Uses vertical center-right bounding box coordinates as anchor point
                          - relative_bottom_left:   Uses bottom-left bounding box coordinates as anchor point
                          - relative_bottom_center: Uses bottom-horizontal center bounding box coordinates as anchor point
                          - relative_bottom_right:  Uses bottom-right bounding box coordinates as anchor point
                          - relative_center:        Uses the (horizontal and vertical) center of the bounding box coordinates as anchor point
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_add_animation
----------------------------------------------------
Action and patch function that adds a new animation to the ARE handle.

INT_VAR loc_x             X coordinate of the animation. (Default: 0)
INT_VAR loc_y             Y coordinate of the animation. (Default: 0)
INT_VAR schedule          Hourly appearance schedule. Each bit refers to a specific hour of the day. (Default: always active)
INT_VAR bam_seq           The BAM sequence number. (Default: 0)
INT_VAR bam_frame         The BAM frame number. (Default: 0)
INT_VAR flags             Animation flags. (Default: 0)
INT_VAR loc_z             Height of the animation. (Default: 0)
INT_VAR transparent       BAM transparency/translucency in range 0 - 255 (the higher the more translucent). (Default: 0)
INT_VAR init_frame        Starting frame of the animation playback. (0 indicates random frame unless synchronized flag is set). (Default: 0)
INT_VAR loop_chance       Chance of looping (%). (Default: 0)
INT_VAR skip_cycles       Start delay in frames. (Default: 0)
INT_VAR width             (EE only) Animation width. This is only required for WBM and PVRZ resources. (Default: 0)
INT_VAR height            (EE only) Animation height. This is only required for WBM and PVRZ resources. (Default: 0)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name              Name of the animation. May not be longer than 32 characters. (Default: empty string)
STR_VAR bam_resref        Resref of the BAM animation. EE games can also specify WBM and PVRZ resources. (Default: empty string)
STR_VAR bmp_resref        Resref of the palette bitmap. Palette is only supported by BAM V1 animations. (Default: empty string).
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET index                 Returns the index of the added animation structure if successful, -1 otherwise
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_animation
------------------------------------------------------
Action and patch function that alters attributes of an existing animation structure on the ARE handle.

INT_VAR animation_index   Index of the animation structure to patch. Omit if you specify the animation structure by name.
INT_VAR loc_x             New X coordinate of the animation. (Default: no change)
INT_VAR loc_y             New Y coordinate of the animation. (Default: no change)
INT_VAR schedule          New hourly appearance schedule. Each bit refers to a specific hour of the day. (Default: no change)
INT_VAR bam_seq           New BAM sequence number. (Default: no change)
INT_VAR bam_frame         New BAM frame number. (Default: no change)
INT_VAR flags             New animation flags. (Default: no change)
INT_VAR loc_z             New height of the animation. (Default: no change)
INT_VAR transparent       New BAM transparency/translucency in range 0 - 255 (the higher the more translucent). (Default: no change)
INT_VAR init_frame        New starting frame of the animation playback. (0 indicates random frame unless synchronized flag is set). (Default: no change)
INT_VAR loop_chance       New chance of looping (%). (Default: no change)
INT_VAR skip_cycles       New start delay in frames. (Default: no change)
INT_VAR width             (EE only) New animation width. This is only required for WBM and PVRZ resources. (Default: no change)
INT_VAR height            (EE only) New animation height. This is only required for WBM and PVRZ resources. (Default: no change)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR animation_name    Name of the animation structure to patch. Omit if you specify the animation structure by index.
STR_VAR name              New name of the animation. May not be longer than 32 characters. (Default: no change)
STR_VAR bam_resref        New resref of the BAM animation. EE games can also specify WBM and PVRZ resources. (Default: no change)
STR_VAR bmp_resref        New resref of the palette bitmap. Palette is only supported by BAM V1 animations. (Default: no change).
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_remove_animation
-------------------------------------------------------
Action and patch function that removes an existing animation structure from the ARE handle.

INT_VAR animation_index   Index of the animation structure to remove. Omit if you specify the animation structure by name.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR animation_name    Name of the animation structure to remove. Omit if you specify the animation structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_move_animation
-----------------------------------------------------
Action and patch function that moves the position of a animation on the ARE handle by a specified amount in either direction.

INT_VAR animation_index   Index of the animation structure to move. Omit if you specify the animation structure by name.
INT_VAR x                 Amount to move in horizontal direction. Specify positive values to move to the right and negative values to move to the left.
INT_VAR y                 Amount to move in vertical direction. Specify positive values to move downwards and negative values to move upwards.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR animation_name    Name of the animation structure to move. Omit if you specify the animation structure by index.
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_songs
--------------------------------------------------
Action and patch function that alters attributes of the songs structure on an ARE handle.

INT_VAR song_day            New day song reference number (SONGLIST.2DA). (Default: no change)
INT_VAR song_night          New night song reference number (SONGLIST.2DA). (Default: no change)
INT_VAR song_victory        New victory song reference number (SONGLIST.2DA). (Default: no change)
INT_VAR song_battle         New battle song reference number (SONGLIST.2DA). (Default: no change)
INT_VAR song_defeat         New defeat song reference number (SONGLIST.2DA). (Default: no change)
INT_VAR song_day_alt        New alternate day song reference number (SONGLIST.2DA). (Default: no change)
INT_VAR song_night_alt      New alternate night song reference number (SONGLIST.2DA). (Default: no change)
INT_VAR song_victory_alt    New alternate victory song reference number (SONGLIST.2DA). (Default: no change)
INT_VAR song_battle_alt     New alternate battle song reference number (SONGLIST.2DA). (Default: no change)
INT_VAR song_defeat_alt     New alternate defeat song reference number (SONGLIST.2DA). (Default: no change)
INT_VAR song_day_vol        New main day ambient volume (%). (Default: no change)
INT_VAR song_night_vol      New main night ambient volume (%). (Default: no change)
INT_VAR reverb              New reverb definition from REVERB.2DA or REVERB.IDS if available. (Default: no change)
INT_VAR silent              Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                 Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                            Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR song_day0           New resref of the first main day ambient sound. (Default: no change)
STR_VAR song_day1           New resref of the second main day ambient sound. (Default: no change)
STR_VAR song_night0         New resref of the first main night ambient sound. (Default: no change)
STR_VAR song_night1         New resref of the second main night ambient sound. (Default: no change)
RET success                 Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%             Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                            (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_rest
-------------------------------------------------
Action and patch function that alters attributes of the rest encounters structure on an ARE handle.

INT_VAR cre_strref0, ...    New strref of string that is displayed upon party ambush. Range: cre_strref0 ... cre_strref9. (Default: no change)
INT_VAR spawn_num           New number of spawned creatures. (Default: no change)
INT_VAR difficulty          New encounter difficulty. (Default: no change)
INT_VAR duration            New creature's removal timer, in seconds. (Default: no change)
INT_VAR wander_distance     New movement restriction distance. (Default: no change)
INT_VAR follow_distance     New movement restriction distance (move to object). (Default: no change)
INT_VAR max_num             New max. number of spawned creatures. (Default: no change)
INT_VAR enable              New value of whether rest encounters are enabled. (Default: no change)
INT_VAR day_prob            Probability (day) per hour. (Default: no change)
INT_VAR night_prob          Probability (night) per hour. (Default: no change)
INT_VAR silent              Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                 Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                            Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR name                Name of the rest encounters structures (unused by the engine). (Default: no change)
STR_VAR cre_resref0, ...    Resref of the creature to spawn. Range: cre_resref0 ... cre_resref9. (Default: no change)
RET success                 Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%             Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                            (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_add_automap
--------------------------------------------------
Action and patch function that adds a new automap note to the ARE handle.

INT_VAR loc_x             X coordinate of the automap note. (Default: 0)
INT_VAR loc_y             Y coordinate of the automap note. (Default: 0)
INT_VAR note_strref       (All except PST) Strref of the note. (Default: -1)
INT_VAR strref_loc        (All except PST) Strref location (0=talk override, 1=dialog.tlk). (Default: 1)
INT_VAR color             Map marker color (PST: 0=blue, 1=red; everything else: 0-7). See MAPNOTES.IDS in EE games. (Default: 0)
INT_VAR note_id           (All except PST) Internal note ID. (Default: 0)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR note_text         (PST only) Text of the automap note. May not be longer than 500 characters. (Default: empty string)
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET index                 Returns the index of the added automap note structure if successful, -1 otherwise
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_automap
----------------------------------------------------
Action and patch function that alters attributes of an existing automap note structure on the ARE handle.

INT_VAR automap_index     Index of the automap note structure to patch.
INT_VAR loc_x             New X coordinate of the automap note. (Default: no change)
INT_VAR loc_y             New Y coordinate of the automap note. (Default: no change)
INT_VAR note_strref       (All except PST) New strref of the note. (Default: no change)
INT_VAR strref_loc        (All except PST) New strref location (0=talk override, 1=dialog.tlk). (Default: no change)
INT_VAR color             New map marker color (PST: 0=blue, 1=red; everything else: 0-7). (Default: no change)
INT_VAR note_id           (All except PST) New internal note ID. (Default: no change)
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: no change)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR note_text         (PST only) New text of the automap note. May not be longer than 500 characters. (Default: no change)
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_remove_automap
-----------------------------------------------------
Action and patch function that removes an existing automap note structure from the ARE handle.

INT_VAR automap_index     Index of the automap note structure to remove.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_move_automap
---------------------------------------------------
Action and patch function that moves the position of a automap note on the ARE handle by a specified amount in either direction.

INT_VAR automap_index     Index of the automap note structure to move.
INT_VAR x                 Amount to move in horizontal direction. Specify positive values to move to the right and negative values to move to the left.
INT_VAR y                 Amount to move in vertical direction. Specify positive values to move downwards and negative values to move upwards.
INT_VAR silent            Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are               Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                          Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
RET success               Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%           Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                          (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_add_projectile
-----------------------------------------------------
Action and patch function that adds a new projectile trap to the ARE handle.
Note: This function works only on AREA V1.0 areas in BG2 or the EE games.

INT_VAR missile_num           MISSILE.IDS reference of the projectile. (Default: 0)
INT_VAR frequency             Explosion length in frames. (Default: 0)
INT_VAR duration              Number of explosions. (Default: 1)
INT_VAR loc_x                 X coordinate of the projectile trap. (Default: 0)
INT_VAR loc_y                 Y coordinate of the projectile trap. (Default: 0)
INT_VAR loc_z                 Height of the projectile trap. (Default: 0)
INT_VAR target                EA.IDS value of the target. (Default: 200 / EVILCUTOFF)
INT_VAR creator               Zero-based index of the party member who created the projectile (0-5). (Default: 0)
INT_VAR num_embedded_eff      Number of EFF structures to add. (Default: 0)
INT_VAR silent                Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                   Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                              Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR pro_resref            Resref of the projectile. (Default: empty string)
STR_VAR embedded_eff_0, ...   Array "embedded_eff" with "num_embedded_eff" effect entries. Each entry is either a path/to/v2.eff file
                              or an EFF resref. Alternate notation: $embedded_eff("0")
RET success                   Returns 1 if the operation was successful, 0 otherwise.
RET index                     Returns the index of the added projectile trap structure if successful, -1 otherwise
RET_ARRAY %are%               Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                              (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_alter_projectile
-------------------------------------------------------
Action and patch function that alters attributes of an existing projectile trap structure on the ARE handle.

INT_VAR projectile_index      Index of the projectile trap structure to patch.
INT_VAR missile_num           New MISSILE.IDS reference of the projectile. (Default: no change)
INT_VAR frequency             Ne explosion length in frames. (Default: no change)
INT_VAR duration              New number of explosions. (Default: no change)
INT_VAR loc_x                 New X coordinate of the projectile trap. (Default: no change)
INT_VAR loc_y                 New Y coordinate of the projectile trap. (Default: no change)
INT_VAR loc_z                 New height of the projectile trap. (Default: no change)
INT_VAR target                New EA.IDS value of the target. (Default: no change)
INT_VAR creator               New Zero-based index of the party member who created the projectile (0-5). (Default: no change)
INT_VAR num_embedded_eff      Number of EFF structures to patch. (Default: no change)
INT_VAR silent                Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                   Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                              Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
STR_VAR pro_resref            New resref of the projectile. (Default: no change)
STR_VAR embedded_eff_0, ...   Array "embedded_eff" with "num_embedded_eff" effect entries. Each entry is either a path/to/v2.eff file
                              or an EFF resref. Alternate notation: $embedded_eff("0")
                              Skip entries or assign an empty string to keep the original effect entry.
                              Skipping definitions or using an empty string for non-existing effect entries will trigger an error.
                              This array is only considered if "num_embedded_eff" is defined.
RET success                   Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%               Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                              (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_remove_projectile
--------------------------------------------------------
Action and patch function that removes an existing projectile trap structure from the ARE handle.

INT_VAR projectile_index    Index of the projectile trap structure to remove.
INT_VAR silent              Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                 Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                            Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
RET success                 Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%             Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                            (which is "are" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_are_move_projectile
------------------------------------------------------
Action and patch function that moves the position of a projectile trap on the ARE handle by a specified amount in either direction.

INT_VAR projectile_index    Index of the projectile trap structure to move.
INT_VAR x                   Amount to move in horizontal direction. Specify positive values to move to the right and negative values to move to the left.
INT_VAR y                   Amount to move in vertical direction. Specify positive values to move downwards and negative values to move upwards.
INT_VAR silent              Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR are                 Name of the ARE handle that is returned by "a7#are_open" and other batch functions.
                            Can be omitted if the return value from "a7#are_open" is used as is. (Default: "are")
RET success                 Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %are%             Returns the updated ARE handle. Specify the actual name of the ARE handle that is returned by "a7#are_open"
                            (which is "are" by default).


****************
* 3. Changelog *
****************

Version 1.0
- Initial release
