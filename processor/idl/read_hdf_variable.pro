;  Copyright 2006, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: read_hdf_variable.pro,v 1.2 2006/06/01 21:08:24 qchau Exp $
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
; New Request #xxxx

FUNCTION read_hdf_variable,$
         i_filename,$
         i_variable_short_name,$
         r_dataset_array,$
         r_slope,$
         r_intercept,$
         r_data_type,$
         r_fill_value,$
         r_valid_min,$
         r_valid_max

; Function read a dataset from an HDF formatted file and return the array containing the
; data sets with 'r_' as the beginning of the name.
;
; Assumptions:
;
;   1. The file is opened already. 
;   2. The HDF variable has slope, and intercept attributes associated with it. 
;   3. TBD.
;   4. TBD. 
;   5. TBD. 
;

;------------------------------------------------------------------------------------------------

; Load constants.

@data_const_config.cfg

; Define local variables.

r_status = SUCCESS;

routine_name = 'read_hdf_variable';
debug_mode = 0;

if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif

; Check to see if variable exist in file.
l_variable_exist = is_hdf_variable_in_file($
                       i_filename,$
                       i_variable_short_name);

if (l_variable_exist NE 1) then begin
    print, 'read_hdf_variable: INFO, No variable ' + i_variable_short_name + ' found in file [' + i_filename + ']';
    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif

l_slope_attribute_name      = 'slope';     HDF's attribute names associated with this variable.
l_intercept_attribute_name  = 'intercept';

; Output attributes:

r_slope      = 0.0;
r_intercept  = 0.0;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'read_hdf_variable: ERROR, Failed in HDF_SD_START function:' + i_filename;
    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif
sd_id = HDF_SD_START(i_filename,/READ); Function HDF_SD_START does not return any status.
CATCH, /CANCEL

; Get the index to the actual variable.

sd_index = HDF_SD_NAMETOINDEX(sd_id,i_variable_short_name);

if (sd_index EQ -1) then begin
    print, 'read_hdf_variable: ERROR, Cannot get index of HDF variable name: ' + i_variable_short_name + ' in file ' + i_filename;
    HDF_SD_END, sd_id;
    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif


; Get the dataset id.

sds_id = HDF_SD_SELECT(sd_id,sd_index);

; Get some info on the variable at hand.

HDF_SD_GETINFO,sds_id,ndims=ndims,dims=dims,type=r_data_type

; Read the slab of Sea Surface Temperature from HDF file.

HDF_SD_GETDATA,sds_id,r_dataset_array;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Read the associated attributes of the variable.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Get index into the slope attribute. 

slope_index = HDF_SD_ATTRFIND(sds_id,l_slope_attribute_name);

if (slope_index EQ -1) then begin
    print, 'read_hdf_variable: ERROR, Cannot get index of HDF variable ' + i_variable_short_name + ', attribute name: ' + l_slope_attribute_name + ' in file ' + i_filename;
    HDF_SD_END, sd_id;
    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif

; Get the attribute info.  Function HDF_SD_ATTRINFO does not return any status.

HDF_SD_ATTRINFO,sds_id,slope_index,NAME=n, TYPE=t, $
    COUNT=c, DATA=r_slope;

; Get index into the intercept attribute.

intercept_index = HDF_SD_ATTRFIND(sds_id,l_intercept_attribute_name);

if (intercept_index EQ -1) then begin
    print, 'read_hdf_variable: ERROR, Cannot get index of HDF variable ' + i_variable_short_name + ', attribute name: ' + l_intercept_attribute_name + ' in file ' + i_filename;
    HDF_SD_END, sd_id;
    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif

; Get the attribute info.  Function HDF_SD_ATTRINFO does not return any status.

HDF_SD_ATTRINFO,sds_id,intercept_index,NAME=n, TYPE=t, $
    COUNT=c, DATA=r_intercept;


; Print debug.
debug_this = 0;

if (debug_this EQ 1) then begin
    print, 'i_variable_short_name = ',i_variable_short_name;
    print, 'slope_index = ',slope_index;
    print, 'r_slope = ',r_slope;
    print, 'r_intercept = ',r_intercept;
    print, 'intercept_index = ',intercept_index;
    print, 'ndims = ',ndims;
    print, 'r_data_type    = ',r_data_type;
    print, 'dims[0] = ',dims[0];
    print, 'dims[1] = ',dims[1];
