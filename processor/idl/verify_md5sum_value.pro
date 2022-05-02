;  Copyright 2007, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: verify_md5sum_value.pro,v 1.1 2007/07/06 17:08:10 qchau Exp $

FUNCTION verify_md5sum_value, i_md5sum_files_directory, i_md5sum_filename

; Fuction perform an "md5sum --check" command on a given md5sum file.
;
; A typicaly md5sum file contains the 32 character value, separated by 2 spaces and then the
; file name.
;
; An example:
;
;  f2c64d4955c2f14b87aab463cf05f8e2  FR-20070616-MODIS_A-JPL-L2P-A2007167235500.L2_LAC_GHRSST-v01.xml
;

; Output/return status.  1 means the md5sum matches.
;

o_status = 1;

;
; Save the current directory.
;

spawn, 'pwd', pwd_output;
current_directory = pwd_output[0]

;help, current_directory

;
; Cd to the directory, perform the md5sum check on the file.
; Look for the phrase OK and change back to current directory.  If the phrase exist then
; the checksum matches.
;

md5sum_command = "cd " + i_md5sum_files_directory + "; md5sum -c " + i_md5sum_filename + " | awk '{print $2}'" + "; cd " + current_directory;

spawn, md5sum_command, run_result, run_error

;help, run_result
;help, STRLEN(run_result[0]);
;print, 'run_result = [',run_result,']'
;help, run_error
;help, STRLEN(run_error)

;print, '----------------------------------------------------------------------'
;print, 'verify_md5sum_value: i_md5sum_files_directory = [',i_md5sum_files_directory,']'
;print, 'verify_md5sum_value: i_md5sum_filename = [',i_md5sum_filename,']'
;print, 'verify_md5sum_value: run_result = [',run_result,']'
if (run_result EQ "OK") then begin
;    print, 'md5sum matches'
endif else begin
;    print, 'md5sum differ'
    o_status = 0;
endelse

return, o_status;
end

