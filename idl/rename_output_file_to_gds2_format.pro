;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

FUNCTION rename_output_file_to_gds2_format,$
             i_day_or_night,$
             i_out_filename,$ 
             o_out_filename

; Function rename an output file to GDS2 format.
; Function also rename the file on file system to its new name.
;
; This output file
;
;      20121025-MODIS_A-JPL-L2P-A2012298001000.nc
;
; will be converted to
;
;      20121025-JPL-L2P_GHRSST-SSTskin-MODIS_A-v02.0-fv01.0.nc
;
; Assumptions:
;
;   1. TBD 
;
;------------------------------------------------------------------------------------------------

; Load constants.  No ending semicolon is required.

@modis_data_config.cfg

routine_name = 'rename_output_file_to_gds2_format.pro';
debug_module = 'rename_output_file_to_gds2_format.pro';
debug_flag = 0;
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_flag = 1;
endif

o_status = SUCCESS;

o_meta_filename = "";
o_out_filename = "";

old_out_filename = i_out_filename;  Save the name so we can use it to rename the file on the file system.
name_only      = FILE_BASENAME(i_out_filename);
directory_name = FILE_DIRNAME(i_out_filename); 
dot_name_tokens  = STRSPLIT(name_only,".",/EXTRACT); 

; Split the token using '-' to break down: 20121025-MODIS_A-JPL-L2P-A2012298001000.nc
dash_name_tokens = STRSPLIT(dot_name_tokens[0],"-",/EXTRACT);

if (SIZE(dash_name_tokens,/N_ELEMENTS) NE 5) then begin
    print, debug_module + ' - ERROR: Expecting exactly 5 tokens, received ' + STRING(SIZE(dash_name_tokens,/N_ELEMENTS)) + ' tokens from ' + i_out_filename;
    o_status = FAILURE;
    return, o_status;
endif

; Get the time portion from the 5th token.
; dash_name_tokens[4] = "A2012298001000";
;                        01234567890123

time_portion = STRMID(dash_name_tokens[4],8);

; This is a bad output name: 201910277T145000-JPL-L2P_GHRSST-SSTskin-MODIS_A-D-v02.0-fv01.0.nc
; If the time portion is too long, we shrink it down to 6 after the T.
nominal_time_length = 6;   001000
;print, debug_module + 'time_portion ', time_portion
;print, debug_module + 'STRLEN(time_portion) ', STRLEN(time_portion)
IF STRLEN(time_portion) GT nominal_time_length THEN BEGIN
    print, debug_module + ' - WARN: Original time_portion ' + time_portion
    ; Look for the T and extract after as in T001000.
    letter_T_pos = STRPOS(time_portion,'T');
    if (letter_T_pos GE 0) then begin
        ;print, debug_module + 'WARN: letter_T_pos ', letter_T_pos
        time_portion = STRMID(time_portion,letter_T_pos+1,6);
        ;print, debug_module + 'WARN: Shrink time_portion to shorter string ' + time_portion
    endif else begin
        time_portion = STRMID(time_portion,0,6);
    endelse
ENDIF

; If dash_name_tokens[0] is too long, we shrink it down.
nominal_name_length = 8;
if STRLEN(dash_name_tokens[0]) GT 8 then begin
    dash_name_tokens[0] = STRMID(dash_name_tokens[0],0,8);
    ;print, debug_module + 'WARN: Shrink dash_name_tokens[0] to ' + dash_name_tokens[0] 
endif

; Rename the 'Day' output file to the GDS2 format.

