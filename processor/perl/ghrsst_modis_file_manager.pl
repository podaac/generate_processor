#!/usr/local/bin/perl

#  Copyright 2006, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id: ghrsst_modis_file_manager.pl,v 1.16 2007/11/14 00:04:34 qchau Exp $
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
# New Request #xxxx

#
#
# Program manages the GHRSST datasets by:
#
#    1) Defining location of various directories and symbols.
#    2) Calls the following subroutines:
#
#        manage_ghrsst_modis_data_sets()         Read FNMOC data files and updates the MAF.
#
# How this program is ran (for now):
#
#    1) Edit this file to match the location of various directories that matches where the
#       .
#
#    2) Either submit this file as part of a crontab or run it
#       with the name of the file on command line on calypso.
#    
#------------------------------------------------------------------------------------------------

#
# Location of configuration file.
# This file is read by ghrsst_ecmwf_maf_manager.pl and ghrsst_modis_file_manager to load
# into memory such things as locations of where the sea ice, sea temperature, windspeed are found
# on the ftp site, prefix of dataset file names.
#

$GHRSST_DATA_CONFIG_FILE = "";

# Make the library functions available.

do "$GHRSST_PERL_LIB_DIRECTORY/manage_ghrsst_modis_data_sets.pl";

do "$GHRSST_PERL_LIB_DIRECTORY/load_ghrsst_run_config.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/get_ghrsst_config.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/verify_taskdl_environment_setup.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/email_ops_to_report_error.pl";

sub ghrsst_modis_file_manager()
{

  my $begin_processing_time = localtime;
  print "ghrsst_modis_file_manager: begin_processing_time = $begin_processing_time\n";

  #
  # Get input parameters.
  #
  # Possible value for i_data_type are:
  #
  #   "sea_surface_temperature"
  #
  # Possible value for i_datasource are:
  #
  #   "modis"

  my $i_data_type         = lc($_[0]);
  my $i_datasource        = $_[1];
  my $i_ftp_push_flag     = $_[2];
  my $i_compress_flag     = lc($_[3]);
  my $i_checksum_flag     = lc($_[4]);
  my $i_convert_to_kelvin = lc($_[5]);
  my $i_processing_type   = uc($_[6]);   # Either QUICKLOOK or REFINED
  my $i_job_index         = $_[7];
  my $i_use_cluster_flag  = uc($_[8]);
  my $i_test_parameter    = $_[9];

  # Reset last parameter if not passed in.
  if ($i_use_cluster_flag eq "") {
      $i_use_cluster_flag  = "LEAVE_ALONE_CLUSTER_IF_AVAILABLE";
  }

  # Reset if TaskDL environment is not set up correctly.
  if (verify_taskdl_environment_setup() != 1) {
      print "ghrsst_modis_file_manager: WARNING, Cannot use slave nodes.  Will be using head node for processing.\n";
      $i_use_cluster_flag  = "LEAVE_ALONE_CLUSTER_IF_AVAILABLE";
  }

  # Execution status.  Value of 0 means OK, 1 means bad.

  my $status = 0;

#  print "ghrsst_modis_file_manager: i_test_parameter [$i_test_parameter]\n";
#  return $status;

  # Location of config file.

  $GHRSST_DATA_CONFIG_FILE = $ENV{GHRSST_DATA_CONFIG_FILE};

  #
  # Load GHRSST run config into memory.
  #

  my $l_status = load_ghrsst_run_config($GHRSST_DATA_CONFIG_FILE);


  # Location of bin directories as global to be used by functions.  May be different on different
  # machines.  On seaworld, the two values are /usr/bin and /bin

  $GLOBAL_SYSTEM_BIN_DIRECTORY = get_ghrsst_config("LOCAL_MACHINE_SYSTEM_BIN_DIRECTORY");
  $GLOBAL_SHELL_BIN_DIRECTORY  = get_ghrsst_config("LOCAL_MACHINE_SHELL_BIN_DIRECTORY");

  #
  # Process the datasets.  For now,  only processing MODIS data.
  #

  if (($i_datasource eq "MODIS_A" or $i_datasource eq "MODIS_T") or 
      ($i_datasource eq "VIIRS")) { 
      # If processing VIIRS dataset, we set the environment variable GHRSST_L2P_VIIRS_RUN_MODE to true so the IDL knows which function to call.
      if ($i_datasource eq "VIIRS") { 
          $ENV{GHRSST_L2P_VIIRS_RUN_MODE} = "true";
      }
      $status = manage_ghrsst_modis_data_sets($i_data_type,$i_datasource,$i_ftp_push_flag,
                    $i_compress_flag,$i_checksum_flag,$i_convert_to_kelvin,$i_processing_type,
                    $i_job_index, $i_use_cluster_flag, $i_test_parameter);
  } else {
      print "ghrsst_modis_file_manager: data source is not supported at this time: $i_datasource.\n";

      my @error_message = ();
      push(@error_message,"\n");
      push(@error_message,"You are receiving this message because there was an error in MODIS L2P Processing.\n");
      push(@error_message,"Please do not reply to the email.\n");
      push(@error_message,"\n");
      push(@error_message,"ghrsst_modis_file_manager: data source is not supported at this time: $i_datasource\n");
      push(@error_message,"\n");
  
      email_ops_to_report_error(\@error_message);

  }

#  print "ghrsst_modis_file_manager: status = [$status]\n";
  if ($status != 0) {
    print "ghrsst_modis_file_manager: Function manage_ghrsst_modis_data_sets() failed.  No need to continue\n";
    print "ghrsst_modis_file_manager: status = $status\n";
  }

  my $end_processing_time = localtime;
  print "ghrsst_modis_file_manager: begin_processing_time = $begin_processing_time\n";
  print "ghrsst_modis_file_manager: end_processing_time   = $end_processing_time\n";
}
# ---------- Close up shop ----------
end
