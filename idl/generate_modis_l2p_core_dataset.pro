;  Copyright 2007, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: generate_modis_l2p_core_dataset.pro,v 1.9 2008/01/07 20:30:22 qchau Exp $
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

PRO generate_modis_l2p_core_dataset, $
    i_original_uncompressed_filename,$
    i_data_filename,                 $
    i_l2p_core_filename,             $ 
    i_start_time_array_element,      $ 
    i_meta_data_filename,            $
    i_convert_to_kelvin,             $
    i_compress_flag,                 $
    i_processing_type,               $
    i_L2P_registry,                  $
    i_test_parameter

; Program read from file containing a list of datasets to process, read each file
; and convert them from HDF format to NetCDF format with some processing. 
; September, 2013: Added parameter i_test_parameter to allow parent code to inject error into this
;                  program.
;
; Assumptions:
;
;   1. TBD 
;
;------------------------------------------------------------------------------------------------

; Load constants.  No ending semicolon is required.

@modis_data_config.cfg

over_all_status = SUCCESS;

; Set the test parameter based on what's being passed in to test.
; For normal operation, the value of i_test_parameter is not set so the N_ELEMENTS() function will return 0.
TEST_PARAMETER = STRUPCASE(GETENV('TEST_PARAMETER_STR'))
if (N_ELEMENTS(i_test_parameter) NE 0) then begin
    TEST_PARAMETER = i_test_parameter;
endif

routine_name = 'generate_modis_l2p_core_dataset.pro';
i_data       = '';

; Get the DEBUG_MODE if it is set.

debug_module = 'generate_modis_l2p_core_dataset.pro';
debug_mode = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif

; Benchmark time.

program_start_time = SYSTIME(/SECONDS);

; Get just the file name without the directory.

splitted_string = strsplit(i_data_filename, "/", /REGEX, /EXTRACT);
num_substrings = SIZE(splitted_string,/N_ELEMENTS);
in_filename_only = splitted_string[num_substrings-1];

;help,    i_original_uncompressed_filename 
;help,    i_data_filename
;help,    i_l2p_core_filename 
;help,    i_start_time_array_element
;help,    i_meta_data_filename
;help,    i_convert_to_kelvin
;help,    i_L2P_registry 

; Note: For now, assumes the file has been uncompressed already.
;       So we comment out the code that deletes it. 
;; Check to see if the output file exist.  Delete if found.
;if FILE_TEST(i_data_filename) then begin
;    print, 'generate_modis_l2p_core_dataset: INFO: File ', i_data_filename, ' exists.  Will be deleted';
;    FILE_DELETE, i_data_filename, /QUIET;
;endif

;
; Uncompress the original data file from .bz2 into HDF file.
;

;print, 'generate_modis_l2p_core_dataset: before uncompress_one_modis_dataset'
uncompress_start_time = SYSTIME(/SECONDS);

;l_uncompress_status = uncompress_one_modis_dataset($
;                          i_data_filename);
l_uncompress_status = uncompress_one_modis_dataset($
                          i_data_filename,$
                          "MODIS_INPUT_DATA_FILE",$
                          i_l2p_core_filename);

;l_uncompress_status = SUCCESS;

uncompress_total_time = SYSTIME(/SECONDS) - uncompress_start_time;

; Log the file being processed based on which format this is.

create_gds2_formatted_file_flag = 1;  By default, set this flag to 1 and reset back to 0 if CREATE_MODIS_L2P_IN_GDS2_FORMAT is not set or blank.
if ((GETENV('CREATE_MODIS_L2P_IN_GDS2_FORMAT') EQ 'false') OR (GETENV('CREATE_MODIS_L2P_IN_GDS2_FORMAT') EQ '')) then begin
    create_gds2_formatted_file_flag = 0;
endif

if (create_gds2_formatted_file_flag EQ 0) then begin
    do_not_care = write_to_processing_log(FILE_BASENAME(i_l2p_core_filename),$
                                      (i_processing_type + "," + "GDS1_UNCOMPRESS_TOTAL_TIME: " + $
                                       STRING(uncompress_total_time,FORMAT='(f0.2)')))
endif else begin
    r_day_or_night = '';
    if (STRPOS(i_data_filename,'.nc') GE 0) then begin
        r_status = read_netcdf_global_attribute(i_data_filename,'Day_or_Night',r_day_or_night);
    endif else begin
        r_status = read_hdf_global_attribute(i_data_filename,'Day or Night',r_day_or_night);
    endelse
    r_day_or_night = convert_to_ascii_string(r_day_or_night);

    saved_l2p_core_filename = i_l2p_core_filename;
    donotcare = rename_output_file_to_gds2_format_without_file_move($
                    r_day_or_night,$
                    saved_l2p_core_filename,$
                    o_actual_gds2_out_filename);
    do_not_care = write_to_processing_log(FILE_BASENAME(o_actual_gds2_out_filename),$
                                          (i_processing_type + "," + "GDS2_UNCOMPRESS_TOTAL_TIME: " + $
                                           STRING(uncompress_total_time,FORMAT='(f0.2)')))
