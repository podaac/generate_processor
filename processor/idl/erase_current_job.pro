;  Copyright 2007, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: erase_current_job.pro,v 1.1 2007/08/08 15:04:11 qchau Exp $
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

; Function remove the current job by perform a removal on the name (without a directory).
;
; The presence of this file was put there by register_current_job() to  signify for others processes
; to skip this file.  When the file is done processing, this file is now removed.
;
; These functions allow the scripts to process the MODIS L2P files to be run in succession
; even though the previous IDL jobs doing the processing is not done yet.
;
FUNCTION erase_current_job, $
             i_directory_name, $
             i_l2p_core_filename

; Load constants.  No ending semicolon is required.

@modis_data_config.cfg

; Returned status.  Value of 0 means ok, 1 means bad.

o_status = SUCCESS;

; Make sure the file name is not one of those not allowed.

if ((i_l2p_core_filename EQ '' OR i_l2p_core_filename EQ '/') OR $
    (i_l2p_core_filename EQ '/*' OR i_l2p_core_filename EQ '/*.*'))  then begin
  print, 'erase_current_job: ERROR, i_l2p_core_filename [' + i_l2p_core_filename + '] is not allowed';
  o_status = FAILURE;
  RETURN, o_status;
endif

; Make sure the directory name is not one of those not allowed.

if ((i_directory_name EQ '' OR i_directory_name EQ '/') OR $
    (i_directory_name EQ '/*' OR i_directory_name EQ '/*.*')) then begin
  print, 'erase_current_job: ERROR, i_directory_name [' + i_directory_name + '] is not allowed';
  o_status = FAILURE;
  RETURN, o_status;
endif

; The name is OK, remove the empty file.

last_slash_pos = STRPOS(i_l2p_core_filename,"/",/REVERSE_SEARCH);
l_l2p_core_name_only = STRMID(i_l2p_core_filename,last_slash_pos + 1);

; Depends on if the format of the MODIS L2P is in GDS1 format (original format)
; or GDS2, we will create a different file.

; Look at the file name to determine if the file is a Day or Night.
; This file name
;
;     20070301-MODIS_A-JPL-L2P-A2007060000500.L2_LAC_GHRSST_N-v01.nc.bz2
;
; will produce the GDS2 file name
;
;      20070301000500-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc
;

job_name = l_l2p_core_name_only;

if (STRUPCASE(GETENV('CREATE_MODIS_L2P_IN_GDS2_FORMAT')) EQ 'TRUE') then begin
    i_day_or_night = 'Day';
    night_string_pos = STRPOS(l_l2p_core_name_only,'L2_LAC_GHRSST_N');

    if (night_string_pos GE 0) then begin
        i_day_or_night = 'Night';
    endif

    donotcare = rename_output_file_to_gds2_format_without_file_move($
                    i_day_or_night,$
                    l_l2p_core_name_only,$
                    o_gds2_filename);

    ; Set the job_name to the new GDS2

    job_name = o_gds2_filename;
endif

; Only rename the job if the name was successfully retrieved above otherwise we will be trying to remove a directory.

if (job_name NE '') then begin
    external_command_string = '/bin/rm -f ' + i_directory_name + '/' + job_name;
    SPAWN, external_command_string 
endif

RETURN, o_status;
END
