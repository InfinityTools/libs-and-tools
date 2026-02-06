// Function Overview:
// A patch function that scans the current 2da file for a matching entry (value) in the specified column and returns the associated first column value.
// DEFINE_PATCH_FUNCTION GET_2DA_KEY

// A patch function that scans the current 2da file for a matching entry (key) in the first table column and returns the associated value in the specified column.
// DEFINE_PATCH_FUNCTION GET_2DA_VALUE


/**
 * A patch function that scans the current 2da file for a matching entry (value) in the specified
 * column and returns the associated first column value.
 *
 * INT_VAR column         Table column index for the value to match. Specify -1 to search in any
 *                        column except the first column. Default: -1
 * INT_VAR case_sensitive Specify a non-zero value to perform a case-sensitive match. Default: 0
 * INT_VAR silent         Specify a non-zero value to suppress warning messages. Default: 0
 * STR_VAR value          The value to find in the table column specified by "column". No default value.
 * RET result             Value from the first column if a match is found. Empty string otherwise.
 */
DEFINE_PATCH_FUNCTION GET_2DA_KEY
INT_VAR
  column = "-1"
  case_sensitive = 0
  silent = 0
STR_VAR
  value = ~~
RET
  result
BEGIN
  SPRINT result ~~

  PATCH_IF (NOT ~%value%~ STR_EQ ~~ && column != 0) BEGIN
    READ_2DA_ENTRIES_NOW table 1
    FOR (row = 3; row < table; ++row) BEGIN
      SET col_min = (column < 0) ? 1 : column
      SET col_max = (column < 0) ? 32767 : column
      FOR (col = col_min; col <= col_max && ~%result%~ STR_EQ ~~; ++col) BEGIN
        PATCH_IF (VARIABLE_IS_SET $table(~%row%~ ~%col%~)) BEGIN
          SPRINT v $table(~%row%~ ~%col%~)
          PATCH_IF (case_sensitive != 0 && ~%v%~ STRING_EQUAL ~%value%~) BEGIN
            SPRINT result $table(~%row%~ ~0~)
            SET row = table
          END ELSE PATCH_IF (case_sensitive == 0 && ~%v%~ STRING_EQUAL_CASE ~%value%~) BEGIN
            SPRINT result $table(~%row%~ ~0~)
            SET row = table
          END
        END ELSE BEGIN
          SET col = col_max + 1
        END
      END
    END
  END ELSE PATCH_IF (silent == 0) BEGIN
    PATCH_IF (column == 0) BEGIN
      PATCH_WARN ~WARNING: Invalid column index: %column%~
    END ELSE PATCH_IF (~%value%~ STR_EQ ~~) BEGIN
      PATCH_WARN ~WARNING: No value specified~
    END
  END
END

/**
 * A patch function that scans the current 2da file for a matching entry (key) in the first
 * table column and returns the associated value in the specified column.
 *
 * INT_VAR column         Table column index for the value to return in "result". Default: 1
 * INT_VAR case_sensitive Specify a non-zero value to perform a case-sensitive match. Default: 0
 * INT_VAR silent         Specify a non-zero value to suppress warning messages. Default: 0
 * STR_VAR key            The string to find in the first column of the table. No default value.
 * RET result             Value from the specified column if a match is found. Empty string otherwise.
 */
DEFINE_PATCH_FUNCTION GET_2DA_VALUE
INT_VAR
  column = 1
  case_sensitive = 0
  silent = 0
STR_VAR
  key = ~~
RET
  result
BEGIN
  SPRINT result ~~

  PATCH_IF (NOT ~%key%~ STR_EQ ~~ && column > 0) BEGIN
    READ_2DA_ENTRIES_NOW table 1
    FOR (row = 3; row < table; ++row) BEGIN
      SPRINT k $table(~%row%~ ~0~)
      PATCH_IF ((case_sensitive != 0 && ~%k%~ STRING_EQUAL ~%key%~) ||
                (case_sensitive == 0 && ~%k%~ STRING_EQUAL_CASE ~%key%~)) BEGIN
        PATCH_IF (VARIABLE_IS_SET $table(~%row%~ ~%column%~)) BEGIN
          SPRINT result $table(~%row%~ ~%column%~)
          SET row = table
        END
      END
    END
  END ELSE PATCH_IF (silent == 0) BEGIN
    PATCH_IF (column <= 0) BEGIN
      PATCH_WARN ~WARNING: Invalid column index: %column%~
    END ELSE PATCH_IF (~%key%~ STR_EQ ~~) BEGIN
      PATCH_WARN ~WARNING: No key specified~
    END
  END
END
