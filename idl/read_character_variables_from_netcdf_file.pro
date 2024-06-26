;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION read_character_variables_from_netcdf_file,$
             i_filename,$
             o_sensor_name,$
             o_start_node,$
             o_end_node,$
             o_day_or_night,$
             o_platform,$
             o_title,$
             o_comment,$
             o_dsd_entry_id,$
             i_test_parameter 
;------------------------------------------------------------------------------------------------

; Load constants.

@modis_data_config.cfg

; Define local variables.

r_status = SUCCESS;

routine_name = "read_character_variables_from_netcdf_file";

; Set our test parameter based on what's being passed in,
TEST_PARAMETER = STRUPCASE(GETENV('TEST_PARAMETER_STR'))
if (N_ELEMENTS(i_test_parameter) NE 0) then begin
    TEST_PARAMETER = i_test_parameter;
endif

; Get the DEBUG_MODE if it is set.

debug_module = 'read_character_variables_from_netcdf_file:';
debug_mode = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif

splitted_string = strsplit(i_filename, "/", /REGEX, /EXTRACT);
num_substrings = SIZE(splitted_string,/N_ELEMENTS);
in_filename_only = splitted_string[num_substrings-1];

o_sensor_name = '';
o_platform = '';
o_title    = '';
o_dsd_entry_id = '';

;
; Read other character attributes.
;

attribute_name = 'Sensor_Name';
r_status = read_netcdf_global_attribute(i_filename,attribute_name,o_sensor_name);
if (TEST_PARAMETER EQ "BAD_SENSOR_NAME_GLOBAL_ATTRIBUTE_READ") then begin
    r_status = FAILURE;
endif

if (r_status NE SUCCESS) then begin
    msg_type = "error";
    msg = 'read_character_variables_from_netcdf_file.pro - ERROR: Cannot read string global attribute ' + attribute_name + ' from file ' + i_filename;
    print, msg;
    donotcare = error_log_writer(routine_name,msg);
    return, r_status;
endif

; Do sanity check on the value.

if (STRMATCH(o_sensor_name,'*VIIRS*',/FOLD_CASE) NE 1) then begin
    msg = "read_character_variables_from_netcdf_file.pro - INFO: o_sensor_name[" + o_sensor_name + "] does not contain VIIRS";
    print, msg;
    if (STRMATCH(o_sensor_name,'*MODIS*',/FOLD_CASE) NE 1) then begin
        msg_type = "error";
        msg = "read_character_variables_from_netcdf_file.pro - ERROR: Cannot read string global attribute " + attribute_name + " due to invalid value in file " + i_filename + ".  Current value " + o_sensor_name;
        print, msg;
        donotcare = echo_message_to_screen(routine_name,msg,msg_type);
        donotcare = error_log_writer(routine_name,msg);
        status = FAILURE;
        ; Must return immediately.
        return, status;
    endif
endif

attribute_name = 'Start_Node';
r_status = read_netcdf_global_attribute(i_filename,attribute_name,o_start_node);
if (TEST_PARAMETER EQ "BAD_START_NODE_GLOBAL_ATTRIBUTE_READ") then begin
    r_status = FAILURE;
endif
if (r_status NE SUCCESS) then begin
    msg_type = "error";
    msg = 'read_character_variables_from_netcdf_file.pro - ERROR: Cannot read string global attribute ' + attribute_name + ' from file ' + i_filename;
    print, msg;
    donotcare = error_log_writer(routine_name,msg);
    return, r_status;
endif

; Do a sanity check on the attribute.

if ((o_start_node NE 'Ascending') AND (o_start_node NE 'Descending')) then begin
    msg_type = "error";
    msg = "Cannot read string global attribute " + attribute_name + " due to invalid value in file " + i_filename + ".  Current value " + o_start_node;
    donotcare = echo_message_to_screen(routine_name,msg,msg_type);
    donotcare = error_log_writer(routine_name,msg);
   
    status = FAILURE;
    ; Must return immediately.
    return, status;
endif

attribute_name = 'End_Node';
r_status = read_netcdf_global_attribute(i_filename,attribute_name,o_end_node);
if (TEST_PARAMETER EQ "BAD_END_NODE_GLOBAL_ATTRIBUTE_READ") then begin
    r_status = FAILURE;
endif
if (r_status NE SUCCESS) then begin
    msg_type = "error";
    msg = 'read_character_variables_from_netcdf_file.pro - ERROR: Cannot read string global attribute ' + attribute_name + ' from file ' + i_filename;
    print, msg;
    donotcare = error_log_writer(routine_name,msg);
    return, r_status;
endif

; Do a sanity check on the attribute.

