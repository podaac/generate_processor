;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
;  $Id$

FUNCTION convert_to_negative_180_positive_180_fast,$
             i_controlled_point_lats,$
             i_controlled_point_lons,$
             i_scan_line_flag_array, $
             r_longitude_array,$
             r_num_longitudes_added,$
             r_num_longitudes_subtracted

; Function convert longitude array back to [-180,180] convention.
;
;------------------------------------------------------------------------------------------------

; Load constants.

@modis_data_config.cfg

; Define local variables.

status = SUCCESS;

;
; Change to [-180,180] convention.
;

r_num_longitudes_subtracted = 0L;
r_num_longitudes_added      = 0L;

good_indices_array = WHERE(i_scan_line_flag_array EQ 1, num_good_indices);

for lat_index = 0, i_controlled_point_lats - 1 do begin
    array_to_check = REFORM(r_longitude_array[lat_index,*],N_ELEMENTS(r_longitude_array[lat_index,*]));

    less_than_minus_180_array = WHERE((array_to_check LT -180.0 AND (i_scan_line_flag_array EQ 1)),num_less_than_minus_180);
    greater_than_180_array    = WHERE(((array_to_check GT 180)  AND (i_scan_line_flag_array EQ 1)),num_greater_than_180);

    if (num_less_than_minus_180 GT 0) then begin
        r_longitude_array[lat_index,less_than_minus_180_array] += 360.0;
        r_num_longitudes_added = r_num_longitudes_added + num_less_than_minus_180;
    endif
    if (num_greater_than_180 GT 0) then begin
        r_longitude_array[lat_index,greater_than_180_array] -= 360.0; 
        r_num_longitudes_subtracted = r_num_longitudes_added + num_greater_than_180;
    endif
endfor

; ---------- Close up shop ----------

return, status
end
