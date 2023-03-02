;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION convert_additional_day_netcdf_variables_to_gds2,i_filename,i_out_filename,$
                i_num_bad_scan_lines, $
                i_bad_scan_lines_array, $
                i_test_parameter

; Function convert additional NetCDF variables to NetCDF if the "Day or Night" is "Day"
;
; Assumptions and notes:
;
;   1. Modifications were made in 5/2014 to add more error handlings;
;
;       https://podaac-redmine.jpl.nasa.gov/issues/2349 MODIS Level 2 Combiner and MODIS Level 2P Processing to read supporting attributes
;
;      The steps will be preceded with MODIS_L2P_ERROR_STEP n to allow easy search.
;------------------------------------------------------------------------------------------------

; Load constants.

@modis_data_config.cfg

; Define local variables.

r_status = SUCCESS;

; Set our test parameter based on what's being passed in,
TEST_PARAMETER = STRUPCASE(GETENV('TEST_PARAMETER_STR'))
if (N_ELEMENTS(i_test_parameter) NE 0) then begin
    TEST_PARAMETER = i_test_parameter;
endif

routine_name = "convert_additional_day_netcdf_variables_to_gds2";
msg_type = "";
msg = ""
i_data = "";

; A few extra parameters so signify if a particular variable should be written out or not.
; If we cannot read a variable in, we cannot do anything with it including writing it out.

ok_to_write_chlor_a_flag = 0;
ok_to_write_K_490_flag   = 0;

; Get the DEBUG_MODE if it is set.

debug_module = 'convert_additional_day_netcdf_variables_to_gds2:';
debug_mode = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif

i_variable_short_name = 'chlor_a';

; Check first to see if the variable exist.  If it does, we will attempt to read it.
; Otherwise, don't try to read it.
variable_exist_flag = is_netcdf_variable_in_file($
                          i_filename,$
                          i_variable_short_name);

; BEGIN_CHECK_CHLOR_A_VARIABLE_EXIST ---------- ---------- ---------- ---------- ---------- ---------- ----------
if (variable_exist_flag) then begin

r_status = read_gds1_netcdf_one_variable(i_filename,i_variable_short_name,$
               o_data_variable_structure);
ok_to_write_chlor_a_flag = 1;

if (TEST_PARAMETER EQ "BAD_CHLOR_A_VARIABLE_READ") then begin
    r_status = FAILURE;
endif

if (debug_mode) then begin
    print, debug_module, 'i_filename ', i_filename, ' i_variable_short_name ', i_variable_short_name, ' variable_exist_flag ', variable_exist_flag, ' TEST_PARAMETER ', TEST_PARAMETER, ' r_status ', r_status
endif

; MODIS_L2P_ERROR_STEP 22: If cannot read optional additional day variable 'chlor_a' from day file, WARN sigevent thrown, keep going 
if (r_status NE SUCCESS) then begin
    msg_type = "warning";
    msg = 'Failed in ' + routine_name + ' to read variable ' + i_variable_short_name + ' in file ' + i_filename;
    print, debug_module + msg;
    donotcare = error_log_writer(routine_name,msg);
    donotcare = wrapper_ghrsst_notify_operator($
                    routine_name,$
                    msg_type,$
                    msg,$
                    i_data);
    ok_to_write_chlor_a_flag = 0;
    ; Keeping
endif

if (ok_to_write_chlor_a_flag) then begin
    r_dataset_array =  *(o_data_variable_structure.s_variable_array);
    PTR_FREE, o_data_variable_structure.s_variable_array;
    r_status = find_netcdf_variable_attribute_info('_FillValue',   o_data_variable_structure.s_attributes_array,r_fill_value);
    r_status = find_netcdf_variable_attribute_info('scale_factor', o_data_variable_structure.s_attributes_array,r_slope);
    r_status = find_netcdf_variable_attribute_info('add_offset',   o_data_variable_structure.s_attributes_array,r_intercept);
    r_status = find_netcdf_variable_attribute_info('valid_min',    o_data_variable_structure.s_attributes_array,r_valid_min);
    r_status = find_netcdf_variable_attribute_info('valid_max',    o_data_variable_structure.s_attributes_array,r_valid_max);
    data_type_as_int = SIZE(r_dataset_array,/TYPE);
    r_data_type = convert_int_type_to_char_type(data_type_as_int);

    if (debug_mode) then begin
        print, debug_module,'IMMEDIATELY_AFTER_READ_NETCDF_VARIABLE:i_filename    : ', i_filename;
        print, debug_module,'IMMEDIATELY_AFTER_READ_NETCDF_VARIABLE:i_dataset_name: ', i_variable_short_name;
        print, debug_module,'IMMEDIATELY_AFTER_READ_NETCDF_VARIABLE:r_data_type   : ', r_data_type;
        if (N_ELEMENTS(r_fill_value)) then begin
            print, debug_module,'IMMEDIATELY_AFTER_READ_NETCDF_VARIABLE:r_fill_value  : ', r_fill_value;
        endif
        if (N_ELEMENTS(r_valid_min)) then begin
            print, debug_module,'IMMEDIATELY_AFTER_READ_NETCDF_VARIABLE:r_valid_min   : ', r_valid_min;
        endif
        if (N_ELEMENTS(r_valid_max)) then begin
            print, debug_module,'IMMEDIATELY_AFTER_READ_NETCDF_VARIABLE:r_valid_max   : ', r_valid_max;
        endif
    endif
