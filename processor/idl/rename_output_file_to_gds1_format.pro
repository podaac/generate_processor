;  Copyright 2014, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

FUNCTION rename_output_file_to_gds1_format,$
    i_day_or_night             ,$
    i_out_filename             ,$ 
    i_meta_filename            ,$ 
    o_out_filename             ,$
    o_meta_filename

; Function rename an output file and a meta file name to GDS1 format.
; Function also rename the files on file system to their new names.
;
; Assumptions:
;
;   1. TBD 
;
;------------------------------------------------------------------------------------------------

; Load constants.  No ending semicolon is required.

@modis_data_config.cfg

over_all_status = SUCCESS;

o_meta_filename = "";
o_out_filename = "";

old_out_filename = i_out_filename; 
name_only      = FILE_BASENAME(i_out_filename);
directory_name = FILE_DIRNAME(i_out_filename); 
name_tokens = STRSPLIT(name_only,".",/EXTRACT); 

if (i_day_or_night EQ 'Day') then begin
    ; The token we are interest in is L2_LAC_GHRSST_N
    o_out_filename = directory_name + "/" + name_tokens[0] + ".L2_LAC_GHRSST_D-v01.nc"; 
    if (old_out_filename NE o_out_filename) then begin
        FILE_MOVE, old_out_filename, o_out_filename, /OVERWRITE; 
    endif
    ; Save the new name back to our i_out_filename variable.
    i_out_filename = o_out_filename;

   ; Save the metadata file too.
    meta_directory_name = FILE_DIRNAME(i_meta_filename);
    meta_name_only = FILE_BASENAME(i_meta_filename);
    name_tokens = STRSPLIT(meta_name_only,".",/EXTRACT); 
    ; The token we are interested in is L2_LAC_GHRSST_N
    o_meta_filename = directory_name + "/" + name_tokens[0] + ".L2_LAC_GHRSST_D-v01.xml"
endif

if (i_day_or_night EQ 'Night' || i_day_or_night EQ 'Mixed') then begin
    ; The token we are interested in is L2_LAC_GHRSST_N
    o_out_filename = directory_name + "/" + name_tokens[0] + ".L2_LAC_GHRSST_N-v01.nc"; 
    if (old_out_filename NE o_out_filename) then begin
        FILE_MOVE, old_out_filename, o_out_filename, /OVERWRITE; 
    endif
    ; Save the new name back to our i_out_filename variable.
    i_out_filename = o_out_filename;

   ; Save the metadata file too.
    meta_directory_name = FILE_DIRNAME(i_meta_filename);
    meta_name_only = FILE_BASENAME(i_meta_filename);
    name_tokens = STRSPLIT(meta_name_only,".",/EXTRACT); 
    ; The token we are interest in is L2_LAC_GHRSST_N
    o_meta_filename = directory_name + "/" + name_tokens[0] + ".L2_LAC_GHRSST_N-v01.xml"; 
endif

; ---------- Close up shop ----------

return, over_all_status
end
