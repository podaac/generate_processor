#!/usr/local/bin/perl

#  Copyright 2012, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
#
# Function that takes an input directory and JSON file and extracts a file list
# to process based on an index value.
#
#------------------------------------------------------------------------------------------------

use File::Basename;
use JSON;
use Date::Calc qw(Day_of_Week Week_Number Day_of_Year);

use strict;
use warnings;

sub load_file_list {

    my $status = 0;

    # Inputs
    my $input_dir = shift;
    my $data_source = shift;
    my $processing_type = lc(shift);
    my $prefix = shift;
    my $job_index = shift;

    # JSON data
    my $json_file = dirname($input_dir) . '/' . $ENV{JSON_FILE};
    my $json = do {
        open(my $json_fh, "<:encoding(UTF-8)", $json_file)
            or die("Can't open \"$json_file\": $!\n");
        local $/;
        <$json_fh>
    };
    
    # Retreive time stamps
    my $decoded = decode_json($json);
    my $index = $ENV{INDEX};
    my $time_stamps = $decoded->[$index];

    # Determine final output extensions
    my $day_ext;
    my $night_ext;
    if ($data_source eq 'MODIS_A' || $data_source eq 'MODIS_T') {
        $day_ext = '.LAC_GSSTD.nc';
        $night_ext = '.LAC_GSSTN.nc'
    } elsif ($data_source eq 'VIIRS') {
        $day_ext = '.SNPP_GSSTD.nc';
        $night_ext = '.SNPP_GSSTN.nc';
    } else {
        # Not a valid data source
        $status = 1;
        my @input_list_ref;
        return ($status, \@input_list_ref);
    }

    # Locate file based on year, doy, and timestamp and add to list
    my @input_list_ref;
    for my $time ( @$time_stamps ) {
        # Extract date
        my $year = substr $time, 0, 4;
        my $month = substr $time, 4, 2;
        my $day = substr $time, 6,2;
        my $doy = Day_of_Year($year, $month, $day);
        # Piece together full path to file name
        my $input_day = '';
        my $input_night = '';
        if ($processing_type eq "quicklook") {
            $input_day = $input_dir . $year . '/' . $doy . '/' . $prefix . $time . $day_ext;
            $input_night = $input_dir . $year . '/' . $doy . '/' . $prefix . $time . $night_ext;
        } else {
            $input_day = $input_dir . $year . '/' . $doy . '/' . $processing_type . '_' . $prefix . $time . $day_ext;
            $input_night = $input_dir . $year . '/' . $doy . '/' . $processing_type . '_' . $prefix . $time . $night_ext;
        }
        
        # Determine if night and/or day file exist and add to list
        if (-f $input_day) {
            push @input_list_ref, "$input_day\n";
        }
        if (-f $input_night) {
            push @input_list_ref, "$input_night\n";
        }
    }

    return ($status, \@input_list_ref);    
}