endif

;
; For debugging purpose only.  This only work for array of 2 dimension with fill value = -32767
; This section of the code should only be run while reading just one file. 
; Most of the time, the value of show_image should be set to 0.

show_image = 0;  Change to zero if do not wish to see use the IIMAGE tool to view the image.

if (show_image EQ 1) then begin
    ;
    ; Massage the HDF variable to removed value -32767, and multiply by slope and add intercept
    ;
    print, 'read_hdf_variable: Applying slope and intercept to data...';

    fill_value = -32767;
    num_corrected = 0L;
    num_filled_to_zero = 0L;
    corrected_data = FLTARR(dims[0],dims[1]);  Set to zero first. 

    corrected_data = r_dataset_array;

    ; IDL is column major, loop through column fastest by place dim1 on the inside.

; For now, this only work for INT data type.
if (r_data_type EQ 'INT') then begin
    for dim2 = 0, dims[1] - 1 do begin
        for dim1 = 0, dims[0] - 1 do begin
                ; Do nothing if value is fill_value otherwise, apply the correction.
                if (r_dataset_array[dim1,dim2] EQ fill_value) then begin
                   corrected_data[dim1,dim2] = 0.0; 
                   num_filled_to_zero = num_filled_to_zero + 1; 
                endif else begin
                   corrected_data[dim1,dim2] = (FLOAT(r_dataset_array[dim1,dim2] * r_slope)) + r_intercept;   y = mx + b;
                   num_corrected = num_corrected + 1;
                endelse
        endfor
    endfor
endif


    help, r_dataset_array; 
    print, size(corrected_data);
    print, 'corrected_data[0,0] = ', corrected_data[0,0];
    print, 'corrected_data[1,0] = ', corrected_data[1,0];
    print, 'corrected_data[2,0] = ', corrected_data[2,0];
    print, 'corrected_data[3,0] = ', corrected_data[3,0];
    print, 'corrected_data[4,0] = ', corrected_data[4,0];
    print, 'corrected_data[dims[0] - 1,0] = ', corrected_data[dims[0] - 1,0];
    print, 'corrected_data[dims[0] - 1,1] = ', corrected_data[dims[0] - 1,1];
    print, 'corrected_data[dims[0] - 1,2] = ', corrected_data[dims[0] - 1,2];
    print, 'corrected_data[dims[0] - 1,3] = ', corrected_data[dims[0] - 1,3];
    print, 'corrected_data[dims[0] - 1,4] = ', corrected_data[dims[0] - 1,4];
    print, 'corrected_data[dims[0] - 1,5] = ', corrected_data[dims[0] - 1,5];
    print, 'min = ', min(corrected_data);
    print, 'max = ', max(corrected_data);

    print, 'num_corrected      = ', num_corrected; 
    print, 'num_filled_to_zero = ', num_filled_to_zero; 

    iimage, rotate(corrected_data,7);
endif

; Use a new function get_hdf_variable_attributes to get the variable attribute to avoid the error from IDL when an attribute does not exist:
;
;     'HDF_SD_ATTRFIND: Unable to find the HDF-SD attribute named'

attribute_name = 'fill_value';
attribute_read_status = get_hdf_variable_attributes($
                            sd_id,$
                            sds_id,$
                            i_variable_short_name,$
                            attribute_name,$
                            r_fill_value);

if (debug_mode) then begin
    help, i_variable_short_name;
    help, attribute_name;
    help, r_fill_value;
endif

attribute_name = 'valid_min';
attribute_read_status = get_hdf_variable_attributes($
                            sd_id,$
                            sds_id,$
                            i_variable_short_name,$
                            attribute_name,$
                            r_valid_min);

if (debug_mode) then begin
    help, i_variable_short_name;
    help, attribute_name;
    help, r_valid_min;
endif

attribute_name = 'valid_max';
attribute_read_status = get_hdf_variable_attributes($
                            sd_id,$
                            sds_id,$
                            i_variable_short_name,$
                            attribute_name,$
                            r_valid_max);

if (debug_mode) then begin
    help, i_variable_short_name;
    help, attribute_name;
    help, r_valid_max;
endif

; ---------- Close up shop ---------- 

HDF_SD_END, sd_id;
return, r_status
end
