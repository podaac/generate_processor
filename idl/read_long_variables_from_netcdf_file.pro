;  Copyright 2014, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION read_long_variables_from_netcdf_file,$
             i_filename,$
             i_test_parameter,$
             o_long_attributes_values

;------------------------------------------------------------------------------------------------
; Function read the 8 long variables from a NetCDF file.  The file is a combined NetCDF file
; as the result of the MODIS Level 2 Combiner code running.
;
;     'Start_Year'
;     'Start_Day'
;     'Start_Millisec'
;     'End_Year'
;     'End_Day',
;     'End_Millisec'
;     'Number_of_Scan_Lines'
;     'Pixels_per_Scan_Line'
;

; Load constants.

@modis_data_config.cfg

; Define local variables.

r_status = SUCCESS;

routine_name = 'read_long_variables_from_netcdf_file';

; Get the DEBUG_MODE if it is set.

debug_module = 'read_long_variables_from_netcdf_file.pro - INFO: ';
error_module = 'read_long_variables_from_netcdf_file.pro - ERROR: ';
debug_mode = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif


; Set our test parameter based on what's being passed in,
TEST_PARAMETER = STRUPCASE(GETENV('TEST_PARAMETER_STR'))
if (N_ELEMENTS(i_test_parameter) NE 0) then begin
    TEST_PARAMETER = i_test_parameter;
endif

; Get just the file name without the directory.

splitted_string = strsplit(i_filename, "/", /REGEX, /EXTRACT);
num_substrings = SIZE(splitted_string,/N_ELEMENTS); 
in_filename_only = splitted_string[num_substrings-1];

; For reading from NetCDF file, the names of the attributes does not contain spaces ' ' but underscore '_'.
; Since the array long_attributes_names is already defined in modis_data_config.cfg with spaces, we re-define it here with underscores.

long_attributes_names = [$
                          'Start_Year', $
                          'Start_Day', $
                          'Start_Millisec', $
                          'End_Year', $
                          'End_Day', $
                          'End_Millisec',$
                          'Number_of_Scan_Lines',$
                          'Pixels_per_Scan_Line']

; Array to store these LONG values.  Note that this cannot be used to read character variables.
; The array long_attributes_names is defined in modis_data_config.cfg file.

o_long_attributes_values = LONARR(size(long_attributes_names,/N_ELEMENTS));

;
; Read all the LONG global attributes.
;

attribute_name = '';

for attribute_index = 0, (size(o_long_attributes_values,/N_ELEMENTS) - 1) do begin

    ; Read one attribute at a time.

    attribute_name = long_attributes_names[attribute_index];
    if (debug_mode) then begin
        print, debug_module + 'Reading global attribute' + attribute_name + ' from file ' + i_filename;
    endif

    r_status = read_netcdf_global_attribute(i_filename,attribute_name,o_read_long_attribute_value);

    if (TEST_PARAMETER EQ "MISSING_GLOBAL_ATTRIBUTE_READ") then begin
        r_status = FAILURE;
    endif

    ; MODIS_L2P_ERROR_STEP 2. If global attributes cannot be read, ERROR sigevent thrown, returns.

    if (r_status NE SUCCESS) then begin
        msg_type = "error";
        msg = 'Cannot read long global attribute ' + attribute_name + ' from file ' + i_filename; 
        print, debug_module + msg;
        l_status = error_log_writer(routine_name,msg);

        r_status = FAILURE;
        ; Must return immediately.
        return, r_status
    endif

    if (debug_mode) then begin
        print, debug_module + 'Post read_netcdf_global_attribute: attribute_index                     = ', attribute_index;
        print, debug_module + 'Post read_netcdf_global_attribute: o_read_long_attribute_value              = ', o_read_long_attribute_value;
        print, debug_module + 'Post read_netcdf_global_attribute: SIZE(o_read_long_attribute_value,/TNAME) = ', SIZE(o_read_long_attribute_value,/TNAME);
    endif

    ; Do a sanity check on the validity of the value before attempting to save it.

    value_is_ok_to_convert_to_long = string_to_number_conversion(o_read_long_attribute_value, attribute_value_as_a_number);
    if (value_is_ok_to_convert_to_long) then begin
        o_long_attributes_values[attribute_index] = LONG(attribute_value_as_a_number);
    endif else begin
        print, error_module + 'Failed to confirm attribute_name ' + attribute_name + ' with o_read_long_attribute_value ', o_read_long_attribute_value, ' as a number from file ' + i_filename;
        r_status = FAILURE;
        ; Must return immediately.
        return, r_status
    endelse

