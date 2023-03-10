;  Copyright 2010, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

;
; Function email an operator of error.  The message is an array of string.
;
;------------------------------------------------------------------------------------------------

FUNCTION  idl_email_ops_to_report_error, $
              i_error_message
    
    ; Define active routine
    routine_name = "idl_email_ops_to_report_error"
    
    ; Log error message based on dimensions of input
    IF (SIZE(i_error_message, /DIMENSIONS) EQ 1) THEN BEGIN
        email_error = i_error_message
        log_error = i_error_message
    ENDIF ELSE BEGIN
        email_error = STRJOIN(i_error_message, " ")
        log_error = i_error_message[4] + ": " + i_error_message[7]
    ENDELSE

    print, "Email error: " + email_error
    print, "Log error: " + log_error
    donotcare = error_log_writer(routine_name,log_error);

    ; Email error message
    msg_type = "error"
    i_data = ""
    donotcare = wrapper_ghrsst_notify_operator($
                    routine_name,$
                    msg_type,$
                    email_error,$
                    i_data)

    ; Close up shop.
    return, 1;
END
