;  Copyright 2007, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: build_modis_processing_jobs.pro,v 1.2 2007/08/08 15:04:11 qchau Exp $
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

PRO build_modis_processing_jobs,$
    i_datasets_list,            $
    i_datatype,                 $
    i_convert_to_kelvin,        $ 
    i_L2P_registry,             $
    i_compress_flag,            $
    i_processing_type,          $
    r_processing_jobs_array,    $
    r_current_jobs_array

; Program build the processing jobs as strings to be submitted to the farm for processing.

;
; Assumptions:
;
;   1. TBD 
;
;------------------------------------------------------------------------------------------------

; Load constants.  No ending semicolon is required.

@data_const_config.cfg

NUM_FILES_TO_PROCESS_TEST_ONLY = 30000L; Change this to whatever number of files to process for now.

args = COMMAND_LINE_ARGS(COUNT = argCount);

IF argCount EQ 0 THEN BEGIN
    ;PRINT, 'build_modis_processing_jobs:No input arguments specified'
    ;RETURN
ENDIF ELSE BEGIN
    i_datasets_list     = args[0];
    i_datatype          = args[1];
    i_convert_to_kelvin = args[2];
    i_L2P_registry      = args[3];
    i_compress_flag     = args[4];
ENDELSE

;
; Open and read the dataset list.
;

openr, file_unit, i_datasets_list, ERROR = err, /GET_LUN;

;
; If err is nonzero, something bad happened.  Print the error message
; to the standard error file (logical unit -2):

; Note: Changed later to print to log if desire.

if (err NE 0) then begin
    print, 'build_modis_processing_jobs: ERROR, Cannot open file for input.'
    print, i_datasets_list 
    over_all_status = FAILURE;
    return
end

;
; Loop through the entire file and process each file.
;

l_file_content_as_one_large_string = '';
lines_read                         = 0L;
LINE_DIVIDER = 'SPLIT_THIS';  Use this to distringuish between each lines.
a_line = ''; Must let IDL know that this is a string so it knows how to read in the readf().

while (lines_read lt NUM_FILES_TO_PROCESS_TEST_ONLY && ~eof(file_unit)) do begin
    ;
    ; Get one file name.  Assumes one file name and a few other attributes per line.
    ; No error handling.
    ;

    readf, file_unit, FORMAT='(A)', a_line;

    ; Concatenate this line to the big ole string preceed by a carriage return.

    l_file_content_as_one_large_string += STRING(13B) + a_line;

    ;
    ;  Keep track of how many lines read.
    ;

    lines_read = lines_read + 1; 
endwhile    ; while ~eof(file_unit) do 

;
; Split the file content into many strings using the carriage return as split token.
;

l_file_content_as_many_strings = STRSPLIT(l_file_content_as_one_large_string,STRING(13B),/EXTRACT);

; We now know how many lines read, we can allocate the string array.

data_filename            = '';
start_time_array_element = '';
out_filename             = ''; 
meta_filename            = ''; 
idl_command_string       = '';
num_jobs_built           = 0L;

r_processing_jobs_array = STRARR(lines_read);  Use the number of lines read to allocate.
r_current_jobs_array    = STRARR(lines_read);

while (num_jobs_built LT lines_read) do begin

    ; Parse the line for the fields separated by commas.

    splitted_string = STRSPLIT(l_file_content_as_many_strings[num_jobs_built],',',/EXTRACT);

    data_filename            = splitted_string[0];
    start_time_array_element = splitted_string[1];
    out_filename             = splitted_string[2];
    meta_filename            = splitted_string[3];
    original_uncompressed_filename = splitted_string[4];

    ;
    ; Build the IDL command for TaskDL to run. 
    ; The format is:
    ;
    ;  1. Name of the processing job.
    ;  2. Any parameters in double quotes, separate by commas.
    ;

    idl_command_string = "generate_modis_l2p_core_dataset"   +       $
                    ",'"  + original_uncompressed_filename + "'" + $
                    ",'" + data_filename                  + "'" + $
                    ",'" + out_filename                   + "'" + $
                    ",'" + start_time_array_element       + "'" + $
                    ",'" + meta_filename                  + "'" + $ 
                    ",'" + i_convert_to_kelvin            + "'" + $
                    ",'" + i_compress_flag                + "'" + $
                    ",'" + i_processing_type              + "'" + $
                    ",'" + i_L2P_registry                 + "'"

    r_processing_jobs_array[num_jobs_built] = idl_command_string;

    ;
    ;  Register that we will start each of these jobs.
    ;

    l_do_not_care_status = actualize_directory(GETENV('MODIS_CURRENT_JOBS_DIR'));
    l_register_status = register_current_job(GETENV('MODIS_CURRENT_JOBS_DIR'),out_filename+".bz2");

    ; Save the current jobs in case the current job registry need cleaning up.
 
    r_current_jobs_array[num_jobs_built] = out_filename +".bz2";

    ;
    ;  Keep track of how many jobs string built. 
    ;

    num_jobs_built = num_jobs_built + 1; 

endwhile    ; while ~eof(file_unit) do 

; ---------- Close up shop ----------
free_lun, file_unit;

end