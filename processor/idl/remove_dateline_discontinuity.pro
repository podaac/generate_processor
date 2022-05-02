;  Copyright 2006, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
;  $Id: remove_dateline_discontinuity.pro,v 1.4 2006/10/12 00:53:38 qchau Exp $
;  DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
;  New Request #xxxx

FUNCTION remove_dateline_discontinuity,$
             i_controlled_point_lats,$
             i_controlled_point_lons,$
             i_scan_line_flag_array, $
             ir_longitude_control_points,$
             r_dateline_crossed,$
             r_num_longitudes_added,$
             r_num_longitudes_subtracted

; Function perform a tweak of longitude that crosses the dateline.
;
; Assumptions:
;
;   1. TBD.
;   2. TBD.
;   3. TBD.
;   4. TBD.
;   5. TBD.
;   6. TBD.
;

;------------------------------------------------------------------------------------------------

; Load constants.

@modis_data_config.cfg

; Define local variables.

status = SUCCESS;

;
; Remove any dateline discontinuity in the longitudes.
;

r_dateline_crossed     = 0;
r_num_longitudes_added = 0L;
r_num_longitudes_subtracted = 0L;

;print, 'remove_dateline_discontinuity: i_controlled_point_lats = ', i_controlled_point_lats;
;print, 'remove_dateline_discontinuity: i_controlled_point_lons = ', i_controlled_point_lons;
;help, ir_longitude_control_points;

; The two values should be:

; i_controlled_point_lats = 170;
; i_controlled_point_lons = 2030;

;
; Start the loop at 1 since we need two points to subtract.
;
for lat_index = 1, i_controlled_point_lats - 1 do begin
    for lon_index = 0, i_controlled_point_lons - 1 do begin
        ;
        ; Only tweak the longitude on the good scan lines.  Good scan lines has a value of 1 in the
        ; array i_scan_line_flag_array.
        ;
        if (i_scan_line_flag_array[lon_index] EQ 1) then begin

            delta = ir_longitude_control_points[lat_index,lon_index] - $
                    ir_longitude_control_points[lat_index-1,lon_index];

            ;
            ; Going west add 360.
            ;

            if (delta LT - 180) then begin
                ir_longitude_control_points[lat_index,lon_index] += 360;
                r_num_longitudes_added++; 
            endif else begin

                ;
                ; Going east subtract 360.
                ;

               if (delta GT 180) then begin 
                   ir_longitude_control_points[lat_index,lon_index] -= 360;
                   r_num_longitudes_subtracted++;
               endif
            endelse
        endif


;        if (i_scan_line_flag_array[lon_index] EQ 0) then begin
;print, 'remove_dateline_discontinuity: skipping [', lat_index, '] [', lon_index, ']';
;        endif
   
    endfor 
endfor

;print, 'remove_dateline_discontinuity: i_controlled_point_lats = ', i_controlled_point_lats;
;print, 'remove_dateline_discontinuity: i_controlled_point_lons = ', i_controlled_point_lons;

;if (r_num_longitudes_added GT 0) then begin 
;    print, 'remove_dateline_discontinuity: r_num_longitudes_added = ', r_num_longitudes_added;
;endif

;if (r_num_longitudes_subtracted GT 0) then begin
;    print, 'remove_dateline_discontinuity: r_num_longitudes_subtracted = ', r_num_longitudes_subtracted;
;endif

if (r_num_longitudes_added GT 0 || r_num_longitudes_subtracted GT 0) then begin
    r_dateline_crossed = 1;
endif

; ---------- Close up shop ----------

return, status
end
