;  Copyright 2016, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION perform_spline_fit_on_controlled_points_with_improvements, $
             i_num_bad_scan_lines, $
             i_scan_line_flag_array, $
             i_bad_longtitude_fill_value, $
             i_bad_latitude_fill_value, $
             i_num_nj_values, $
             i_num_ni_values, $
             i_longitude_subintervals, $
             i_latitude_subintervals, $
             i_controlled_point_cols, $
             i_filename, $
             i_out_filename, $
             r_longitude_array, $
             r_latitude_array

; Function performs the spline fit funtions in the longitude direction of the l_longitude_array and
; i_latitude_array using the i_controlled_point_cols, the i_latitude_subintervals and
; i_longitude_subintervals arrays.
;
; Assumptions:
;
;   1. TBD
;

;------------------------------------------------------------------------------------------------

; Load constants.

@modis_data_config.cfg

; Define local variables.

r_status = SUCCESS;

debug_module = "perform_spline_fit_on_controlled_points_with_improvements:";
debug_mode = 0;

;
; Create a catch block to catch error in processing the spline() function.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'perform_spline_fit_on_controlled_points_with_improvements: FATAL, fatal error in processing input  file: ', $
        i_filename
    print, 'perform_spline_fit_on_controlled_points_with_improvements: FATAL, fatal error in processing output file: ', $
        i_out_filename
    print, 'GHRSST_PROCESSING_ERROR ', i_filename, ' Spline function causes division by zero';
    r_status = FAILURE;

    ; Remove in-complete NetCDF file.
    l_do_not_care = clean_up_modis_processing(i_out_filename);

    ; Must return immediately.
    return, r_status
endif

;
; Note:
;
; i_num_nj_values is the same as number of pixel per scan line  nj, latitude size    2030
; i_num_ni_values is the same as number of scan lines           ni, longitude size   1354
;
; From NetCDF file, the dimensions are:
;
;dimensions:
;        time = 1 ;
;        nj = 2030 ;
;        ni = 1354 ;
;variables:
;        float lat(nj, ni) ;
;        float lon(nj, ni) ;
;        short sea_surface_temperature(time, nj, ni) ;
;

;print, 'perform_spline_fit_on_controlled_points_with_improvements: i_num_ni_values = ',i_num_nj_values;
;print, 'perform_spline_fit_on_controlled_points_with_improvements: i_num_nj_values = ',i_num_ni_values;
;help, i_longitude_subintervals;
;help, i_latitude_subintervals;
;help, i_controlled_point_cols;
;print, 'perform_spline_fit_on_controlled_points_with_improvements: i_longitude_subintervals = ',i_longitude_subintervals;
;print, 'perform_spline_fit_on_controlled_points_with_improvements: i_latitude_subintervals  = ',i_latitude_subintervals;
;exit;

; If the size of i_controlled_point_cols is the same as i_num_ni_values, we don't need to do spline fit, just do a simple assignment.
; If it is 170, we proceed as normal.
if (N_ELEMENTS(i_controlled_point_cols) EQ i_num_ni_values) then begin
    r_longitude_array = i_longitude_subintervals;
    r_latitude_array  = i_latitude_subintervals;
    return, r_status;
endif


r_longitude_array = FLTARR(i_num_ni_values, i_num_nj_values);     1354 by 2030
r_latitude_array  = FLTARR(i_num_ni_values, i_num_nj_values);     1354 by 2030

;
; Create a catch block to catch error in processing the spline() function.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'perform_spline_fit_on_controlled_points_with_improvements: ERROR, fatal error in processing input  file: ', $
    i_filename
    print, 'perform_spline_fit_on_controlled_points_with_improvements: ERROR, fatal error in processing output file: ', $
    i_out_filename
    r_status = FAILURE;
    
    ; Remove in-complete NetCDF file.
    l_do_not_care = clean_up_modis_processing(i_out_filename);
    
    ; Must return immediately.
    return, r_status