endelse

do_not_care = verify_returned_status(in_filename_only,l_uncompress_status,SUCCESS,'Cannot uncompress data file');

if (l_uncompress_status NE SUCCESS) then begin
    print, routine_name + ' - INFO: Cannot uncompress data file: ' + in_filename_only;
    print, routine_name + ' - INFO: Will return without doing any further work.';

    l_status = error_log_writer($
              'generate_modis_l2p_core_dataset',$
              'Cannot uncompress data file:' + in_filename_only, $
              /DO_NOT_PRINT);

    l_do_not_care = clean_up_modis_processing(i_l2p_core_filename);
    FILE_DELETE, i_data_filename, /QUIET;

    ; Remove current job from directory.

    l_remove_status = erase_current_job(GETENV('MODIS_CURRENT_JOBS_DIR'), $
                      i_l2p_core_filename + ".bz2");

    return
endif

; Further uncompress the filled Quicklook so the Refined processing can fill the ancillary
; datasets. 
;
; Assumption: the file is BZ2 compressed.

if (i_processing_type EQ 'REFINED') then begin
    l_uncompress_status = uncompress_one_modis_dataset($
                          i_data_filename,$
                          "MODIS_FILLED_QUICKLOOK",$
                          i_l2p_core_filename);
endif

;
; Convert HDF or NetCDF to NetCDF and make metadata file.
;

convert_start_time = SYSTIME(/SECONDS);

; Save the original_out_filename so we can delete the job.
original_out_filename = i_l2p_core_filename;

l_convert_status = convert_modis_and_make_meta(    $
                       i_data_filename,            $
                       i_l2p_core_filename,        $ 
                       i_start_time_array_element, $ 
                       i_meta_data_filename,       $ 
                       i_convert_to_kelvin,        $
                       i_processing_type,          $
                       i_L2P_registry,             $
                       i_test_parameter);

convert_total_time = SYSTIME(/SECONDS) - convert_start_time;
do_not_care = write_to_processing_log(FILE_BASENAME(i_l2p_core_filename),$
                                      (i_processing_type + "," + "CONVERT_TOTAL_TIME: " + $
                                       STRING(convert_total_time,FORMAT='(f0.2)')))

if (TEST_PARAMETER EQ "CONVERT_MODIS_AND_MAKE_META_FAILED") then begin
    l_convert_status = FAILURE;
endif

if (l_convert_status NE SUCCESS) then begin

    ; Quarantine (make a copy) the staged data file so we can inspect it later.

    quarantine_status = quarantine_one_staged_dataset(i_data_filename);

    l2p_output_name_used_in_reporting = '';
    if (create_gds2_formatted_file_flag EQ 0) then begin
        l2p_output_name_used_in_reporting = i_l2p_core_filename;
    endif else begin
        l2p_output_name_used_in_reporting = o_actual_gds2_out_filename;
    endelse
    l_status = error_log_writer($
               'generate_modis_l2p_core_dataset',$
               'GHRSST_PROCESSING_ERROR ' + ' Function convert_modis_and_make_meta failed to convert file ' + l2p_output_name_used_in_reporting + ' from file ' + i_data_filename,$
               /DO_NOT_PRINT);

    msg_type = "error";
    msg = 'Function convert_modis_and_make_meta failed to convert file ' + l2p_output_name_used_in_reporting + ' from file ' + i_data_filename + ". Files associated with processing have been quarantined.";
    print, routine_name + ' - INFO: ' + msg;
    donotcare = wrapper_ghrsst_notify_operator($
                        routine_name,$
                        msg_type,$
                        msg,$
                        i_data);

     ; Must return immediately.
     return;
endif

if (debug_mode) then begin
    print, routine_name + ' - INFO: i_compress_flag = ' + i_compress_flag;
    print, routine_name + ' - INFO: FORCE_COMPRESS_GDS2_FORMAT_FLAG = ' + GETENV('FORCE_COMPRESS_GDS2_FORMAT_FLAG');
endif

;
; Compress L2P and ftp push to melia for QA.
;
if ((i_compress_flag EQ "yes") OR (GETENV('FORCE_COMPRESS_GDS2_FORMAT_FLAG') EQ 'true')) then begin
    ; Only compress and push and L2P core dataset to melia if it was successfully created and the flag
    ; indicated so.
    if (l_convert_status EQ SUCCESS) then begin
        compresspush_start_time = SYSTIME(/SECONDS);

        a_push_for_dmas_ingestion_flag = 'no'; Set to no for default. 

        ; Get the flag to push the files to DMAS for ingestion from environment variable.

        if ((GETENV('SEND_MODIS_L2P_TO_DMAS_FOR_INGESTION_FLAG') EQ "true") OR (GETENV('SEND_MODIS_L2P_TO_DMAS_FOR_INGESTION_FLAG') EQ "TRUE")) then begin 
            a_push_for_dmas_ingestion_flag = 'yes'; 
        endif