if ((o_end_node NE 'Ascending') AND (o_end_node NE 'Descending')) then begin
    msg_type = "error";
    msg = "Cannot read string global attribute " + attribute_name + " due to invalid value in file " + i_filename + ".  Current value " + o_end_node;
    donotcare = echo_message_to_screen(routine_name,msg,msg_type);
    donotcare = error_log_writer(routine_name,msg);

    status = FAILURE;
    ; Must return immediately.
    return, status;
endif


attribute_name = 'Day_or_Night';
r_status = read_netcdf_global_attribute(i_filename,attribute_name,r_day_or_night);
if (TEST_PARAMETER EQ "BAD_DAY_OR_NIGHT_GLOBAL_ATTRIBUTE_READ") then begin
    r_status = FAILURE;
endif
if (r_status NE SUCCESS) then begin
    msg_type = "error";
    msg = 'read_character_variables_from_netcdf_file.pro - ERROR: Cannot read string global attribute ' + attribute_name + ' from file ' + i_filename;
    print, msg;
    donotcare = error_log_writer(routine_name,msg);
    return, r_status;
endif

; Remove the non-ascii character from variable.

o_day_or_night = convert_to_ascii_string(r_day_or_night);

; Do a sanity check on the attribute.

if ((o_day_or_night NE 'Day') AND $
   ((o_day_or_night NE 'Night') AND (o_day_or_night NE 'Mixed')) ) then begin
    msg_type = "error";
    msg = "Cannot read string global attribute " + attribute_name + " due to invalid value in file " + i_filename + ".  Current value " + o_day_or_night;
    donotcare = echo_message_to_screen(routine_name,msg,msg_type);
    donotcare = error_log_writer(routine_name,msg);

    status = FAILURE;
    ; Must return immediately.
    return, status;
endif

; Prepend a pre-existing.

warning = "; WARNING Some applications are unable to properly handle signed byte values. If values are encountered > 127, please subtract 256 from this reported value";
o_comment = const_comment + "; " + o_day_or_night + ", Start Node:" + convert_to_ascii_string(o_start_node) + ", End Node:" + convert_to_ascii_string(o_end_node) + warning;

if ((o_sensor_name EQ 'MODISA') OR (o_sensor_name EQ 'HMODISA')) then begin
    o_sensor_name = 'MODIS_A';
    o_platform = 'Aqua';
    o_title    = 'MODIS Aqua L2P SST';
endif else begin
    if ((o_sensor_name EQ 'MODIST') OR (o_sensor_name EQ 'HMODIST')) then begin
        o_sensor_name = 'MODIS_T';
        o_platform = 'Terra';
        o_title    = 'MODIS Terra L2P SST';
    endif
endelse

; Note from 5/2014:
;
; The NetCDF file for test files from 2007 has the o_sensor_name value as 'MODIS'
; We have to determine if it is Aqua or Terra from the first character of the name.

name_only = '';
if (o_title EQ '') then begin
    ; Get the name only
    name_only = FILE_BASENAME(i_filename);
    ; The refined files has this /some_directory/refined_A2007079195500.LAC_GSSTD so we may need to skip "refined_" to get to the A letter.
    ;                                            01234567890
    ;
    first_character = STRMID(name_only,0,1);
    if (STRPOS(name_only,'refined_') EQ 0) then begin
        first_character = STRMID(name_only,8,1);  Skip the "refined_" to get to letter A.
    endif
    if (first_character EQ 'A') then begin
        o_sensor_name = 'MODIS_A';
        o_platform = 'Aqua';
        o_title    = 'MODIS Aqua L2P SST';
    endif

    if (first_character EQ 'T') then begin
        o_sensor_name = 'MODIS_T';
        o_platform = 'Terra';
        o_title    = 'MODIS Terra L2P SST';
    endif
    if (first_character EQ 'V') then begin
        o_sensor_name = 'VIIRS';
        o_platform = 'Suomi-NPP';
        o_title    = 'VIIRS L2P Sea Surface Skin Temperature';
    endif
endif

; Because the VIIRS sensor has different version, we have to bring the constants defined in viirs_data_config.cfg here.
if (o_sensor_name EQ 'VIIRS') then begin
    @viirs_data_config.cfg
    o_dsd_entry_id = o_sensor_name + "-JPL-L2P" +  "-v" + const_gds2_product_version; 
endif else begin
    o_dsd_entry_id = o_sensor_name + "-JPL-L2P" +  "-v" + const_gds2_product_version;
endelse

if (debug_mode) then begin
    print, debug_module,'o_sensor_name[', o_sensor_name, ']'
    print, debug_module,'i_filename[', i_filename, ']'
    print, debug_module,'o_title   [', o_title, ']'
endif

return, r_status
end
