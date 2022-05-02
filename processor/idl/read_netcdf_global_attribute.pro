;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$

FUNCTION read_netcdf_global_attribute,$
             i_netcdf_input_filename,$
             i_attribute_name,$
             o_attribute_value

; Function read one global attribute and returned it in o_attribute_value.
;
; Assumptions:
;
;   1. TBD 
;

;------------------------------------------------------------------------------------------------

; Load constants.

@modis_data_config.cfg

; Define local variables.

o_status = SUCCESS;
o_attribute_value = "";
routine_name = 'read_netcdf_global_attribute:';
debug_flag = 0;

if (GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')  EQ 'true') then debug_flag = 1; 

;
; Create a catch block to catch error in interaction with FILE IO
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'read_netcdf_global_attributes: ERROR, Cannot open file for reading ' + i_netcdf_input_filename;
    o_status = FAILURE;
    ; Must return immediately.
    return, o_status
endif

;
; Open file for reading only. 
;

if (debug_flag) then begin
    print, routine_name, 'NCDF_OPEN() i_netcdf_input_filename = ' + i_netcdf_input_filename;
endif

file_id = NCDF_OPEN(i_netcdf_input_filename,/NOWRITE);

;
; Create a catch block to catch error in interaction with FILE IO
;
            
CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
;    print, 'read_netcdf_global_attribute: ERROR, Cannot get global attribute ' + i_attribute_name + ' from file ' + i_netcdf_input_filename
    o_status = FAILURE;
    
    if (debug_flag) then begin
        print, 'read_netcdf_global_attribute: NCDF_CLOSE ', file_id;
    endif
    NCDF_CLOSE, file_id;
    CATCH, /CANCEL
    ; Must return immediately.
    return, o_status
endif

if (debug_flag) then begin
    print, 'read_netcdf_global_attribute: INFO, NCDF_ATTGET /GLOBAL ' + i_attribute_name
endif
NCDF_ATTGET, file_id, /GLOBAL, i_attribute_name, attribute_value
CATCH, /CANCEL

att_value_as_string = STRTRIM(STRING(attribute_value),2);  Convert attribute to string even the integer, float, double and such.
o_attribute_value   = att_value_as_string

; ---------- Close up shop ---------- 

;
; Create a catch block to catch error in interaction with FILE IO.
;

CATCH, error_status
if (error_status NE 0) then begin
   CATCH, /CANCEL
   print, 'read_netcdf_global_attribute: ERROR, Cannot close input file: ', i_netcdf_input_filename;
   o_status = FAILURE;
   ; Must return immediately.
   return, o_status
endif

if (debug_flag) then begin
    print, routine_name, 'NCDF_CLOSE() file_id = ', file_id;
endif

NCDF_CLOSE, file_id;
CATCH, /CANCEL

return, o_status;
end
