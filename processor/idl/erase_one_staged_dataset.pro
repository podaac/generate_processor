;  Copyright 2008, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

; Function remove one staged datasets from the scratch area.
;
; If the processing type is REFINED, it will also remove the filled quicklook.

FUNCTION erase_one_staged_dataset, $
             i_data_filename, $
             i_processing_type, $ 
             i_l2p_core_filename

; Load constants.  No ending semicolon is required.

@modis_data_config.cfg

; Returned status.  Value of 0 means ok, 1 means bad.

o_status = SUCCESS;

; Remove the data file.

print, 'erase_one_staged_dataset:INFO, removing [' + i_data_filename + ']';
FILE_DELETE, i_data_filename, /QUIET;
print, 'erase_one_staged_dataset:INFO, removing [' + i_data_filename + '.bz2' + ']';
FILE_DELETE, i_data_filename + '.bz2' , /QUIET;

; Remove the Filled Quicklook MODIS L2P file if processing type is REFINED.

if (i_processing_type EQ "REFINED") then begin

    ; Extract the directory from the input data file name.
    scratch_directory = FILE_DIRNAME(i_data_filename);

    ; Extract the name only from the refined MODIS L2P
    filled_quick_name_only = FILE_BASENAME(i_l2p_core_filename); 

    ; Build the Filled Quicklook MODIS L2P filename.
    ; Assumption: the file has been uncompressed from BZ2 to .nc

    filled_quicklook_filename = scratch_directory + "/" + filled_quick_name_only;

    ; Delete the staged Filled Quicklook file.
print, 'erase_one_staged_dataset:INFO, removing [' + filled_quicklook_filename + ']';
    FILE_DELETE, filled_quicklook_filename, /QUIET;
print, 'erase_one_staged_dataset:INFO, removing [' + filled_quicklook_filename + '.bz2' + ']';
    FILE_DELETE, filled_quicklook_filename + '.bz2', /QUIET;
endif

RETURN, o_status;
END
