;  Copyright 2014, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION read_gds1_netcdf_one_variable,$
         i_file_name,$
         i_variable_short_name,$
         r_data_variable_structure

; Function read one variable from a NetCDF4 file along with its attributes and returns the structure r_data_variable_structure.
;
; Assumptions:
;
;   1. The NetCDF4 file exist.
;   2. The lat and lon ids have been defined for the size of the variable.  
;

;------------------------------------------------------------------------------------------------

; Load constants.

@data_const_config.cfg

; Define local variables.

o_read_status = SUCCESS;
l_verbose = 0;       Set to 1 if wish to see all the debug print messages.

debug_module = 'read_gds1_netcdf_one_variable:';
debug_mode = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif

;
; Create a catch block to catch error in interaction with FILE IO
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    msg = 'ERROR, Cannot open file for reading ' + i_file_name + '. Error status: ' + error_status
    print, debug_module + msg;
    donotcare = error_log_writer(debug_module,msg);
    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif

;
; Open file for reading only. 
;

file_id = ncdf_open(i_file_name,/NOWRITE);
CATCH, /CANCEL

;
; Create a catch block to catch error in interaction with FILE IO
;

CATCH, error_status 
if (error_status NE 0) then begin
    CATCH, /CANCEL
    msg = 'ERROR, Cannot get NCDF_VARID ' + i_variable_short_name + ' from file ' + i_file_name  + '. Error status: ' + error_status
    print, debug_module + msg;
    donotcare = error_log_writer(debug_module,msg);
    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif

varid = NCDF_VARID(file_id,i_variable_short_name);
CATCH, /CANCEL

; Get the actual variable.

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    msg = 'ERROR, Cannot get NCDF_VARGET for file_id ' + STRING(file_id) + ' varid ' + STRING(varid) + ' from file ' + i_file_name + '. Error status: ' + error_status
    print, debug_module + msg;
    donotcare = error_log_writer(debug_module,msg);
    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif

NCDF_VARGET, file_id, varid, r_variable_array;
CATCH, /CANCEL

; Get all the variable attributes, types, and values

read_status = get_netcdf_variable_attribute_info($
                  file_id,$
                  i_variable_short_name,$
                  o_attribute_info);

num_attributes = N_ELEMENTS(o_attribute_info);

if (debug_mode) then begin
    print, debug_module + 'INFO, variable_name = ' + i_variable_short_name + ', num_attributes = ', num_attributes;
endif

;
; Create a structure to return to callee.
;

modis_data_variable_str = {  $
  s_variable_array   : PTR_NEW(), $
  s_attributes_array : STRARR(num_attributes) $
};

r_data_variable_structure = replicate(modis_data_variable_str, 1)

; Create a pointer to point to the newly read variable array.
; The data type is dynamic.

r_data_variable_structure.s_variable_array = PTR_NEW(r_variable_array);
r_data_variable_structure.s_attributes_array = o_attribute_info;

; ---------- Close up shop ---------- 
NCDF_CLOSE, file_id;
return, o_read_status
end
