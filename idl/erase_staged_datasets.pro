;  Copyright 2008, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

; Function remove staged datasets from the scratch area.
;
; The likely reason of having to call this function is if the process cannot connect
; to TaskDL because IDL licenses were not available at the time.
;
FUNCTION erase_staged_datasets, $
             i_datasets_list

; Load constants.  No ending semicolon is required.

@modis_data_config.cfg

; Returned status.  Value of 0 means ok, 1 means bad.

o_status = SUCCESS;

;
; Open and read the dataset list.
;

openr, file_unit, i_datasets_list, ERROR = err, /GET_LUN;

;
; If err is nonzero, something bad happened.  Print the error message
; to the standard error file (logical unit -2):

; Note: Changed later to print to log if desire.

if (err NE 0) then begin
    print, 'erase_staged_datasets.pro - ERROR: Cannot open file for input:' + i_datasets_list
    o_status = FAILURE;
    return, o_status
end

;
; Loop through the entire file, get each name and delete it.
;

files_removed = 0L;
a_line = ''; Must let IDL know that this is a string so it knows how to read in the readf().

print, 'erase_staged_datasets.pro - INFO: Removing staged datasets...';

while (~eof(file_unit)) do begin
    ;
    ; Get one file name.  Assumes one file name and a few other attributes per line.
    ; No error handling.
    ;

    readf, file_unit, FORMAT='(A)', a_line;

    ; Parse the line for the fields separated by commas.

    splitted_string = STRSPLIT(a_line,',',/EXTRACT);

    ; We only want fields 0 and 2: the data filename, and out_filename

    data_filename = splitted_string[0];
    out_filename  = splitted_string[2];

    ; Check to see if this is not an empty string and the file does exist.
    ; Note: Remove the .bz2 extension file as well if it exists.
    ;       This is to handle the case where the staged file was not uncompressed.

    if (STRLEN(data_filename) GT 0) then begin
        ; Remove this file and the possible .bz2 extension.
        ;

        print, 'erase_staged_datasets.PRO - INFO: Removing [' + data_filename+ ']';
        ;        FILE_DELETE, data_filename         , /QUIET;
        print, 'erase_staged_datasets - INFO: Removing [' + data_filename + '.bz2' + ']';
        ;        FILE_DELETE, data_filename + '.bz2', /QUIET;

        ; Quarantine (make a copy) the staged data file so we can inspect it later.

        quarantine_status = quarantine_one_staged_dataset(data_filename);

        ; Remove the filled MODIS L2P if it exists.
        ; Assumption: The scratch directory holds both the staged data file and the
        ;             ancillary filled MODIS L2P.

        scratch_directory = FILE_DIRNAME(data_filename);
        filled_quick_name_only = FILE_BASENAME(out_filename);
        filled_quicklook_filename = scratch_directory + "/" + filled_quick_name_only;

        print, 'erase_staged_datasets - INFO: Removing [' + filled_quicklook_filename + ']';
        ;        FILE_DELETE, filled_quicklook_filename         , /QUIET;
        print, 'erase_staged_datasets - INFO: Removing [' + filled_quicklook_filename + '.bz2' + ']';
        ;        FILE_DELETE, filled_quicklook_filename + '.bz2', /QUIET;

        ;
        ;  Keep track of how many files removed.
        ;

        files_removed = files_removed + 1; 
    endif

endwhile    ; while ~eof(file_unit) do 

print, 'erase_staged_datasets - INFO: Number of staged datasets removed = ', files_removed;

; ---------- Close up shop ----------
free_lun, file_unit;

RETURN, o_status;
END