if (debug_mode) then begin
    print, routine_name + 'i_meta_data_filename           ' + i_meta_data_filename
    print, routine_name + 'i_l2p_core_filename            ' + i_l2p_core_filename
    print, routine_name + 'i_L2P_registry                 ' + i_L2P_registry
    print, routine_name + 'i_processing_type              ' + i_processing_type
    print, routine_name + 'i_compress_flag                ' + i_compress_flag
    print, routine_name + 'a_push_for_dmas_ingestion_flag ' + a_push_for_dmas_ingestion_flag
endif

        l_compress_status = compress_and_ftp_push_modis_L2P_core_datasets( $
                            i_meta_data_filename,     $
                            i_l2p_core_filename,      $ 
                            i_L2P_registry,           $
                            i_processing_type,i_compress_flag,a_push_for_dmas_ingestion_flag);

        if (TEST_PARAMETER EQ "COMPRESS_AND_FTP_PUSH_FAILED") then begin
            l_compress_status = FAILURE;
        endif

        if (l_compress_status NE SUCCESS) then begin
            ; Since the files could not be ftp to melia.jpl.nasa.gov for QA perhaps
            ; because of network problem, the staged data file and the empty file will be removed from
            ; current_jobs directory so they can be picked up again next time.

            ; Quarantine (make a copy) the staged data file so we can inspect it later.

            quarantine_status = quarantine_one_staged_dataset(i_data_filename);

            l_erase_status = erase_one_staged_dataset($
                                 i_data_filename, $
                                 i_processing_type, $
                                 i_l2p_core_filename);

            l_remove_status = erase_current_job(GETENV('MODIS_CURRENT_JOBS_DIR'), $
                                  FILE_BASENAME(original_out_filename) + ".bz2");

            l_status = error_log_writer($
                      'generate_modis_l2p_core_dataset',$
                      'GHRSST_PROCESSING_ERROR ' + ' Function compress_and_ftp_push_modis_L2P_core_datasets failed for file ' + i_l2p_core_filename,$
                      /DO_NOT_PRINT);

            msg_type = "error";
            msg = 'Function compress_and_ftp_push_modis_L2P_core_datasets failed for file ' + i_l2p_core_filename + ". Files associated with processing have been quarantined.";
            donotcare = wrapper_ghrsst_notify_operator($
                        routine_name,$
                        msg_type,$
                        msg,$
                        i_data);

        endif else begin

        ; We only write to processing log both
        ; COMPRESSPUSH_TOTAL_TIME and SUCCESS_OVERALL_TOTAL_TIME stages if the files were successfully
        ; pushed to melia for QA.

        compresspush_total_time = SYSTIME(/SECONDS) - compresspush_start_time;
        do_not_care = write_to_processing_log(FILE_BASENAME(i_l2p_core_filename),$
                                      (i_processing_type + "," + "COMPRESSPUSH_TOTAL_TIME: " + $
                                       STRING(compresspush_total_time,FORMAT='(f0.2)')))

        program_elapsed_time = SYSTIME(/SECONDS) - program_start_time; 
        do_not_care = write_to_processing_log(FILE_BASENAME(i_l2p_core_filename),$
                                      (i_processing_type + "," + "SUCCESS_OVERALL_TOTAL_TIME: " + $
                                       STRING(program_elapsed_time,FORMAT='(f0.2)')))
        endelse

    endif
endif else begin
        ; Even though the file won't be compressed, we can still build the checksum file.
        a_push_for_dmas_ingestion_flag = 'no'; Set to no for default. 

        ; Get the flag to push the files to DMAS for ingestion from environment variable.

        if ((GETENV('SEND_MODIS_L2P_TO_DMAS_FOR_INGESTION_FLAG') EQ "true") OR (GETENV('SEND_MODIS_L2P_TO_DMAS_FOR_INGESTION_FLAG') EQ "TRUE")) then begin 
            a_push_for_dmas_ingestion_flag = 'yes'; 
        endif

        donotcare = build_checksum_and_ftp_push_modis_L2P_core_datasets($
                        i_l2p_core_filename,$
                        i_L2P_registry,$
                        i_processing_type,$
                        i_compress_flag,$
                        a_push_for_dmas_ingestion_flag);
endelse

; ---------- Close up shop ----------
FILE_DELETE, i_data_filename, /QUIET;

l_remove_status = erase_current_job(GETENV('MODIS_CURRENT_JOBS_DIR'), $
                      original_out_filename + ".bz2");

program_elapsed_time = SYSTIME(/SECONDS) - program_start_time; 
print, routine_name + " - INFO: program_elapsed_time (in seconds) = " + STRING(program_elapsed_time);

do_not_care = write_to_processing_log(FILE_BASENAME(i_l2p_core_filename),$
                                      (i_processing_type + "," + "OVERALL_TOTAL_TIME: " + $
                                       STRING(program_elapsed_time,FORMAT='(f0.2)')))

print, routine_name + " - INFO: Processed: " + FILE_BASENAME(i_l2p_core_filename)

end
