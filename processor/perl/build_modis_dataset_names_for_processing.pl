#! /usr/local/bin/perl

#  Copyright 2007, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id: build_modis_dataset_names_for_processing.pl,v 1.3 2007/08/08 15:04:11 qchau Exp $
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

#
# Function build the names of MODIS dataset to process.
#
# Assumption:
#
#   1) Global variables:
#       $over_write_processed_modis_files
#       $NUM_FILES_TO_PROCESS
#   2) 
#
#------------------------------------------------------------------------------------------------

do "$GHRSST_PERL_LIB_DIRECTORY/get_ghrsst_config.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/build_modis_l2p_core_filename.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/build_name_without_bunzip_extension.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/build_L2P_processed_file_registry.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/does_file_exist_in_registry_or_filesystem.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/build_auxiliary_dataset_names_for_processing.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/rename_output_file_to_gds2_format.pl";

sub  build_modis_dataset_names_for_processing {

    # Returned status.  Value of 0 means ok, 1 means bad.

    my $o_status = 0;

    #
    # Get input.
    #
    
    my $i_tmp_uncompressed_bzip_filelist = shift; 
    my $i_L2P_registry                   = shift; 
    my $i_l2p_core_output_directory      = shift; 
    my $i_datasource                     = shift; 
    my $i_scratch_area                   = shift; 
    my $i_compress_flag                  = shift;
    my $ref_modis_filelist               = shift; # References to array variables
    my $i_processing_type                = shift;

    #
    # Local variables.  The @$ dereference the reference.
    #

    my @l_modis_filelist = @$ref_modis_filelist;

    my $debug_flag = 0;

    #
    # Returned array(s) and variable(s).
    #

    my @r_uncompressed_data_filelist  = (); 
    my @r_l2p_core_filelist           = (); 
    my @r_l2p_core_name_only_filelist = (); 
    my @r_meta_data_filelist          = (); 
    my @r_original_uncompressed_filelist = (); 

    my $r_num_uncompressed = 0;  # A running index of files uncompress from BZIP2 to HDF. 

    ################################################################################
    #                                                                              #
    # For each name in the list above, we check to see if it has been processed    #
    # previously.  If yes and the flag to overwrite is not set, then do nothing.   #
    #                                                                              #
    # If no, then we:                                                              #
    #                                                                              #
    #   1) Uncompress the file from .bz2 into HDF format to a scratch area         #
    #   2) Include this scratch HDF file name in a new list.                       # 
    #   3) Pass this list of "uncompressed" .bz2 data file to be processed.        # 
    #                                                                              #
    ################################################################################

    unlink("$i_tmp_uncompressed_bzip_filelist");
    open (FH, "> $i_tmp_uncompressed_bzip_filelist")
        or die "build_modis_dataset_names_for_processing:Can't open file to write uncompress BZIP2 file to: $!";

    #
    # Keep a list of files converted to later use for deletion.
    #

    my $num_modis_files = @l_modis_filelist;   # Get the number of files in the list.
    my $num_skipped     = 0;                   # Number of files skipped in this batch.
    $call_shell_command_str  = "$GLOBAL_SYSTEM_BIN_DIRECTORY/bunzip2";

    # For each new file, check against the i_L2P_registry.  If found, do nothing.

    for ($count = 0; ($count < $num_modis_files && $r_num_uncompressed < $NUM_FILES_TO_PROCESS); $count++) {
        chomp($l_modis_filelist[$count]);  # Remove the carriage return.

        my $l_modis_fullpathname = $l_modis_filelist[$count];

        #
        # Build output file name.
        #

        my $l_output_l2p_core_filename = ""; 
        my $l2p_core_filename_only   = ""; 
        my $l_meta_filename = ""; 
        my $l_output_yyyy = "";
        my $l_output_doy  = "";

        ($l_meta_filename,$l_output_l2p_core_filename,$l2p_core_filename_only,
         $l_output_yyyy,$l_output_doy) = 
              build_modis_l2p_core_filename($l_modis_fullpathname,$i_l2p_core_output_directory,
                                            $i_datasource);

        if ($debug_flag) {
            print "build_modis_dataset_names_for_processing:l_modis_fullpathname        [$l_modis_fullpathname]\n";
            print "build_modis_dataset_names_for_processing:i_l2p_core_output_directory [$i_l2p_core_output_directory]\n";
            print "build_modis_dataset_names_for_processing:i_datasource                [$i_datasource]\n";
            print "build_modis_dataset_names_for_processing:l_meta_filename             [$l_meta_filename]\n";
            print "build_modis_dataset_names_for_processing:l_output_l2p_core_filename  [$l_output_l2p_core_filename]\n";
            print "build_modis_dataset_names_for_processing:l2p_core_filename_only      [$l2p_core_filename_only]\n";
            print "build_modis_dataset_names_for_processing:l_output_yyyy               [$l_output_yyyy]\n";
            print "build_modis_dataset_names_for_processing:l_output_doy                [$l_output_doy]\n";
         }

        #
        # Get just the name without the directory.
        #

        ($r_after_bunzip_data_filename) =
              build_name_without_bunzip_extension($l_modis_fullpathname);

        #
        # Check to see if it has been processed before.
        #
        # The assumption is if the file is there, we don't process it again unless the user
        # set the global variable over_write_processed_modis_files to 1.
        #

        my $file_existed_already = 0; 

        # If we are processing GDS1 (default mode), we check to see if the file has been processed before.
        if ((uc($ENV{CREATE_MODIS_L2P_IN_GDS2_FORMAT}) eq 'FALSE') or 
               ($ENV{CREATE_MODIS_L2P_IN_GDS2_FORMAT}  eq ''     )) {

           $file_existed_already = does_file_exist_in_registry_or_filesystem(
                                    $i_L2P_registry,
                                    $i_scratch_area,
                                    $i_compress_flag,
                                    $l_output_l2p_core_filename,
                                    $l2p_core_filename_only,
                                    $i_processing_type);
        }

        # If we are processing GDS2 format, we change the l2p_core_filename_only and l_output_l2p_core_filename to reflect GDS2 file names
        # before checking to see if the file has been processed before.

        if ((   $ENV{CREATE_MODIS_L2P_IN_GDS2_FORMAT}  ne ''    ) and
            (uc($ENV{CREATE_MODIS_L2P_IN_GDS2_FORMAT}) eq 'TRUE')) {
           use File::Basename;
           my $gds2_core_filename_only = rename_output_file_to_gds2_format($l2p_core_filename_only);

           # Parse the l_output_l2p_core_filename just for the directory name.
           # The variable $path_name should contain a trailing '/', e.g. /data/dev/scratch/qchau/MODIS_L2P_CORE/MODIS_A_REFINED/2007/060/

           my ($name_only,$path_name)  = fileparse($l_output_l2p_core_filename);

           # Use the directory together with gds2_core_filename_only to build the gds2 output file name.
           #
           # Example:
           #
           #     l_output_l2p_core_filename /data/dev/scratch/qchau/MODIS_L2P_CORE/MODIS_A_REFINED/2007/060/20070301-MODIS_A-JPL-L2P-A2007060000000.L2_LAC_GHRSST_D-v01.nc
           #     path_name                  /data/dev/scratch/qchau/MODIS_L2P_CORE/MODIS_A_REFINED/2007/060/
           #     gds2_core_filename_only    20070301000000-JPL-L2P_GHRSST-SSTskin-MODIS_A-D-v02.0-fv01.0.nc
           #     gds2_output_core_filename  /data/dev/scratch/qchau/MODIS_L2P_CORE/MODIS_A_REFINED/2007/060/20070301000000-JPL-L2P_GHRSST-SSTskin-MODIS_A-D-v02.0-fv01.0.nc

           my $gds2_output_core_filename = $path_name . $gds2_core_filename_only;

           if ($debug_flag) {
               print "build_modis_dataset_names_for_processing:path_name                 [$path_name]\n";
               print "build_modis_dataset_names_for_processing:gds2_core_filename_only   [$gds2_core_filename_only]\n";
               print "build_modis_dataset_names_for_processing:gds2_output_core_filename [$gds2_output_core_filename]\n";
           }

           $file_existed_already = does_file_exist_in_registry_or_filesystem(
                                    $i_L2P_registry,
                                    $i_scratch_area,
                                    $i_compress_flag,
                                    $gds2_output_core_filename,
                                    $gds2_core_filename_only,
                                    $i_processing_type);
        }

        # Note that the logic is if the file exist and the flag to overwrite is not set
        # then do nothing.  If either the file is not found or the overwrite flag is set, then
        # it will go ahead the process this file.
        #

        if ($file_existed_already == 1 && $over_write_processed_modis_files == 0) {

            $num_skipped++;

        } else {

            my ($l_new_hdf_filename,
                $l_start_time_array_element,
                $l_global_start_date_utc,
                $l_global_start_time_utc) = build_auxiliary_dataset_names_for_processing(
                                                $i_l2p_core_output_directory,
                                                $l_output_yyyy,
                                                $l_output_doy,
                                                $l_modis_fullpathname,
                                                $i_scratch_area);

            # Save the original uncompress file name for later staging.
            $r_original_uncompressed_filelist[$r_num_uncompressed] = $l_modis_fullpathname; 

            # Save the output file name for later compression
            $r_l2p_core_filelist[$r_num_uncompressed] = $l_output_l2p_core_filename;

            # Save the metadata file name for later building FR.
            $r_meta_data_filelist[$r_num_uncompressed] = $l_meta_filename;

            # Save core file name only for later append to registry.
            $r_l2p_core_name_only_filelist[$r_num_uncompressed] = $l2p_core_filename_only;

            # Save the uncompressed HDF name for later deletion.
            $r_uncompressed_data_filelist[$r_num_uncompressed] = $l_new_hdf_filename;

            $r_num_uncompressed = $r_num_uncompressed + 1; 

            # Write the HDF file name and associated values the IDL program will need.

            if ($debug_flag) {
                print "build_modis_dataset_names_for_processing:l_new_hdf_filename         [$l_new_hdf_filename]\n";
                print "build_modis_dataset_names_for_processing:l_start_time_array_element [$l_start_time_array_element]\n";
                print "build_modis_dataset_names_for_processing:l_output_l2p_core_filename [$l_output_l2p_core_filename]\n";
                print "build_modis_dataset_names_for_processing:l_meta_filename            [$l_meta_filename]\n";
                print "build_modis_dataset_names_for_processing:l_modis_fullpathname       [$l_modis_fullpathname]\n";
            }

            print FH $l_new_hdf_filename, ",", $l_start_time_array_element;
            print FH ",", $l_output_l2p_core_filename;
            print FH ",", $l_meta_filename;
            print FH ",", $l_modis_fullpathname;
            print FH "\n";

      } # end if ($file_existed_already == 1 && $over_write_processed_modis_files == 0)

    } # end for ($count = 0; ($count < $num_modis_files && $r_num_uncompressed < $NUM_FILES_TO_PROCESS); $count++)

    close (FH);
my $end_processing_time = localtime;
print "------------------------------------------------------------\n";
print "build_modis_dataset_names_for_processing: Processing stats:\n\n";
print "build_modis_dataset_names_for_processing: " . $end_processing_time . " num_modis_files      = $num_modis_files\n";
print "build_modis_dataset_names_for_processing: " . $end_processing_time . " num_skipped          = $num_skipped\n";
print "build_modis_dataset_names_for_processing: " . $end_processing_time . " NUM_FILES_TO_PROCESS = $NUM_FILES_TO_PROCESS\n";
print "build_modis_dataset_names_for_processing: " . $end_processing_time . " r_num_uncompressed   = $r_num_uncompressed\n";
print "------------------------------------------------------------\n";
print "\n\n";

    return ($o_status,$r_num_uncompressed,
           \@r_original_uncompressed_filelist,
           \@r_uncompressed_data_filelist,
           \@r_l2p_core_filelist,
           \@r_l2p_core_name_only_filelist ,
           \@r_meta_data_filelist);
}
