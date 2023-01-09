;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;

FUNCTION validate_day_of_year_field, i_year, i_yearday

; Function to validate the day of year field.  It uses the same logic as calday function but does not stop processing if an error
; is found.  The input parameters are expected to be numbers.

; Load constants.

@modis_data_config.cfg

o_status = SUCCESS;

; Variables for reporting sigevents.

routine_name = "validate_day_of_year_field";
msg_type = "";
msg = ""
i_data = "";

; Get the DEBUG_MODE if it is set.

debug_module = 'validate_day_of_year_field:';
debug_mode = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif

;debug_mode = 1;

days_table = INTARR(12,2);

; The 1st row contains the number of days up to the end of the month for each month in a non-leap year.
; The 2nd row contains the number of days up to the end of the month for each month in a leap year.

days_table = [ $
                 [ 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365 ], $
                 [ 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366 ]  $
             ];

; Check if the input are numbers.  Return failure if either one is not.

if (~ISA(i_year,/NUMBER)) then begin
    print, debug_module +  'ERROR:Field i_year ', i_year , ' is not a number.';
    o_status = FAILURE;
    return, o_status;
endif

if (~ISA(i_yearday,/NUMBER)) then begin
    print, debug_module +  'ERROR:Field i_yearday ', i_yearday, ' is not a number.'
    o_status = FAILURE;
    return, o_status;
endif

; Check if the input are numbers.  Return failure if either one is zero.

if (i_year EQ 0) then begin
    print, debug_module +  'ERROR:Field i_year is ZERO and not a valid value.';
    o_status = FAILURE;
    return, o_status;
endif

if (i_yearday EQ 0) then begin
    print, debug_module +  'ERROR:Field i_yearday is ZERO and not a valid value.';
    o_status = FAILURE;
    return, o_status;
endif

; Start out assume the year is not leap.
; Note that the value correspond with the values in days_table array.
; A value of 1 corresponds with index of 1 for 366 days.

leap_flag = 0;

; Determine if the year is a leap year or not.
IF (((i_year MOD 4 eq 0) AND (i_year MOD 100 ne 0)) OR (i_year MOD 400 eq 0)) THEN leap_flag = 1;

; Do the error check on the day of year.
IF (i_yearday GT days_table[11, leap_flag]) OR (i_yearday LT 1) THEN BEGIN
    print, debug_module +  "year day must be >= 1 and <= ", days_table[11, leap_flag];
    o_status = FAILURE;
ENDIF

if (debug_mode) then begin
    print, debug_module + "i_year    = ", i_year;
    print, debug_module + "i_yearday = ", i_yearday;
    print, debug_module + "leap_flag = ", leap_flag;
    print, debug_module + "o_status  = ", o_status
endif
return, o_status
END
