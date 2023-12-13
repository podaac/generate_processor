;  Copyright 2008, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$

; Function to write an error to log file.

FUNCTION error_log_writer,$
         i_calle_name,$
         i_error_reason,$
         DO_NOT_PRINT = FALSE

; Print the error

if keyword_set(FALSE) then begin
     print, i_calle_name + " - INFO: " + i_error_reason
endif else begin
    print, i_calle_name + " - ERROR: " + i_error_reason
endelse

; Set the fields.

l_job_id         = LONG(SYSTIME(/SECONDS));
l_date_processed = SYSTIME();

;
; Create the object reference to ghrsst_error_logger
;

l_status = create_error_logger($
               l_job_id, $                          
               l_date_processed, $                  
               i_calle_name, $
               i_error_reason, $
               lr_logger_ref);

;
; Print the error entry to log file.
;

lr_logger_ref->write_to_log_file;

;
; Destroy the object
;

OBJ_DESTROY, lr_logger_ref;

;print, 'after OBJ_DESTROY';
;help,/heap

RETURN, l_status
END
