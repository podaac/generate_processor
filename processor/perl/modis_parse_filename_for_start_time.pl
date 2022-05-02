#! /usr/local/bin/perl

#  Copyright 2005, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id: modis_parse_filename_for_start_time.pl,v 1.6 2007/05/21 17:05:32 qchau Exp $
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
# New Request #xxxx

# Subroutine parses a MODIS sea surface temperature for the start time
# Certain assumptions are made about the format of the filename.
#
#------------------------------------------------------------------------------------------------

do "$GHRSST_PERL_LIB_DIRECTORY/convert_to_mm_day.pl";

sub modis_parse_filename_for_start_time {

    #
    # Get input.
    #

    my $i_filename = $_[0];

    #
    # Local variables.
    #
    
    my $r_status = 0;

    # Default output values with some unrealistic time.

    my $r_start_time_array_element = '9999999999T000000Z';
    my $r_global_start_date_utc    = '9999-99-99 UTC';
    my $r_global_start_time_utc    = '99:99:99 UTC';

    #
    # The filename has the below format:
    #
    # /project/nrt/melia/oceanids/data/GHRSST-TEMP/MODIS/2006/097/ 
    #    A2006097005500.L2_LAC_GSSTN.bz2 
    #
    #     01234567890  
    #
    # We must advance one position past the last '/' is there is one.
    #
    # The first part of the start_time is 2006097, then the 2nd part is
    #  005500

    #
    # Search for the last '/' if there is one.
    #

    my $last_slash_pos = rindex($i_filename,"/");

    my $name_to_parse_from = '';

    if ($last_slash_pos != -1) {

        # The name has directory.  Extract just the name.

        $name_to_parse_from = substr($i_filename, $last_slash_pos + 1);

    } else {

        # The name has no directory. It is the name we want to parse from. 

        $name_to_parse_from = $i_filename; 

    } 

    #
    # Now, we split the name into separate substrings separated by the dot. 
    #

#    print "name_to_parse_from = $name_to_parse_from\n";
    
    my @splitted_array = split(/\./,$name_to_parse_from);
#    my @splitted_array = split(/\./,$name_only);



    #
    # Remove any refined prefix.
    #
    my $name_only = $splitted_array[0];
    my $l_status = 0;
#print "build_modis_l2p_core_filename:before remove_refined_prefix_from_filename, name_only = $name_only\n";
    ($l_status,$name_only) = remove_refined_prefix_from_filename($name_only);
#print "build_modis_l2p_core_filename:after remove_refined_prefix_from_filename, name_only = $name_only\n";


    #
    # The yyyydoy of the file name is the 1st substring.
    #

    my $yyyy = substr($name_only,1,4);
    my $doy  = substr($name_only,5,3);


    # Check for 'T' in the name.
    if (index($name_only,'T') >= 0) {
        # V20191102T210001
        # 01234567890
        my $month_field = substr($name_only,5,2);
        my $day_field   = substr($name_only,7,2);
    }

    my $hour = substr($name_only,8,2);
    my $min  = substr($name_only,10,2);
    my $sec  = substr($name_only,12,2);

    #
    # The convert the day of year to the month and day.
    #
 
    ($o_year, $o_mm, $o_dd) = convert_to_mm_day($yyyy,$doy);

    # Check for 'T' in the name.  If that is the case, we can get the month, day, hour, minute, and seconds from the name.
    if (index($name_only,'T') >= 1) {  # Note that we have to make sure it is >=1 because Terra starts with T at position 0.
        # V20191102T210001
        # 0123456789012345
        $o_mm = int(substr($name_only,5,2));
        $o_dd = int(substr($name_only,7,2));
        $hour = substr($name_only,10,2);
        $min  = substr($name_only,12,2);
        $sec  = substr($name_only,14,2);
    }

    # Adding leading zero if month is less than October.

    if ($o_mm < 10) {
        $o_mm = "0" . $o_mm;
    }

    # Adding leading zero if day is less than the 10th of the month
    if ($o_dd < 10) {
        $o_dd = "0" . $o_dd;
    }

    #
    # We now have enough to form the returned start time and dates.
    #

#print "modis_parse_filename_for_start_time:splitted_array = @splitted_array\n";
#print "modis_parse_filename_for_start_time:yyyy = $yyyy\n";
#print "modis_parse_filename_for_start_time:doy  = $doy\n";
#print "modis_parse_filename_for_start_time:hour = $hour\n";
#print "modis_parse_filename_for_start_time:min  = $min\n";
#print "modis_parse_filename_for_start_time:sec  = $sec\n";
#print "modis_parse_filename_for_start_time:o_year = $o_year\n";
#print "modis_parse_filename_for_start_time:o_mm   = $o_mm\n";
#print "modis_parse_filename_for_start_time:o_dd   = $o_dd\n";


    $r_start_time_array_element = $yyyy . $o_mm . $o_dd . "T" . $hour . $min . $sec . "Z";
    $r_global_start_date_utc    = $yyyy . '-' . $o_mm . "-" . $o_dd . " UTC";
    $r_global_start_time_utc    = $hour . ':' . $min  . ":" . $sec . " UTC";

#print "modis_parse_filename_for_start_time:r_start_time_array_element = $r_start_time_array_element\n";
#print "modis_parse_filename_for_start_time:r_global_start_date_utc = $r_global_start_date_utc\n";
#print "modis_parse_filename_for_start_time:r_global_start_time_utc = $r_global_start_time_utc\n";
#print "modis_parse_filename_for_start_time:i_filename = $i_filename\n";

    #
    # Close up shop and return.
    #

    return ($r_status,
           $r_start_time_array_element,
           $r_global_start_date_utc,
           $r_global_start_time_utc)
}
