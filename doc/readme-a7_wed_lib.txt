WeiDU WED Library
~~~~~~~~~~~~~~~~~

Version:  1.0
Author:   Argent77
License:  MIT


*********************
* Table of Contents *
*********************

1. Overview
2. WED functions
  2.1. Standalone functions
    - a7#wed_create
  2.2.Open/close functions for batch processing
    - a7#wed_open
    - a7#wed_close
  2.3. Query functions
    - a7#batch_wed_get_info
    - a7#batch_wed_get_overlay
    - a7#batch_wed_get_wall_poly
    - a7#batch_wed_get_door
    - a7#batch_wed_get_door_poly
  2.4. Patch functions
    - a7#batch_wed_set_overlay
    - a7#batch_wed_alter_overlay
    - a7#batch_wed_add_wall_poly
    - a7#batch_wed_alter_wall_poly
    - a7#batch_wed_remove_wall_poly
    - a7#batch_wed_add_door
    - a7#batch_wed_alter_door
    - a7#batch_wed_remove_door
    - a7#batch_wed_set_door_tilemap
    - a7#batch_wed_add_door_poly
    - a7#batch_wed_alter_door_poly
    - a7#batch_wed_remove_door_poly
    - a7#batch_wed_wall_poly_move
    - a7#batch_wed_door_poly_move
    - a7#batch_wed_wall_poly_scale
    - a7#batch_wed_door_poly_scale
    - a7#batch_wed_rebuild_wallgroups
3. Changelog


***************
* 1. Overview *
***************

This library provides WeiDU functions for creating, querying, and patching WED resources.

Parsing WED files by the WeiDU interpreter is slow. For that reason the library allows to batch-process WED files
in one go by the functions described below.

Example of patching a WED file:
// Patching BG2 "Athkatla City Gates" WED file 
COPY_EXISTING "AR0020.WED" "override"
  // prepares the WED data for patching
  LPF a7#wed_open RET success RET_ARRAY wed END

  // adds a new wall polygon
  LPF a7#batch_wed_add_wall_poly
    INT_VAR
      flags = BIT0 | BIT3  // Shade wall, Cover animations
      num_vertices = 4
      vertex_0 = 363 + (699 << 16)  // X + (Y << 16)
      vertex_1 = 467 + (623 << 16)
      vertex_2 = 536 + (673 << 16)
      vertex_3 = 431 + (749 << 16)
    RET success index
    RET_ARRAY wed   // "wed" handle must be returned to make the changes visible to subsequent operations
  END
  PATCH_IF (success) BEGIN
    PATCH_PRINT "Added new wall polygon at index %index%"
  END ELSE BEGIN
    PATCH_WARN ~WARNING: Wall polygon could not be added.~
  END

  // writes any changes back to the WED file
  LPF a7#wed_close RET success END
BUT_ONLY


********************
* 2. WED functions *
********************

The following function can be found in the library "a7_wed_lib.tph".


2.1. Standalone functions
*************************

DEFINE_ACTION_FUNCTION a7#wed_create
------------------------------------
Action function that creates an empty WED file with 5 predefined empty overlay structures.

INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR resref          Resource reference of the resulting WED file. Length must not exceed 8 characters.
STR_VAR path            Destination folder for WED file. (Default: "override")
RET success             Returns 1 if the operation was successful, 0 otherwise.


2.2. Open/close functions for batch processing
**********************************************

These functions are required to perform batch operations on the WED file. "a7#wed_open" is required for any query
or patch functions. "a7#wed_close" is only required after calling patch functions.

DEFINE_PATCH_FUNCTION a7#wed_open
---------------------------------
Patch function that opens the current WED file and returns a WED handle for further editing.

IMPORTANT: Only after calling "a7#wed_open" batch functions can be used to modify WED content.

RET success             Returns 1 on success and 0 on error.
RET_ARRAY wed           Returns a handle of the initialized WED structure if "success" returns 1.
                        The name of this handle must be specified as parameter for the "a7#batch_xxx" functions.

