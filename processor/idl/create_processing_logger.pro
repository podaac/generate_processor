;  Copyright 2007, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: create_processing_logger.pro,v 1.1 2007/12/14 16:24:15 qchau Exp $

; Function create a ghrsst_processing_logger object reference and returns back the reference. 
;
; Basically, it is a wrapper to the OBJ_NEW calls.
;

FUNCTION create_processing_logger,$
             i_job_id,$
             i_date_processed,$
             i_data_filename,$
             i_processing_reason,$
             r_logger_ref

;print, 'entering create_processing_logger';

;
; Define an empty structure.
;

my_struct = ghrsst_processing_logger__DEFINE();

;
; Create the class, calling the INIT function.
;

r_logger_ref = OBJ_NEW('ghrsst_processing_logger',$
                                            i_job_id, $                          
                                            i_date_processed, $                  
                                            i_data_filename, $
                                            i_processing_reason);

;print, 'leaving create_processing_logger';

; Will always return 1 for now
return, 1

END

