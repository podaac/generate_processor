#!/usr/local/bin/perl

#  Copyright 2007, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id: take_filenames_from_directory_snapshot.pl,v 1.4 2007/12/05 19:14:21 qchau Exp $
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

#
# Function build a file given the name of the directory, a search string and returned the
# name of file containing one line per file.
#
# Assumption:
#
#   1) The directory structure is either:
#
#        year
#          doy
#           filename
#
#      or
#
#        year
#          month 
#           day
#             filename
#
#
#   2) A file of zero size is returned if directory is empty or non-existence.
#
#------------------------------------------------------------------------------------------------

do "$GHRSST_PERL_LIB_DIRECTORY/filter_for_night_datasets.pl";

sub take_filenames_from_directory_snapshot {

    # Returned status.  Value of 0 means ok, 1 means bad.

    my $r_status = 0;

    # Get input.

    my $file_search_directory = $_[0]; 
    my $search_string   = $_[1]; 
    my $the_year        = $_[2];
    my $the_day_of_year = $_[3];
    my $source_name     = lc($_[4]);      # 'modis' gets special treatment.
    my $sort_flag          = $_[5]; # either yes or no
    my $filename_to_return = $_[6];

    my $debug_module = "take_filenames_from_directory_snapshot:";
    my $debug_mode   = 0;

    if ($debug_mode) {
        print $debug_module . "file_search_directory $file_search_directory\n";
        print $debug_module . "search_string $search_string\n";
        print $debug_module . "the_year $the_year\n";
        print $debug_module . "the_day_of_year $the_day_of_year\n";
        print $debug_module . "source_name $source_name\n";
        print $debug_module . "sort_flag $sort_flag\n";
        print $debug_module . "filename_to_return $filename_to_return\n";
    }

    my @one_filelist=(); 

    #if (index($source_name,"modis") >= 0) { 
    if ((index($source_name,"modis") >= 0) or (index($source_name,"viirs") >= 0)) { 
        # MODIS instrument has the A or T and as prefix and then the year
        #       thus we look for files with $search_string$the_year_list[$count_year]
#print "ls " . $file_search_directory . " | grep $search_string$the_year$the_day_of_year" . "\n";
        if ($debug_mode) {
            print $debug_module . "source_name is modis or viirs\n";
            print $debug_module . "readpipe:ls " . $file_search_directory . " | grep $search_string$the_year$the_day_of_year | grep -v md5\n";
        }
        my @unfiltered_filelist = readpipe("ls " . $file_search_directory . " | grep $search_string$the_year$the_day_of_year | grep -v md5");

        # We also look for the alternate names that has yyyymmdd
        my ($o_year, $o_mm, $o_dd) = convert_to_mm_day($the_year,$the_day_of_year);
        my $mm_as_string  = sprintf("%02d",$o_mm);
        my $day_as_string = sprintf("%02d",$o_dd);
        my $alternate_search_string = "$search_string$the_year$mm_as_string$day_as_string";
        my @alternate_filelist = readpipe("ls " . $file_search_directory . " | grep $alternate_search_string | grep -v md5");
        push(@unfiltered_filelist,@alternate_filelist);

        # Since the unfiltered_filelist can have files of the same time frame
        # one for day and one for night, we drop the day one. 
       
        #@one_filelist = filter_for_night_datasets(\@unfiltered_filelist);
        @one_filelist = @unfiltered_filelist;

    } else {
        # The data type aerosol_optical_depth requires that the sorting is done column 37 
        # of the file name.

        if ($sort_flag eq 'yes') {
            if ($debug_mode) {
                print $debug_module . "source_name not modis sort_flag is yes\n";
                print $debug_module . "readpipe:ls $file_search_directory | grep -v 0240_02400 | grep -v dup | grep -v _du | grep -v _sm | grep -v _su | grep -e RL -e NL | sort -k 1.37\n";
            }

            @one_filelist= readpipe("ls $file_search_directory | grep -v 0240_02400 | grep -v dup | grep -v _du | grep -v _sm | grep -v _su | grep -e RL -e NL | sort -k 1.37");

        } else {
            # Other instrument, perform the regular grep, ignore the duplicates.
        @one_filelist = readpipe("ls " . $file_search_directory . " | grep $search_string | grep -v dup");

        if ($debug_mode) {
            print $debug_module . "source_name not modis sort_flag not yes\n";
            print $debug_module . "ls " . $file_search_directory . " | grep $search_string | grep -v dup" . "\n";
        }
       }
    }

    my $num_files = @one_filelist;
    my @list_with_full_directory = "";

    # Prepend the file with the full directory.

    if ($debug_mode) {
        print $debug_module . "num_files $num_files\n" ;
    }
    for ($file_index = 0; $file_index < $num_files; $file_index++) {
        chomp($one_filelist[$file_index]);
        $list_with_full_directory[$file_index] = "$file_search_directory/$one_filelist[$file_index]\n";
        if ($debug_mode) {
            print $debug_module . "append_to_list_with_full_directory: $file_search_directory/$one_filelist[$file_index]\n" 
        }
    }

    open (FH, ">> $filename_to_return")
        or die "take_filenames_from_directory_snapshot:Can't open $filename_to_return for writing: $!";

    print FH @list_with_full_directory; 

    close (FH);
    return($r_status);
}