DEFINE_PATCH_FUNCTION a7#wed_close
----------------------------------
Patch function that writes all modifications made by batch functions back to the WED file.

STR_VAR wed             Name of the WED array structure. (Default: "wed")
RET success             Returns 1 on success and 0 on error.


2.3. Query functions
********************

These function perform only read operations on the specified WED handle and therefore don't require a final call
of "a7#wed_close".

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_get_info
-----------------------------------------------
Action and patch function that returns general information about the WED handle.

STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
RET success             Returns 1 if the query was successful, 0 otherwise.
RET num_overlays        Returns the number of available overlay structures.
RET num_doors           Returns the number of available door structures.
RET num_wallpolys       Returns the number of available wall polygon structures.

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_get_overlay
--------------------------------------------------
Action and patch function that returns overlay information from the WED handle.

INT_VAR index           Index of the overlay structure to query information about. (Default: 0)
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
RET success             Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY overlay       Returns an associative array with information about the specified overlay structure.
                        Structure of the array:
                        - $overlay("width"): width (in tiles)
                        - $overlay("height"): height (in tiles)
                        - $overlay("resref"): TIS resref
                        - $overlay("unique"): unique tile count
                        - $overlay("type"): movement type
                        - $overlay("tilemap"): number of tilemap elements
                        - $overlay("tilemap" "<idx>"): number of primary tiles assigned to tilemap entry <idx>
                          (primary tile count)
                        - $overlay("tilemap" "<idx>" "<idx2>"): tile index associated with primary tile of
                          tilemap entry <idx> (<idx2> range: 0 to <number of primary tiles minus 1>)
                        - $overlay("tilemap" "<idx>" "secondary"): secondary tile index if defined, -1 otherwise
                        - $overlay("tilemap" "<idx>" "flags"): overlay flags for tilemap entry <idx>

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_get_wall_poly
----------------------------------------------------
Action and patch function that returns wall polygon information from the WED handle.

INT_VAR index           Index of the wall polygon structure to query information about.
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
RET success             Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY wallpoly      Returns an associative array with information about the specified wall polygon structure.
                        Structure of the array:
                        - $wallpoly("flags"): polygon flags
                        - $wallpoly("height"): height
                        - $wallpoly("min_x"): minimum x coordinate of the bounding box
                        - $wallpoly("max_x"): maximum x coordinate of the bounding box
                        - $wallpoly("min_y"): minimum y coordinate of the bounding box
                        - $wallpoly("max_y"): maximum y coordinate of the bounding box
                        - $wallpoly("vertex"): number of polygon vertices
                        - $wallpoly("vertex" "<idx>"): vertex coordinates as combined (x | (y << 16)) values
                          - How to extract x: x = (value BLSL 16) BASR 16   (double shift to preserve signedness)
                          - How to extract y: y = value BASR 16

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_get_door
-----------------------------------------------
Action and patch function that returns door information from the WED handle.

INT_VAR index           Index of the door structure to query information about.
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
RET success             Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY door          Returns an associative array with information about the specified door structure.
                        Structure of the array:
                        - $door("name"): Name of the door
                        - $door("tilemap"): number of tilemap indices occupied by the door structure
                        - $door("tilemap" "<idx>"): index of the tilemap structure
                        - $door("tilemap" "<idx>" "secondary"): tile index that is used for the closed state of a door
                        - $door("poly_open"): number of open state polygons
                        - $door("poly_closed"): number of closed state polygons

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_get_door_poly
----------------------------------------------------
Action and patch function that returns door polygon information from the WED handle.

