;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION get_hdf_variable_attributes,$
             i_sd_id,$
             i_dataset_id,$
             i_dataset_name,$
             i_attribute_name,$
             o_attribute_value

; Function returns an attribute value from a variable given the attribute name.   If the attribute does not exist, the value returned will be undefined.
;
; Assumptions:
;
;   1.  HDF file has been opened successfully.
;

;------------------------------------------------------------------------------------------------

; Load constants.

@data_const_config.cfg

; Define local variables.

o_read_status = SUCCESS;
debug_mode = 0;

if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif

if (debug_mode) then begin
    print, 'get_hdf_variable_attributes: INFO, i_sd_id  = ', i_sd_id;
    print, 'get_hdf_variable_attributes: INFO, i_dataset_id = ', i_dataset_id;
    print, 'get_hdf_variable_attributes: INFO, i_dataset_name = ',i_dataset_name;
    print, 'get_hdf_variable_attributes: INFO, i_attribute_name = ',i_attribute_name;
endif

; Set default return value as undefined.

tempvar = SIZE(TEMPORARY(o_attribute_value))

; Get attribute information
CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'get_hdf_variable_attributes: ERROR, Function HDF_SD_GETINFO failed for file id ' + STRTRIM(STRING(i_file_id),2);
    o_read_status = FAILURE;
    ; Must return immediately.
    return, o_read_status
endif

HDF_SD_GETINFO, i_dataset_id,name = i_dataset_name, natts = num_attributes, $ 
                             ndim = num_dims,       dims  = dimvector;
CATCH, /CANCEL
if (debug_mode) then begin
    print, 'get_hdf_variable_attributes: INFO, num_attributes = ', num_attributes;
endif

; Now look in the list of attribute for the attribute name.  If find it, fetch it and save it in o_attribute_value.

found_attribute_flag = 0
attribute_index = 0;

while (found_attribute_flag EQ 0) AND (attribute_index LT num_attributes) do begin
    ; Get the attribute name associated with attribute_index
    HDF_SD_ATTRINFO, i_dataset_id, attribute_index, name = attribute_name_from_file
    if (attribute_name_from_file EQ i_attribute_name) then begin
        HDF_SD_ATTRINFO,i_dataset_id,attribute_index,NAME  = n, TYPE = t, $
                                                     COUNT = c, DATA = o_attribute_value;
        found_attribute_flag  = 1;
    endif
    attribute_index = attribute_index + 1;
endwhile

; If the attribute name was found, the value of o_attribute_value would be defined and set to whatever was read from the file.

;help, i_attribute_name;
;help, o_attribute_value;
;HDF_SD_END, i_sd_id
;stop;

; ---------- Close up shop ---------- 
return, o_read_status;
end
