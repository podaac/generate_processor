#!/usr/local/bin/perl

#  Copyright 2007, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id: take_directory_snapshot.pl,v 1.3 2007/12/05 19:14:21 qchau Exp $
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

#
# Function take a snapshot of the content of a directory and returns the
# name of file containing one line per file.
#
#   1) A file of zero size is returned if directory is empty or non-existence.
#
#------------------------------------------------------------------------------------------------

do "$GHRSST_PERL_LIB_DIRECTORY/take_filenames_from_directory_snapshot.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/create_random_filename.pl";

sub take_directory_snapshot {

    # Returned status.  Value of 0 means ok, 1 means bad.

    my $r_status = 0;

    # Get input.

    my $input_directory = $_[0]; 
    my $search_string   = $_[1]; 
    my $scratch_area    = $_[2]; 
    my $source_name  = lc($_[3]);      # 'modis' gets special treatment.
    my $num_directory_levels = $_[4];  # A value of 3:year/doy/filename, 4:year/month/day/filename 
    my $sort_flag            = lc($_[5]);  # 'yes' or 'no' 
    my $i_current_time       = $_[6];

    my $debug_module = "take_directory_snapshot:";
    my $debug_mode   = 0;

    if ($debug_mode) {
        print $debug_module . "input_directory $input_directory\n";
        print $debug_module . "search_string $search_string\n";
        print $debug_module . "scratch_area $scratch_area\n";
        print $debug_module . "source_name $source_name\n";
        print $debug_module . "num_directory_levels $num_directory_levels\n";
        print $debug_module . "sort_flag $sort_flag\n";
        print $debug_module . "i_current_time $i_current_time\n";
    }

#    exit(0);

    # Local variables.

    my $YEAR_DOY_FILENAME_LEVELS       = 3;
    my $YEAR_MONTH_DAY_FILENAME_LEVELS = 4;

    my $file_search_directory = "DUMMY";
    my $doy_or_month_search_directory  = "DUMMY";

    # Returned variables:

    my $r_tmp_filelist = create_random_filename(
                                 $i_current_time,("$source_name" . "_" . lc($search_string)),
                                 "scratch_filelist");

    # Create an empty file to start with.
    # File should not exist already.  If it is, print a message and exit.  Doesn't make sense to
    # to continue.

    if (-e $r_tmp_filelist) {
        $file_existed_already = 1;
        print "take_directory_snapshot: ERROR, Scratch file $r_tmp_filelist exist.\n";
        print "Please delete scratch file and re-run script.\n";
        $r_status = 1;
        return($r_status, $r_tmp_filelist);
    } else {
        system("touch $r_tmp_filelist")  == 0
            or die "take_directory_snapshot: Cannot create empty scratch file $r_tmp_filelist: $?";
    }

    # Get the years.  Ignore the CVS and Subversion directories.

    my @the_year_list = readpipe("ls $input_directory | grep -v CVS | grep -v svn");
    if ($debug_mode) {
        print $debug_module . "ls $input_directory | grep -v CVS | grep -v svn" . "\n";
    }
    my $num_years     = @the_year_list;

    #
    # Create a list of files.
    #

    for ($count_year = 0; $count_year < $num_years; $count_year++) {

        #
        # Create a list of day of years.
        #

        chomp($the_year_list[$count_year]);
        $doy_or_month_search_directory = $input_directory . "/$the_year_list[$count_year]/";

        # Skip if not a directory.
        if (!(-d ($doy_or_month_search_directory))) {
#            print "[$doy_or_month_search_directory] is not a directory, skipping.\n";
            next;
        } else {
#            print "[$doy_or_month_search_directory] is indeed a directory continue as normal\n";
        }

        #
        # Get the largest day of year first.  Basically work backward.
        #

        my @the_doy_or_month_list = (); 

        # Only sort the list if processing MODIS data.
        if (index($source_name,"modis") >= 0) {
           @the_doy_or_month_list = readpipe("ls " . $doy_or_month_search_directory . " | grep -v CVS | grep -v svn | sort -r");
        } else {
            @the_doy_or_month_list = readpipe("ls " . $doy_or_month_search_directory . " | grep -v CVS | grep -v svn");
            if ($debug_mode) {
                print $debug_module . "ls " . $doy_or_month_search_directory . " | grep -v CVS | grep -v svn" . "\n";
            }
        }

        my $num_doy_or_months = @the_doy_or_month_list;

        if ($debug_mode) {
            print $debug_module . "num_doy_or_months [$num_doy_or_months]" . "\n";
        }

        my $count_doy_or_month = 0;
        for ($count_doy_or_month = 0; $count_doy_or_month < $num_doy_or_months; $count_doy_or_month++) {
            #
            # For each day of year create a list of files. 
            #

            chomp($the_doy_or_month_list[$count_doy_or_month]);

            $file_search_directory = $input_directory . "/$the_year_list[$count_year]/$the_doy_or_month_list[$count_doy_or_month]/";
            if ($debug_mode) {
                print $debug_module . "file_search_directory [$file_search_directory]" . "\n";
            }

            # Skip if not a directory.
            if (!(-d ($file_search_directory))) {
#                print "[$file_search_directory] is not a directory, skipping.\n";
                next;
            } else {
#                print "[$file_search_directory] is indeed a directory continue as normal\n";
            }

            # If the number of directory levels is (4:year/month/day/filename), that means we have
            # search one more level to get to the file names.

            my $directory_to_search = $file_search_directory;  # Start with file_search_directory.
            if ($debug_mode) {
                print $debug_module . "num_directory_levels [$num_directory_levels]" . "\n";
                print $debug_module . "YEAR_MONTH_DAY_FILENAME_LEVELS [$YEAR_MONTH_DAY_FILENAME_LEVELS]" . "\n";
            }

            if ($num_directory_levels == $YEAR_MONTH_DAY_FILENAME_LEVELS) {

                # Get the list of months.
                my @days_filelist= readpipe("ls $file_search_directory");
                my $count_day = 0;
                my $num_days  = @days_filelist;

                # For each day, get the names beneath that month.

                for ($count_day = 0; $count_day < $num_days; $count_day++) {
                    chomp($days_filelist[$count_day]);  # Remove carriage return.

                    # Add the day to the end of the file_search_directory since must search day.

                    $directory_to_search = $file_search_directory . '/'. $days_filelist[$count_day];

                    if ($debug_mode) {
                        print $debug_module . "directory_to_search $directory_to_search" . "\n";
                    }
                    # Get the name of files beneath this month and append to scratch directory.

                    $l_status = take_filenames_from_directory_snapshot(
                                $directory_to_search,
                                $search_string  ,
                                $the_year_list[$count_year],
                                $the_doy_or_month_list[$count_doy_or_month],
                                $source_name,
                                $sort_flag,
                                $r_tmp_filelist);
                }

            } else {
                # We assume that num_directory_levels is the same as YEAR_DOY_FILENAME_LEVELS
                $l_status = take_filenames_from_directory_snapshot(
                                $directory_to_search,
                                $search_string  ,
                                $the_year_list[$count_year],
                                $the_doy_or_month_list[$count_doy_or_month],
                                $source_name,
                                $sort_flag,
                                $r_tmp_filelist);
            }
        } # for ($count_doy_or_month = 0; $count_doy_or_month < $num_doy_or_months; $count_doy_or_month++)
    } # for ($count_year = 0; $count_year < $num_years; $count_year++)
    return($r_status, $r_tmp_filelist);
}