endif

if (debug_mode) then begin
    print, debug_module, "i_num_bad_scan_lines ",i_num_bad_scan_lines;
    print, debug_module, "SIZE(i_controlled_point_cols,/N_ELEMENTS) ",SIZE(i_controlled_point_cols,/N_ELEMENTS);
    print, debug_module, "i_num_nj_values         ",i_num_nj_values;
    print, debug_module, "i_num_ni_values         ",i_num_ni_values;
    print, debug_module, "SIZE(i_longitude_subintervals,/N_ELEMENTS)",SIZE(i_longitude_subintervals,/N_ELEMENTS);
    print, debug_module, "SIZE(i_latitude_subintervals,/N_ELEMENTS) ",SIZE(i_latitude_subintervals,/N_ELEMENTS);
endif

;
; Only perform spline function on good scan lines.
;
if (i_num_bad_scan_lines GT 0) then begin
    ;
    ; For bad scan lines:
    ;
    ; i_num_ni_values should be 1354
    ; i_num_nj_values should be 2030
  
;    help, i_num_ni_values
;    help, i_num_nj_values
;    help, i_longitude_subintervals;
;    help, i_latitude_subintervals;
;    help, r_longitude_array;
;    help, r_latitude_array;
;    help, i_scan_line_flag_array;
;    help, i_bad_longtitude_fill_value;
;    help, i_bad_latitude_fill_value;

    l_pix = LINDGEN(i_num_ni_values) + 1;
    for nj_index = 0, (i_num_nj_values - 1) do begin
        ;
        ; Only perform the spline fit on the good scan line.
        ; A value of 0 means the scan line is bad and 1 means good.
        ;
        if (i_scan_line_flag_array[nj_index] EQ 0) then begin
            r_longitude_array(*,nj_index) = i_bad_longtitude_fill_value;
            r_latitude_array(*,nj_index)  = i_bad_latitude_fill_value;
        endif else begin
            r_longitude_array(*,nj_index) = spline(i_controlled_point_cols, $
                                                   i_longitude_subintervals(*,nj_index),l_pix);
            r_latitude_array(*,nj_index)  = spline(i_controlled_point_cols, $
                                                   i_latitude_subintervals(*,nj_index),l_pix);
        endelse
    endfor
    CATCH, /CANCEL

endif else begin

    l_pix = LINDGEN(i_num_ni_values) + 1;
    for nj_index = 0, (i_num_nj_values - 1) do begin
        r_longitude_array(*,nj_index) = spline(i_controlled_point_cols, $
                                               i_longitude_subintervals(*,nj_index),l_pix);
        r_latitude_array(*,nj_index)  = spline(i_controlled_point_cols, $
                                               i_latitude_subintervals(*,nj_index),l_pix);
    endfor
    CATCH, /CANCEL

endelse

;
; IDL does not throw an exception when divide by zero or float underflow/overflow so we
; must catch the error by using the CHECK_MATH() function.  Obviously, if such an error
; occurred, there's no need to continue processing this input file.
;
; We either abandon ship, remove the partial completed output file or keeping going by
; doing some additional processing.  As of now, we abandon ship.
;

if (CHECK_MATH() NE 0) then begin
    CATCH, /CANCEL
    print, 'perform_spline_fit_on_controlled_points_with_improvements: FATAL, Math error occurred in critical section in processing input file: ', $
    i_filename
    print, 'perform_spline_fit_on_controlled_points_with_improvements: output file: ', i_out_filename
    print, 'perform_spline_fit_on_controlled_points_with_improvements: Cannot continue processing.';
    print, 'GHRSST_PROCESSING_ERROR ', i_filename, ' Math error occurred in critical section';
    r_status = FAILURE;

    ; Remove in-complete NetCDF file.
    l_do_not_care = clean_up_modis_processing(i_out_filename);

    ; Must return immediately.
    return, r_status
endif

; ---------- Close up shop ---------- 

return, r_status
end