if (i_day_or_night EQ 'Day') then begin

    ; dash_name_tokens[0] = "20121025"
    ; dash_name_tokens[1] = "MODIS_A"
    ; dash_name_tokens[2] = "JPL"
    ; dash_name_tokens[3] = "L2P" 
    ; dash_name_tokens[4] = "A2012298001000";

    ; to form 20121025001000-JPL-L2P_GHRSST-SSTskin-MODIS_A-D-v02.0-fv01.0.nc

    ;                                         20121025               001000       -             JPL           -             L2P           _     GHRSST-SSTskin     -        MODIS_A            -     D     -     v02.0     -     fv01.0     .nc
    o_out_filename = directory_name + "/" + dash_name_tokens[0] + time_portion + "-" + dash_name_tokens[2] + "-" + dash_name_tokens[3] + "_" + "GHRSST-SSTskin" + "-" + dash_name_tokens[1] + "-" + "D" + "-" + "v02.0" + "-" + "fv01.0" + ".nc";

    ; If the name contains VIIRS-, we make a slight tweak to the name of the output file from 20160901000000-JPL-L2P_GHRSST-SSTskin-VIIRS-N-v02.0-fv01.0.nc to 
    ;                                                            20160901000000-JPL-L2P_GHRSST-SSTskin-VIIRS_NPP-N-v02.0-fv01.0.nc
    ; to more accurately describe the sensor name.
    ; So we replace  VIIRS- with  VIIRS_NPP- in the o_out_filename variable.

    if (STRMATCH(o_out_filename,'*VIIRS-*') EQ 1) then begin
        o_out_filename = STRJOIN(STRSPLIT(o_out_filename, "VIIRS-", /REGEX, /EXTRACT, /PRESERVE_NULL), "VIIRS_NPP-");
    endif

    ; Rename the file on the file system only if the names are different.
    if (old_out_filename NE o_out_filename) then begin
        FILE_MOVE, old_out_filename, o_out_filename, /OVERWRITE; 
    endif

    ; Save the new name back to our i_out_filename variable.
    i_out_filename = o_out_filename;

endif

; Rename the 'Night' or 'Mixed' output file to the GDS2 format.

if (i_day_or_night EQ 'Night' || i_day_or_night EQ 'Mixed') then begin

    ; dash_name_tokens[0] = "20121025"
    ; dash_name_tokens[1] = "MODIS_A"
    ; dash_name_tokens[2] = "JPL"
    ; dash_name_tokens[3] = "L2P" 
    ; dash_name_tokens[4] = "A2012298001000";

    ; to form 20121025001000-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc


    ;                                        20121025               001000       -             JPL           -             L2P           _     GHRSST-SSTskin     -        MODIS_A            -     N     -     v02.0     -     fv01.0     .nc
    o_out_filename = directory_name + "/" + dash_name_tokens[0] + time_portion + "-" + dash_name_tokens[2] + "-" + dash_name_tokens[3] + "_" + "GHRSST-SSTskin" + "-" + dash_name_tokens[1] + "-" + "N" + "-" + "v02.0" + "-" + "fv01.0" + ".nc";

    ; If the name contains VIIRS-, we make a slight tweak to the name of the output file from 20160901000000-JPL-L2P_GHRSST-SSTskin-VIIRS-N-v02.0-fv01.0.nc to 
    ;                                                            20160901000000-JPL-L2P_GHRSST-SSTskin-VIIRS_NPP-N-v02.0-fv01.0.nc
    ; to more accurately describe the sensor name.
    ; So we replace  VIIRS- with  VIIRS_NPP- in the o_out_filename variable.

    if (STRMATCH(o_out_filename,'*VIIRS-*') EQ 1) then begin
        o_out_filename = STRJOIN(STRSPLIT(o_out_filename, "VIIRS-", /REGEX, /EXTRACT, /PRESERVE_NULL), "VIIRS_NPP-");
    endif

    ; Rename the file on the file system only if the names are different.
    if (old_out_filename NE o_out_filename) then begin
        FILE_MOVE, old_out_filename, o_out_filename, /OVERWRITE; 
    endif

    ; Save the new name back to our i_out_filename variable.
    i_out_filename = o_out_filename;
endif

if (debug_flag) then begin
    print, routine_name + 'i_day_or_night                      = ' + i_day_or_night;
    print, routine_name + 'i_out_filename                      = ' + i_out_filename;
    print, routine_name + 'directory_name                      = ' + directory_name;
    print, routine_name + 'name_only                           = ' + name_only;
    print, routine_name + ' dot_name_tokens[0]                 = ' + dot_name_tokens[0];
    print, routine_name + ' SIZE(dash_name_tokens,/N_ELEMENTS) = ', SIZE(dash_name_tokens,/N_ELEMENTS); 
endif
; ---------- Close up shop ----------

return, o_status
end