# Main program calls the subroutine defined above.
my $debug_module = "take_directory_snapshot:";
my $module_name  = "take_directory_snapshot.pl";
    
if (index($0,$module_name) >= 0)
{   
    # Because we are running this script for unit test, we have to call the next 3 statements explicitly to define the variable GHRSST_PERL_LIB_DIRECTORY
    # and execute the next 2 scripts.  Without these 3 lines, this script will complain about not defined funtion:
    # "Undefined subroutine &main::create_random_filename called at take_directory_snapshot.pl line 63"

    $GHRSST_PERL_LIB_DIRECTORY = $ENV{GHRSST_PERL_LIB_DIRECTORY};
    do "$GHRSST_PERL_LIB_DIRECTORY/take_filenames_from_directory_snapshot.pl";
    do "$GHRSST_PERL_LIB_DIRECTORY/create_random_filename.pl";

    my $input_directory ="/data/dev/scratch/qchau/scratch/combiner_output/from_netcdf_input_files_from_trunk_code_into_netcdf/viirs/";
    my $search_string  ="V";
    my $scratch_area  ="/home/qchau/scratch";
    my $source_name  ="refined_viirs";
    my $num_directory_levels  = 3;
    my $sort_flag  ="no";
    #my $i_current_time  ="1475001063";
    my $i_current_time  ="1474997057";

    #unlink("/home/qchau/scratch/current_logs/__1475001063.refined_viirs_v/tmp_scratch_filelist");
    print "unlink('/home/qchau/scratch/current_logs/__1474997057.refined_viirs_v/tmp_scratch_filelist')\n";
    unlink("/home/qchau/scratch/current_logs/__1474997057.refined_viirs_v/tmp_scratch_filelist");

    my ($r_status,$r_tmp_filelist) = take_directory_snapshot($input_directory,
                                           $search_string,
                                           $scratch_area,
                                           $source_name,
                                           $num_directory_levels,
                                           $sort_flag,
                                           $i_current_time);

    print "input_directory $input_directory\n";
    print "cat -n $r_tmp_filelist\n";
    system("cat -n $r_tmp_filelist");

    print "\n";
    print "unlink('/home/qchau/scratch/current_logs/__1474997057.refined_viirs_v/tmp_scratch_filelist')\n";
    unlink("/home/qchau/scratch/current_logs/__1474997057.refined_viirs_v/tmp_scratch_filelist");
    print "unlink('/home/qchau/scratch/current_logs/__1474997057.refined_modis_a/tmp_scratch_filelist')\n";
    unlink("/home/qchau/scratch/current_logs/__1474997057.refined_modis_a/tmp_scratch_filelist");
    my $input_directory ="/data/dev/scratch/qchau/scratch/combiner_output/from_netcdf_input_files_from_trunk_code_into_netcdf/aqua";
    my $search_string  ="A";
    my $scratch_area  ="/home/qchau/scratch";
    my $source_name  ="refined_modis";
    my $num_directory_levels  = 3;
    my $sort_flag  ="no";
    #my $i_current_time  ="1475001063";
    my $i_current_time  ="1474997057";

    my ($r_status,$r_tmp_filelist) = take_directory_snapshot($input_directory,
                                           $search_string,
                                           $scratch_area,
                                           $source_name,
                                           $num_directory_levels,
                                           $sort_flag,
                                           $i_current_time);

    print "input_directory $input_directory\n";
    print "cat -n $r_tmp_filelist\n";
    system("cat -n $r_tmp_filelist");


    print "unlink($r_tmp_filelist)\n";
    unlink($r_tmp_filelist);
}