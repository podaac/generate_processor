#!/usr/local/bin/perl

# Program manages the GHRSST datasets by:
#
#    1) Defining location of various directories and symbols.
#    2) Calls the following subroutine to:
#
#        ghrsst_modis_file_manager()      Read and process the dataset data files.
#
# How this program is ran:
#
#    1) Either submit this file as part of a crontab or run it
#       with the name of the file on command line.
#
#------------------------------------------------------------------------------------------------

# Location of GHRSST Perl library functions.
$GHRSST_PERL_LIB_DIRECTORY = $ENV{GHRSST_PERL_LIB_DIRECTORY};
do "$GHRSST_PERL_LIB_DIRECTORY/ghrsst_modis_file_manager.pl";

# Debug Flag
my $debug_module = "ghrsst_generic_seatmp_manager:";
my $debug_mode   = 1;

# Set global number of files to process each time. Useful in coding and debugging and in controlling how long the script should run for.
$NUM_FILES_TO_PROCESS = 100;

# Set global flag to 1 if wish to overwrite existing files.
# Normally, this should be set to zero.
$over_write_processed_modis_files = 0;

# Get the user's original umask and save it.
my $original_user_mask = umask();
my $previous_mask = umask(02);    # Set the umask to 02 (results in g+rw) so people in the same group can modify MODIS L2P files.
my $new_mask = umask();

# Command line arguments
my $num_args = $#ARGV + 1;
my $dataset_name = "";
my $processing_type = "";

if ($num_args >= 5) {
    if ($ARGV[0] ne '') {
        $NUM_FILES_TO_PROCESS = $ARGV[0];
    }
    if ($ARGV[1] ne '' && $ARGV[1] eq "yes") {
        $over_write_processed_modis_files = 1;
    }
    if ($ARGV[2] ne '') {
        $dataset_name = $ARGV[2];
    }
    if ($ARGV[3] ne '') {
        $processing_type = $ARGV[3];
    }
    if ($ARGV[4] ne '') {
        $job_index = $ARGV[4];
    }
} else {
    print $debug_module . "ERROR:Example of good runs\n";
    print "perl ghrsst_generic_seatmp_manager.pl 1 yes VIIRS QUICKLOOK 0\n";
    print "perl ghrsst_generic_seatmp_manager.pl 1 yes VIIRS REFINED 0\n";
    print "perl ghrsst_generic_seatmp_manager.pl 1 yes MODIS_A QUICKLOOK 0\n";
    print "perl ghrsst_generic_seatmp_manager.pl 1 yes MODIS_A REFINED 0\n";
    die($debug_module . "ERROR:You must provide at least 5 required parameters: num_files_to_process over_write_flag dataset_name processing_type job_index");
}

if ($dataset_name eq "") {
    die($debug_module . "ERROR:You must provide the dataset_name parameter: {MODIS_A,MODIS_T,VIIRS}.  Program exiting");
}
if ($processing_type eq "") {
    die($debug_module . "ERROR:You must provide the processing_type parameter: {QUICKLOOK,REFINED}.  Program exiting");
}

# Set the environment variable which sets the log file name for processing.
# Some example of possible log file names are:
#     ghrsst_viirs_processing_log_archive.txt     for the VIIRS dataset name.
#     ghrsst_modis_a_processing_log_archive.txt   for the MODIS_A dataset name.
#     ghrsst_modis_t_processing_log_archive.txt   for the MODIS_T dataset name.
#
# When the L2P Processing module is running, the logging will go to these files.
$ENV{GAPFARMPROCESSINGLOGFILENAME} = "ghrsst_" . lc($dataset_name) . "_processing_log_archive_" . $ENV{'RANDOM_NUMBER'} . ".txt";

if ($debug_mode) {
    print $debug_module . "NUM_FILES_TO_PROCESS [$NUM_FILES_TO_PROCESS]\n";
    print $debug_module . "over_write_processed_modis_files [$over_write_processed_modis_files]\n";
    print $debug_module . "dataset_name    [$dataset_name]\n";
    print $debug_module . "processing_type [$processing_type]\n";
    print $debug_module . "GAPFARMPROCESSINGLOGFILENAME [" . $ENV{GAPFARMPROCESSINGLOGFILENAME} ."]\n";
    print $debug_module . "job_index [$job_index]\n";
    print $debug_module . "RANDOM_NUMBER [$ENV{RANDOM_NUMBER}]\n";
}

#  Call subroutine to manage the data files.
ghrsst_modis_file_manager("sea_surface_temperature",
                           $dataset_name,
                           $ENV{FTP_PUSH_FLAG},
                           $ENV{COMPRESS_FLAG},
                           $ENV{CHECKSUM_FLAG},
                           $ENV{CONVERT_TO_KELVIN},
                           $processing_type,
                           $job_index,
                           $ENV{USE_CLUSER_FLAG});

# Reset to user's original mask.
umask($original_user_mask);
$current_mask = umask();
