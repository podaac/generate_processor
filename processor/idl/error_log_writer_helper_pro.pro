;  Copyright 2008, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$

; This program allows a Perl script to report an error to the GHRSST Error Archive Log (GELA).
;
; Assumption(s):
;   1.  (TBD)
;

PRO error_log_writer_helper_pro,$
        i_calle_name,$
        i_error_reason

;print, 'Entering error_log_writer_helper_pro';

i_calle_name   = '';
i_error_reason = ''; 

args = COMMAND_LINE_ARGS(COUNT = argCount);

;print, argCount;

IF argCount EQ 0 THEN BEGIN
    PRINT, 'error_log_writer_helper_pro:No input arguments specified'
    RETURN
ENDIF ELSE BEGIN
    i_calle_name   = args[0];
    i_error_reason = args[1];
ENDELSE

;print, "[",i_calle_name,"]";
;print, "[",i_error_reason,"]";

l_status = error_log_writer($
         i_calle_name,$
         i_error_reason);

;print, 'Leaving error_log_writer_helper_pro';
END