INT_VAR door_index      Index of the door structure to query information about.
INT_VAR index           Index of the (open or closed state) polygon structure to query information about.
INT_VAR closed          Specify 0 to query information about an open state polygon, specify 1 to query information
                        about an closed state polygon.
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
RET success             Returns 1 if the query was successful, 0 otherwise.
RET_ARRAY doorpoly      Returns an associative array with information about the specified door polygon structure.
                        Structure of the array:
                        - $doorpoly("flags"): polygon flags
                        - $doorpoly("height"): height
                        - $doorpoly("min_x"): minimum x coordinate of the bounding box
                        - $doorpoly("max_x"): maximum x coordinate of the bounding box
                        - $doorpoly("min_y"): minimum y coordinate of the bounding box
                        - $doorpoly("max_y"): maximum y coordinate of the bounding box
                        - $doorpoly("vertex"): number of polygon vertices
                        - $doorpoly("vertex" "<idx>"): vertex coordinates as combined (x | (y << 16)) values
                          - How to extract x: x = (value BLSL 16) BASR 16   (double shift to preserve signedness)
                          - How to extract y: y = value BASR 16


2.4. Patch functions
********************

These functions perform read and write operations on the specified WED handle. They must be finalized by a call
of "a7#wed_close" to make the changes persistent.

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_set_overlay
--------------------------------------------------
Action and patch function that assigns new tilemap definitions to an overlay structure on the WED handle.

INT_VAR overlay_index   Index of the overlay structure where the tilemap definitions should by assigned to.
                        New overlay structures are inserted if needed. Allowed range: 0 - 7
INT_VAR width           Width of the overlay, in tiles. (Default: 1)
INT_VAR height          Height of the overlay, in tiles. (Default: 1)
INT_VAR unique          Unique tile count. (Default: 0)
INT_VAR type            Movement type. Available types: 0=Default, 1=Disabled, 2=Alternate. (Default: 0)
INT_VAR tilemap_0, ...  Array "tilemap" with "num_tilemaps" entries. Number of required entries is calculated
                        from width × height.
                        Tilemap entries allow you to define optional fields for more fine-tuning:
                        - "tilemap_x" itself contains the primary tilemap (start) index value.
                        - "tilemap_x_count" defines the count of tiles for the primary tile. (Default: 1)
                        - "tilemap_x_y" defines "count" tile indices for the primary tile, where "y" ranges
                          from 0 to "count" - 1. For non-existing definitions it is assumed that tile index is
                          equal to tilemap index.
                        - "tilemap_x_second" defines a secondary (alternate) tile index. (Default: -1)
                        - "tilemap_x_flags" defines the overlay layer(s) to use. (Default: 0)
                        Alternate notation: $tilemap("0"), $tilemap("0", "count"), $tilemap("0", "0"), ...
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
STR_VAR tileset         Resref of the associated tileset (TIS) file. (Default: [empty])
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is returned
                        by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_alter_overlay
----------------------------------------------------
Action and patch function that alters individual tilemap definitions in an overlay structure on the WED handle.

INT_VAR overlay_index   Index of the overlay structure where tilemap definitions should by updated.
INT_VAR tilemap_0, ...  Tilemap definition that should be altered. Index specifies the tilemap index.
                        Tilemap entries allow you to define optional fields for more fine-tuning:
                        - "tilemap_x" itself contains the primary tilemap (start) index value.
                        - "tilemap_x_count" defines the count of tiles for the primary tile. (Default: 1)
                        - "tilemap_x_y" defines "count" tile indices for the primary tile, where "y" ranges
                          from 0 to "count" - 1.
                        - "tilemap_x_second" defines a secondary (alternate) tile index. (Default: -1)
                        - "tilemap_x_flags" defines the overlay layer(s) to use. (Default: 0)
                        Alternate notation: $tilemap("0"), $tilemap("0" "count"), ...
                        Skip entries or assign the constant "A7_WED_NO_CHANGE" to "tilemap_x" to keep the
                        original tilemap value.
                        Definitions for non-existing tilemap entries are ignored.
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is returned
                        by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_add_wall_poly
----------------------------------------------------
Action and patch function that adds a new wall polygon to the WED handle.

