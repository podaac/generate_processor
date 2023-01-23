;  Copyright 2008, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

; Function verify if an IDL worker has been successfully started.
;

FUNCTION verify_taskdl_worker_started, $
             i_port_number, $
             i_worker_name

; Load constants.  No ending semicolon is required.

@modis_data_config.cfg

; Returned status.  Value of 0 means ok, 1 means bad.

o_status = SUCCESS;

; Get the user account:

SPAWN, "whoami", user_account;
;help, user_account
;print, user_account

str_process_check_command = "ps -ef | grep " + STRING(i_port_number) + " | grep ssh | grep taskdl | grep " + user_account + $
                            " | grep " + i_worker_name + " | wc -l "
print, str_process_check_command;
SPAWN, str_process_check_command, number_process_found; 

;help, number_process_found;
;print, "number_process_found = ", number_process_found;

; If '0' was returned, the worker failed to start.
; Note: variable number_process_found is of type string.

if (number_process_found EQ '0') then begin
    print, "verify_taskdl_worker_started: IDL worker failed to start with port number: " + STRING(i_port_number) $
                                                             + " " + i_worker_name;
    o_status = FAILURE;
endif

return, o_status;
END