# Main program calls the subroutine defined above.
my $debug_module = "take_filenames_from_directory_snapshot:";
my $module_name  = "take_filenames_from_directory_snapshot.pl";

if (index($0,$module_name) >= 0)
{
    my $log_directory  = "/home/qchau/scratch/current_logs/__1474997057.refined_viirs_v";

    my $file_search_directory = "/data/dev/scratch/qchau/scratch/combiner_output/from_netcdf_input_files_from_trunk_code_into_netcdf/viirs//2016/001/";
    my $search_string         = "V";
    my $the_year              = "2016";
    my $the_day_of_year       = "001";
    my $source_name           = "refined_viirs";
    my $sort_flag             = "no";
    my $filename_to_return = $log_directory . "/tmp_scratch_filelist";

    # Create a directory so we can write to it.
    print $debug_module . "mkdir($log_directory)\n";
    mkdir($log_directory);
    print $debug_module . "unlink($filename_to_return)\n";
    unlink($filename_to_return);

    my $r_status = take_filenames_from_directory_snapshot($file_search_directory,
                                                          $search_string,
                                                          $the_year,
                                                          $the_day_of_year,
                                                          $source_name,
                                                          $sort_flag,
                                                          $filename_to_return);

    print $debug_module . "r_status [$r_status]\n";
    print $debug_module . "filename_to_return [$filename_to_return]\n";
    print $debug_module . "cat -n $filename_to_return\n";
    system("cat -n $filename_to_return");
    print $debug_module . "file_search_directory $file_search_directory\n";

    print "\n";

    # Call take_filenames_from_directory_snapshot() again with source_name to not include viirs.
    print $debug_module . "unlink($filename_to_return)\n";
    unlink($filename_to_return);
    rmdir($log_directory);

    my $source_name           = "refined_somethingelse";
    my $sort_flag             = "no";
    mkdir($log_directory);
    my $r_status = take_filenames_from_directory_snapshot($file_search_directory,
                                                          $search_string,
                                                          $the_year,
                                                          $the_day_of_year,
                                                          $source_name,
                                                          $sort_flag,
                                                          $filename_to_return);

    print $debug_module . "r_status [$r_status]\n";
    print $debug_module . "filename_to_return [$filename_to_return]\n";
    print $debug_module . "cat -n $filename_to_return\n";
    system("cat -n $filename_to_return");
    print $debug_module . "file_search_directory $file_search_directory\n";
    print $debug_module . "unlink($filename_to_return)\n";
    unlink($filename_to_return);
    print  $debug_module ."rmdir($log_directory)\n";
    rmdir($log_directory);

    print "\n";

    # Call take_filenames_from_directory_snapshot() again with source_name to include modis and different directory.
    print $debug_module . "unlink($filename_to_return)\n";
    unlink($filename_to_return);
    my $file_search_directory = "/data/dev/scratch/qchau/scratch/combiner_output/from_netcdf_input_files_from_trunk_code_into_netcdf/aqua/2015/215";
    my $search_string         = "A";
    my $the_year              = "2015";
    my $the_day_of_year       = "215";
    my $source_name           = "refined_modis";
    my $sort_flag             = "no";

    my $log_directory  = "/home/qchau/scratch/current_logs/__1474997057.refined_modis_a";
    my $filename_to_return = $log_directory . "/tmp_scratch_filelist";
    mkdir($log_directory);

    my $r_status = take_filenames_from_directory_snapshot($file_search_directory,
                                                          $search_string,
                                                          $the_year,
                                                          $the_day_of_year,
                                                          $source_name,
                                                          $sort_flag,
                                                          $filename_to_return);

    print $debug_module . "r_status [$r_status]\n";
    print $debug_module . "filename_to_return [$filename_to_return]\n";
    print $debug_module . "cat -n $filename_to_return\n";
    system("cat -n $filename_to_return");
    print $debug_module . "file_search_directory $file_search_directory\n";
    print "unlink($filename_to_return)\n";
    unlink($filename_to_return);
    rmdir($log_directory);
}
1;
