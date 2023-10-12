;  Copyright 2008, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

FUNCTION perform_modis_cleanup_failed_processing,$
             i_error_in_function                ,$
             i_error_reason                     ,$
             i_data_filename                    ,$
             i_processing_type                  ,$
             i_out_filename                     ,$
             i_L2P_registry

; Function perform a general clean up of a failed MODIS processing job.
;
; It will:
;
;   1.  Remove the staged dataset.
;   2.  Remove the current job entry.
;   3.  Logs the error.
;   4.  Append an entry into the processed file registry.
;
; Assumptions:
;
;   1. TBD 
;
;------------------------------------------------------------------------------------------------

; Load constants.  No ending semicolon is required.

@modis_data_config.cfg

over_all_status = SUCCESS;

; Remove staged data file and current job.

l_erase_status = erase_one_staged_dataset($
                     i_data_filename, $
                     i_processing_type, $
                     i_out_filename);
 
l_remove_status = erase_current_job(GETENV('MODIS_CURRENT_JOBS_DIR'), $
                      FILE_BASENAME(i_out_filename) + ".bz2");

l_status = error_log_writer(i_error_in_function,i_error_reason,/DO_NOT_PRINT);

; Get the L2P core filename only without the directory.

l_l2p_core_name_only = FILE_BASENAME(i_out_filename) + ".bz2";
l_append_status = append_to_L2P_processed_file_registry($
                      i_L2P_registry,l_l2p_core_name_only); 

; ---------- Close up shop ----------

return, over_all_status
end