endif

i_dataset_name = 'chlorophyll_a';
i_units = 'mg m^-3';

; If the fill value is provided from HDF file, we attempt to use it
if (N_ELEMENTS(r_fill_value)) then begin
    ; Do nothing, the variable r_fill_value is already contained the value we want.
endif else begin
    ; If the fill value is not provided, we use a constant, which is hard-coded.
    r_fill_value = -1.0;
endelse

; If the valid_min value is provided from HDF file, we attempt to use it

if (N_ELEMENTS(r_valid_min)) then begin
    ; Do nothing, the variable is already contained the value we want.
endif else begin
    ; If the value is not provided, we use a constant, which is hard-coded.
    r_valid_min = 0.0;
endelse

; If the valid_max value is provided from HDF file, we attempt to use it

if (N_ELEMENTS(r_valid_max)) then begin
    ; Do nothing, the variable is already contained the value we want.
endif else begin
    ; If the value is not provided, we use a constant, which is hard-coded.
    r_valid_max = 200.0;
endelse

i_coordinates = "lon lat";
i_long_name =  'Chlorophyll Concentration, OC3 Algorithm'; 
standard_name = "chlorophyll_a" ;
i_source = '';
i_comment =  "non L2P core field";
l_status = fill_bad_scan_lines_with_missing_value(i_dataset_name,$
                i_num_bad_scan_lines, $
                i_bad_scan_lines_array, $
                r_fill_value, $
                r_dataset_array);

if (debug_mode) then begin
    print, debug_module,'i_filename    : ', i_filename;
    print, debug_module,'i_dataset_name: ', i_dataset_name;
    print, debug_module,'r_data_type   : ', r_data_type;
    print, debug_module,'r_fill_value  : ', r_fill_value;
    print, debug_module,'r_valid_min   : ', r_valid_min;
    print, debug_module,'r_valid_max   : ', r_valid_max;
endif

if (ok_to_write_chlor_a_flag) then begin
    r_status = write_gds2_variable(i_out_filename,$
                                   r_dataset_array,$
                                   i_dataset_name,$
                                   undefined_standard_name,$
                                   i_units,$
                                   r_fill_value,$
                                   r_data_type,$
                                   r_valid_min,$
                                   r_valid_max,$
                                   i_comment,$
                                   i_long_name,$
                                   r_slope,$
                                   r_intercept,$
                                   undefined_source,$
                                   i_coordinates);


    if (TEST_PARAMETER EQ "BAD_CHLOR_A_VARIABLE_WRITE") then begin
        r_status = FAILURE;
    endif

    if (r_status EQ FAILURE) then begin
        msg_type = "warning";
        msg = 'Failed in write_modis_data_variable:' + i_dataset_name + ' to file ' + i_out_filename;
        print, debug_module + msg;
        donotcare = error_log_writer(routine_name,msg);
        donotcare = wrapper_ghrsst_notify_operator($
                        routine_name,$
                        msg_type,$
                        msg,$
                        i_data);

        ; Keep going
     endif
endif

; Be sure to make these variables undefined for next read otherwise you will be having a bad day.

tempvar = SIZE(TEMPORARY(r_fill_value));
tempvar = SIZE(TEMPORARY(r_valid_min));
tempvar = SIZE(TEMPORARY(r_valid_max));

endif else begin
    if (debug_mode) then begin
        print, debug_module + 'Variable ' + i_variable_short_name + ' does not exist in file ' + i_filename;
    endif
;    msg_type = "warning";
;    msg = 'Variable ' + i_variable_short_name + ' does not exist in file ' + i_filename;
;    print, msg;
;    donotcare = wrapper_ghrsst_notify_operator($
;                    routine_name,$
;                    msg_type,$
;                    msg,$
;                    i_data);
endelse
; END_CHECK_CHLOR_A_VARIABLE_EXIST ---------- ---------- ---------- ---------- ---------- ---------- ----------

i_variable_short_name = 'K_490';

variable_exist_flag = is_netcdf_variable_in_file($
                          i_filename,$
                          i_variable_short_name);

; BEGIN_CHECK_K_490_VARIABLE_EXIST ---------- ---------- ---------- ---------- ---------- ---------- ----------
if (variable_exist_flag) then begin

r_status = read_gds1_netcdf_one_variable(i_filename,i_variable_short_name,$
               o_data_variable_structure);

ok_to_write_K_490_flag = 1;

if (TEST_PARAMETER EQ "BAD_K_490_VARIABLE_READ") then begin
    r_status = FAILURE;
endif

if (debug_mode) then begin
    print, debug_module, 'i_filename ', i_filename, ' i_variable_short_name ', i_variable_short_name, ' variable_exist_flag ', variable_exist_flag, ' TEST_PARAMETER ', TEST_PARAMETER, ' r_status ', r_status