INT_VAR flags           Polygon flags. (Default: 0)
INT_VAR height          Polygon height. (Default: -1)
INT_VAR num_vertices    Number of vertices to add. (Default: 0)
INT_VAR vertex_0, ...   Array "vertex" with "num_vertices" vertex coordinates,
                        as "X coordinate | (Y coordinate << 16)".
                        Alternate notation: $vertex("0"), ...
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET index               Returns the index of the added wall polygon if successful, -1 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is
                        returned by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_alter_wall_poly
------------------------------------------------------
Action and patch function that alters base attributes of an existing wall polygon on the WED handle.

INT_VAR polygon_index   Index of the wall polygon to patch.
INT_VAR flags           New polygon flags. (Default: no change)
INT_VAR height          New polygon height. (Default: no change)
INT_VAR num_vertices    New number of vertices. If this parameter is specified then the current polygon
                        vertices are updated with the specified vertex definitions. (Default: no change)
INT_VAR vertex_0, ...   Array "vertex" with "num_vertices" vertex coordinates,
                        as "X coordinate | (Y coordinate << 16)".
                        Alternate notation: $vertex("0"), ...
                        Skip entries or assign the constant "VERTEX_NO_CHANGE" to keep the original vertex value.
                        Skipping definitions or using the constant for non-existing vertices will trigger an error.
                        This array is only considered if "num_vertices" is defined.
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is
                        returned by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_remove_wall_poly
-------------------------------------------------------
Action and patch function that removes a wall polygon from the WED handle.

INT_VAR polygon_index   Index of the wall polygon structure to remove.
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is
                        returned by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_add_door
-----------------------------------------------
Action and patch function that adds a new door structure to the WED handle, with optional tilemap definitions.

