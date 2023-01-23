#!/usr/local/bin/perl

#  Copyright 2016, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# Function returns the name of the registry based on the data source and processing type.
# If a new data source has been added, this is where the code will need to change.

#------------------------------------------------------------------------------------------------

sub generic_get_registry_filename {

    #
    # Get input.
    #
    
    my $i_scratch_area    = shift; # Directory where registry is stored. 
    my $i_data_source      = shift; # {MODIS_A,MODIS_T,VIIRS}
    my $i_processing_type = shift; # {QUICKLOOK,REFINED}

    my $debug_module = "generic_get_registry_filename:";
    my $debug_mode   = 0;

    my $o_L2P_registry = "";

    my $random_number = int(rand(1000));

    # Depend on the data source and processing type, use different registries.
    if ($i_data_source eq "MODIS_A" or $i_data_source eq "MODIS_T") {
        if ($i_processing_type eq "QUICKLOOK") {
            $o_L2P_registry = $i_scratch_area . "/ghrsst_master_" . lc($i_data_source) . "_quicklook_list_processed_files_" . $ENV{'RANDOM_NUMBER'} . ".dat";
        } elsif ($i_processing_type eq "REFINED") {
            $o_L2P_registry = $i_scratch_area . "/ghrsst_master_" . lc($i_data_source) . "_refined_list_processed_files_" . $ENV{'RANDOM_NUMBER'} . ".dat";
        }
    } elsif ($i_data_source eq "VIIRS") {
        if ($i_processing_type eq "QUICKLOOK") {
            $o_L2P_registry = $i_scratch_area . "/ghrsst_master_viirs_quicklook_list_processed_files_" . $ENV{'RANDOM_NUMBER'} . ".dat";
        } elsif ($i_processing_type eq "REFINED") {
            $o_L2P_registry = $i_scratch_area . "/ghrsst_master_viirs_refined_list_processed_files_" . $ENV{'RANDOM_NUMBER'} . ".dat";
        }
    } else {
        die($debug_module . "ERROR: This function does not yet support data source [$i_data_source]");
    }

    return ($o_L2P_registry);
}

# Main program calls the subroutine defined above.
my $debug_module = "generic_get_registry_filename:";
my $module_name  = "generic_get_registry_filename.pl";

if (index($0,$module_name) >= 0)
{
    my $debug_module = "generic_get_registry_filename:";

    my $scratch_area    = shift; # Directory where registry is stored. 
    my $data_source      = shift; # {MODIS_A,MODIS_T,VIIRS}
    my $processing_type = shift; # {QUICKLOOK,REFINED}

    $scratch_area    = $ENV{HOME} . "/scratch";

    my $o_L2P_registry = "";

    $data_source      = "MODIS_A";
    $processing_type = "QUICKLOOK";
    $o_L2P_registry = generic_get_registry_filename($scratch_area,
                                                    $data_source,
                                                    $processing_type);
    print "data_source $data_source processing_type $processing_type o_L2P_registry $o_L2P_registry\n";
    print "\n";

    $data_source      = "MODIS_A";
    $processing_type = "REFINED";
    $o_L2P_registry = generic_get_registry_filename($scratch_area,
                                                    $data_source,
                                                    $processing_type);
    print "data_source $data_source processing_type $processing_type o_L2P_registry $o_L2P_registry\n";
    print "\n";

    $data_source      = "MODIS_T";
    $processing_type = "QUICKLOOK";
    $o_L2P_registry = generic_get_registry_filename($scratch_area,
                                                    $data_source,
                                                    $processing_type);
    print "data_source $data_source processing_type $processing_type o_L2P_registry $o_L2P_registry\n";
    print "\n";

    $data_source      = "MODIS_T";
    $processing_type = "REFINED";
    $o_L2P_registry = generic_get_registry_filename($scratch_area,
                                                    $data_source,
                                                    $processing_type);
    print "data_source $data_source processing_type $processing_type o_L2P_registry $o_L2P_registry\n";
    print "\n";

    $data_source      = "VIIRS";
    $processing_type = "QUICKLOOK";
    $o_L2P_registry = generic_get_registry_filename($scratch_area,
                                                    $data_source,
                                                    $processing_type);
    print "data_source $data_source processing_type $processing_type o_L2P_registry $o_L2P_registry\n";
    print "\n";

    $data_source      = "VIIRS";
    $processing_type = "REFINED";
    $o_L2P_registry = generic_get_registry_filename($scratch_area,
                                                    $data_source,
                                                    $processing_type);
    print "data_source $data_source processing_type $processing_type o_L2P_registry $o_L2P_registry\n";
    print "\n";

    $data_source      = "THIS_DATA_SOURCE_IS_NOT_SUPPORTED_YET";
    $processing_type = "REFINED";
    $o_L2P_registry = generic_get_registry_filename($scratch_area,
                                                    $data_source,
                                                    $processing_type);
    print "data_source $data_source processing_type $processing_type o_L2P_registry $o_L2P_registry\n";
    print "\n";

    exit(0);
}
1;