endif

; MODIS_L2P_ERROR_STEP 23: If cannot read optional additional day variable 'K_490' from day file, WARN sigevent thrown, keep going 
if (r_status NE SUCCESS) then begin
    msg_type = "warning";
    msg = 'Failed in ' + routine_name + ' to read variable ' + i_variable_short_name + ' in file ' + i_filename;
    print, debug_module + msg;
    donotcare = error_log_writer(routine_name,msg);
    donotcare = wrapper_ghrsst_notify_operator($
                    routine_name,$
                    msg_type,$
                    msg,$
                    i_data);
    ok_to_write_K_490_flag = 0;
    ; Keep going
endif

if (ok_to_write_K_490_flag) then begin
    r_dataset_array =  *(o_data_variable_structure.s_variable_array);
    PTR_FREE, o_data_variable_structure.s_variable_array;
    r_status = find_netcdf_variable_attribute_info('_FillValue',   o_data_variable_structure.s_attributes_array,r_fill_value);
    r_status = find_netcdf_variable_attribute_info('scale_factor', o_data_variable_structure.s_attributes_array,r_slope);
    r_status = find_netcdf_variable_attribute_info('add_offset',   o_data_variable_structure.s_attributes_array,r_intercept);
    r_status = find_netcdf_variable_attribute_info('valid_min',    o_data_variable_structure.s_attributes_array,r_valid_min);
    r_status = find_netcdf_variable_attribute_info('valid_max',    o_data_variable_structure.s_attributes_array,r_valid_max);
    data_type_as_int = SIZE(r_dataset_array,/TYPE);
    r_data_type = convert_int_type_to_char_type(data_type_as_int);
endif

i_dataset_name = 'K_490';
standard_name = 'K_490';
i_units = 'm^-1';

; If the fill value is provided from HDF file, we attempt to use it
if (N_ELEMENTS(r_fill_value)) then begin
    ; Do nothing, the variable r_fill_value is already contained the value we want.
endif else begin
    ; If the fill value is not provided, we use a constant, which is hard-coded.
    r_fill_value = -5000;
endelse

; If the valid_min value is provided from HDF file, we attempt to use it

if (N_ELEMENTS(r_valid_min)) then begin
    ; Do nothing, the variable is already contained the value we want.
endif else begin
    ; If the value is not provided, we use a constant, which is hard-coded.
    r_valid_min = 0;
endelse

; If the valid_max value is provided from HDF file, we attempt to use it

if (N_ELEMENTS(r_valid_max)) then begin
    ; Do nothing, the variable is already contained the value we want.
endif else begin
    ; If the value is not provided, we use a constant, which is hard-coded.
    r_valid_max = 4000;
endelse

if (ok_to_write_K_490_flag) then begin
i_coordinates = "lon lat";
i_long_name =  'Diffuse attenuation coefficient at 490 nm (OBPG)';
i_source = '';
i_comment =  "non L2P core field";
l_status = fill_bad_scan_lines_with_missing_value(i_dataset_name,$
                i_num_bad_scan_lines, $
                i_bad_scan_lines_array, $
                r_fill_value, $
                r_dataset_array);

if (debug_mode) then begin
    print, debug_module,'i_dataset_name: ', i_dataset_name;
    print, debug_module,'r_data_type   : ', r_data_type;
    print, debug_module,'r_fill_value  : ', r_fill_value;
    print, debug_module,'r_valid_min   : ', r_valid_min;
    print, debug_module,'r_valid_max   : ', r_valid_max;
endif
    r_status = write_gds2_variable(i_out_filename,$
                                   r_dataset_array,$
                                   i_dataset_name,$
                                   undefined_standard_name,$
                                   i_units,$
                                   r_fill_value,$
                                   r_data_type,$
                                   r_valid_min,$
                                   r_valid_max,$
                                   i_comment,$
                                   i_long_name,$
                                   r_slope,$
                                   r_intercept,$
                                   undefined_source,$
                                   i_coordinates);

    if (TEST_PARAMETER EQ "BAD_K_490_VARIABLE_WRITE") then begin
        r_status = FAILURE;
    endif

    if (r_status EQ FAILURE) then begin
        msg_type = "warning";
        msg = 'Failed in write_modis_data_variable:' + i_dataset_name + ' to file ' + i_out_filename;
        print, debug_module + msg;
        donotcare = error_log_writer(routine_name,msg);
        donotcare = wrapper_ghrsst_notify_operator($
                        routine_name,$
                        msg_type,$
                        msg,$
                        i_data);

        ; Keep going
     endif
endif; end (ok_to_write_K_490_flag) 
endif else begin; end if (variable_exist_flag) 
    if (debug_mode) then begin
        print, debug_module + 'Variable ' + i_variable_short_name + ' does not exist in file ' + i_filename;
    endif
endelse
; END_CHECK_K_490_VARIABLE_EXIST ---------- ---------- ---------- ---------- ---------- ---------- ----------

; ---------- Close up shop ---------- 

return, r_status
end