INT_VAR num_tilemaps    Number of tilemap entries to add. (Default: 0)
INT_VAR tilemap_0, ...  Array "tilemap" with "num_tilemaps" tilemap indices.
                        The following optional field is supported:
                        - "tilemap_x_swap" indicates whether primary and secondary tile indices should
                          swap places. It allows to reverse the open/closed states of door tiles. (Default: 0)
                        Alternate notation: $tilemap("0"), $tilemap("0" "swap", ...
INT_VAR tile_0, ...     Array "tile" with secondary tile indices, one for each tilemap definition,
                        that applied to the overlay tilemap structures.
                        Alternate notation: $tile("0"), ...
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR door_name       Name of the door structure. May not be longer than 8 characters.
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET index               Returns the index of the added door structure if successful, -1 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is
                        returned by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_alter_door
-------------------------------------------------
Action and patch function that alters base attributes of an existing door structure on the WED handle.

INT_VAR door_index      Index of the door structure to patch. Omit if you specify the door structure by name.
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
STR_VAR door_name       Name of the door structure to patch. Omit if you specify the door structure by index.
STR_VAR name            New name of the door structure. (Default: no change)
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is
                        returned by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_remove_door
--------------------------------------------------
Action and patch function that removes a door structure from the WED handle.

INT_VAR door_index      Index of the door structure to remove. Omit if you specify the door structure by name.
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
STR_VAR door_name       Name of the door structure to remove. Omit if you specify the door structure by index.
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is
                        returned by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_set_door_tilemap
-------------------------------------------------------
Action and patch function that assigns new tilemap definitions to an existing door structure on the WED handle.
Existing tilemap definitions are overwritten.

INT_VAR door_index      Index of the door structure where the tilemap definition should be added.
                        Omit if you specify the door structure by name.
INT_VAR num_tilemaps    Number of tilemap entries to set or update. (Default: 0)
                        Specifying 0 removes all tilemap entries.
INT_VAR tilemap_0, ...  Array "tilemap" with "num_tilemaps" tilemap indices.
                        The following optional field is supported:
                        - "tilemap_x_swap" indicates whether primary and secondary tile indices should
                          swap places. It allows to reverse the open/closed states of door tiles. (Default: 0)
                        Alternate notation: $tilemap("0"), $tilemap("0" "swap"), ...
                        Skip entries or assign the constant "A7_WED_NO_CHANGE" to keep the original tilemap value.
                        Skipping definitions or using the constant for non-existing tilemap definitions will
                        trigger an error.
INT_VAR tile_0, ...     Array "tile" with secondary tile indices, one for each specified tilemap definition,
                        that applied to the overlay tilemap structures.
                        Alternate notation: $tile("0"), ...
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
STR_VAR door_name       Name of the door structure where the tilemap definition should be added.
                        Omit if you specify the door structure by index.
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is
                        returned by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_add_door_poly
----------------------------------------------------
Action and patch function that adds a new (open or closed) polygon to an existing door structure on the WED handle.

INT_VAR door_index      Index of the door structure where the polygon should be added. Omit if you specify
                        the door structure by name.
INT_VAR closed          Specify 0 to define a new open polygon, specify 1 to define a new closed polygon.
INT_VAR flags           Polygon flags. (Default: 0)
INT_VAR height          Polygon height. (Default: -1)
INT_VAR num_vertices    Number of vertices to add. (Default: 0)
INT_VAR vertex_0, ...   Array "vertex" with "num_vertices" vertex coordinates,
                        as "X coordinate | (Y coordinate << 16)".
                        Alternate notation: $vertex("0"), ...
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
STR_VAR door_name       Name of the door structure where the polygon should be added. Omit if you specify
                        the door structure by index.
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET index               Returns the index of the added (open or closed) door polygon if successful, -1 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is
                        returned by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_alter_door_poly
------------------------------------------------------
Action and patch function that alters base attributes of an existing (open or closed) door polygon on the WED handle.

INT_VAR door_index      Index of the door structure with the polygon to patch. Omit if you specify the
                        door structure by name.
INT_VAR closed          Specify 0 to patch an open polygon, specify 1 to define a closed polygon.
INT_VAR polygon_index   Index of the (open or closed) door polygon to patch.
INT_VAR flags           New polygon flags. (Default: no change)
INT_VAR height          New polygon height. (Default: no change)
INT_VAR num_vertices    New number of vertices. If this parameter is specified then the current polygon
                        vertices are updated with the specified vertex definitions. (Default: no change)
INT_VAR vertex_0, ...   Array "vertex" with "num_vertices" vertex coordinates,
                        as "X coordinate | (Y coordinate << 16)".
                        Alternate notation: $vertex("0"), ...
                        Skip entries or assign the constant "VERTEX_NO_CHANGE" to keep the original vertex value.
                        Skipping definitions or using the constant for non-existing vertices will trigger an error.
                        This array is only considered if "num_vertices" is defined.
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
STR_VAR door_name       Name of the door structure with the polygon to patch. Omit if you specify the door
                        structure by index.
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is
                        returned by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_remove_door_poly
-------------------------------------------------------
Action and patch function that removes a (open or closed) polygon from a door structure on the WED handle.

INT_VAR closed          Specify 0 to remove an open polygon, specify 1 to remove a closed polygon.
INT_VAR polygon_index   Index of the polygon structure to remove.
INT_VAR door_index      Index of the door structure with the polygon to remove. Omit if you specify the door
                        structure by name.
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
STR_VAR door_name       Name of the door structure with the polygon to remove. Omit if you specify the door
                        structure by index.
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is
                        returned by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_wall_poly_move
-----------------------------------------------------
Action and patch function that moves a wall polygon on the WED handle by a specified amount in either direction.

INT_VAR polygon_index   Index of the wall polygon to move.
INT_VAR x               Amount to move in horizontal direction. Specify positive values to move to the right and negative
                        values to move to the left.
INT_VAR y               Amount to move in vertical direction. Specify positive values to move downwards and negative
                        values to move upwards.
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is returned
                        by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_door_poly_move
-----------------------------------------------------
Action and patch function that moves a door polygon on the WED handle by a specified amount in either direction.

INT_VAR closed          Specify 0 to move an open polygon, specify 1 to move a closed polygon.
INT_VAR door_index      Index of the door structure with the polygon to move. Omit if you specify the door
                        structure by name.
INT_VAR polygon_index   Index of the door polygon to move.
INT_VAR x               Amount to move in horizontal direction. Specify positive values to move to the right and
                        negative values to move to the left.
INT_VAR y               Amount to move in vertical direction. Specify positive values to move downwards and negative
                        values to move upwards.
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
STR_VAR door_name       Name of the door structure with the polygon to move. Omit if you specify the door
                        structure by index.
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is returned
                        by "a7#wed_open" (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_wall_poly_scale
------------------------------------------------------
Action and patch function that scales a wall polygon on the WED handle by a specified factor in either direction.

INT_VAR polygon_index   Index of the wall polygon to scale.
INT_VAR scale_x         Indicates whether to scale horizontally. (Default: 1)
INT_VAR scale_y         Indicates whether to scale vertically. (Default: 1)
INT_VAR numerator       Numerator (top value of a fraction) of the scaling factor. (Default: 1)
                        Note: A negative fractional value will mirror the polygon vertex coordinates around the anchor point.
INT_VAR denominator     Denominator (bottom value of a fraction) of the scaling factor. Must not be 0. (Default: 1)
                        Note: A negative fractional value will mirror the polygon vertex coordinates around the anchor point.
INT_VAR x               If "custom" anchor is specified then this value defines the absolute x coordinate of the anchor point. (Default: 0)
INT_VAR y               If "custom" anchor is specified then this value defines the absolute y coordinate of the anchor point. (Default: 0)
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
STR_VAR anchor          Anchor point for the scaling operation. Relative movement of the vertices is centered on this position.
                        (Default: "origin")
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
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is returned by "a7#wed_open"
                        (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_door_poly_scale
------------------------------------------------------
Action and patch function that scales a door polygon on the WED handle by a specified factor in either direction.

INT_VAR closed          Specify 0 to scale an open polygon, specify 1 to scale a closed polygon.
INT_VAR door_index      Index of the door structure with the polygon to scale. Omit if you specify the door
                        structure by name.
INT_VAR polygon_index   Index of the door polygon to scale.
INT_VAR scale_x         Indicates whether to scale horizontally. (Default: 1)
INT_VAR scale_y         Indicates whether to scale vertically. (Default: 1)
INT_VAR numerator       Numerator (top value of a fraction) of the scaling factor. (Default: 1)
                        Note: A negative fractional value will mirror the polygon vertex coordinates around the anchor point.
INT_VAR denominator     Denominator (bottom value of a fraction) of the scaling factor. Must not be 0. (Default: 1)
                        Note: A negative fractional value will mirror the polygon vertex coordinates around the anchor point.
INT_VAR x               If "custom" anchor is specified then this value defines the absolute x coordinate of the anchor point. (Default: 0)
INT_VAR y               If "custom" anchor is specified then this value defines the absolute y coordinate of the anchor point. (Default: 0)
INT_VAR silent          Specify 1 to suppress any feedback messages. (Default: 0)
STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
STR_VAR door_name       Name of the door structure with the polygon to scale. Omit if you specify the door
                        structure by index.
STR_VAR anchor          Anchor point for the scaling operation. Relative movement of the vertices is centered on this position.
                        (Default: "origin")
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
RET success             Returns 1 if the operation was successful, 0 otherwise.
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is returned by "a7#wed_open"
                        (which is "wed" by default).

DEFINE_DIMORPHIC_FUNCTION a7#batch_wed_rebuild_wallgroups
---------------------------------------------------------
Action and patch function that explicitly rebuilds the wallgroups section on the WED file.
Note: Calling this function explicitly is not necessary since wallgroups are automatically rebuilt by a call of "a7#wed_close".

STR_VAR wed             Name of the WED handle that is returned by "a7#wed_open" and other batch functions.
                        Can be omitted if the return value from "a7#wed_open" is used as is. (Default: "wed")
RET_ARRAY %wed%         Returns the updated WED handle. Specify the actual name of the WED handle that is returned by "a7#wed_open"
                        (which is "wed" by default).


****************
* 3. Changelog *
****************

Version 1.0
- Initial release
