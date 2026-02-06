WeiDU function: FIND_FREE_ANIM_SLOT

Version:  2.0
Author:   Argent77
License:  MIT


DEFINE_DIMORPHIC_FUNCTION FIND_FREE_ANIM_SLOT
---------------------------------------------
Action and patch function that returns the first unoccupied creature animation slot in the defined range or of the
defined animation type.

Note: This function only supports EE games from patch version 2.0 and higher.

INT_VAR slot_min      Lower bound of the requested animation slot range for creature animations.
                      Optional, if "type" parameter is specified.
INT_VAR slot_max      Upper bound (exclusive) of the requested animation slot range for creature animations.
                      Optional, if "type" parameter is specified.
INT_VAR slot_step     Specifies how many slots to skip after each iteration. This parameter can be specified for
                      slot ranges or types. (Default: 1)
STR_VAR type          Instructs the function to find the first free creature animation slot that is compatible with
                      the specified animation type. Optionally, "slot_min" and "slot_max" parameters can be used to
                      further narrow down the applicable slot range.
                      Supported types:
                      - effect                  0x0000 - 0x0fff
                      - monster_quadrant        0x1000 - 0x1fff
                      - monster_multi           0x1000 - 0x1fff
                      - multi_new               0x1000 - 0x1fff
                      - monster_layered_spell   0x2000 - 0x2fff
                      - monster_ankheg          0x3000 - 0x3fff
                      - town_static             0x4000 - 0x4fff
                      - character               0x5000 - 0x5fff, 0x6000 - 0x6fff
                      - character_old           0x5000 - 0x5fff, 0x6000 - 0x6fff
                      - monster                 0x7000 - 0x7fff
                      - monster_old             0x7000 - 0x7fff
                      - monster_layered         0x8000 - 0x8fff
                      - monster_large           0x9000 - 0x9fff
                      - monster_large16         0xa000 - 0xafff
                      - ambient_static          0xb000 - 0xbfff
                      - ambient                 0xc000 - 0xcfff
                      - flying                  0xd000 - 0xdfff
                      - monster_icewind         0xe000 - 0xefff
                      - monster_planescape      0xf000 - 0xffff   (PST:EE only)
RET slot              Returns the first free creature animation slot according to the specifications.
                      Returns -1 if no free slots were found, the game isn't supported, or parameters are invalid.