;    ; Save it in the array.
;
;    o_long_attributes_values[attribute_index] = LONG(o_read_long_attribute_value);

    ; Do a sanity check on these attributes:
    ;                      'Start_Year'
    ;                      'Start_Day'
    ;                      'Start_Millisec'
    ;                      'End_Year'
    ;                      'End_Day'
    ;                      'End_Millisec'

    if (TEST_PARAMETER EQ "BAD_LONG_GLOBAL_ATTRIBUTE_READ") then begin
        o_long_attributes_values[attribute_index] = 0;
    endif

    ; MODIS_L2P_ERROR_STEP 3. If global attributes containing bad value, ERROR sigevent thrown, returns.

    ; Check for zero values for 'Start Year', 'Start Day', 'End Year', and 'End Day':
;long_attributes_names[attribute_index]
;1234567890123456789012345678901234567890
;         10        20        30k

    if ((((attribute_name EQ 'Start_Year') OR (attribute_name EQ 'Start_Day')) OR    $
        ((attribute_name EQ 'End_Year')    OR (attribute_name EQ 'End_Day')))  AND  $
        (o_long_attributes_values[attribute_index] EQ 0)) then begin

        msg_type = "error";
        msg = "Cannot read long global attribute " + attribute_name + " contains bad value " + STRTRIM(STRING(o_long_attributes_values[attribute_index]),2) + " from file " + i_filename;
        print, debug_module + msg;
        l_status = error_log_writer(routine_name,msg);

        ; No need to keep going.  Exiting now.
        r_status = FAILURE;
        return, r_status;
    endif

    ; Check for negative values for the 'Start Millisec' and 'End Millisec' attributes.  Note that these values can be zero.

    ;Start_Year_index     = 0;
    ;Start_Day_index      = 1;
    ;Start_Millisec_index = 2;
    ;End_Year_index       = 3;
    ;End_Day_index        = 4;
    ;End_Millisec_index   = 5;
    ;Number_of_Scan_Lines_index = 6;
    ;Pixels_per_Scan_Line_index = 7;

    if (TEST_PARAMETER EQ "BAD_LONG_NEGATIVE_START_MILLISEC_GLOBAL_ATTRIBUTE_READ") then begin
        if (attribute_index EQ Start_Millisec_index) then o_long_attributes_values[attribute_index] = -1;
    endif
    if (TEST_PARAMETER EQ "BAD_LONG_NEGATIVE_END_MILLISEC_GLOBAL_ATTRIBUTE_READ") then begin
        if (attribute_index EQ End_Millisec_index) then o_long_attributes_values[attribute_index] = -1;
    endif

    if (((attribute_name EQ 'Start_Millisec') OR (attribute_name EQ 'End_Millisec'))  AND  $
        (o_long_attributes_values[attribute_index] LT 0)) then begin

        msg_type = "error";
        msg = "Cannot read long global attribute " + attribute_name + " contains negative value " + STRTRIM(STRING(o_long_attributes_values[attribute_index]),2) + " from file " + i_filename;
        print, debug_module + msg;
        l_status = error_log_writer(routine_name,msg);

        ; No need to keep going.  Exiting now.
        r_status = FAILURE;
        return, r_status;
    endif
endfor

return, r_status
end
