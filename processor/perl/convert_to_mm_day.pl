#  Copyright 2005, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id: convert_to_mm_day.pl,v 1.2 2006/05/30 18:19:38 qchau Exp $

# Make the library functions available.

do "$GHRSST_PERL_LIB_DIRECTORY/is_leap_year.pl";

sub convert_to_mm_day
{
    #
    # Function converts a day of year to month and day.
    #

    # Retrieve the input:

    my $i_year = shift; # Get the first parameter, shift to next
    my $i_doy  = shift; # Get the next parameter, shift to next.

    # Define output.

    my  $o_year = $i_year;
    my  $o_mm = 0;
    my  $o_day = 0;

    #
    # Check for leapness
    # 

    $year_is_leap = is_leap_year($i_year);

#print 'convert_to_mm_day:i_year      = ' . $i_year . "\n";
#print 'convert_to_mm_day:i_doy       = ' . $i_doy . "\n";
#print 'convert_to_mm_day:year_is_leap  = ' . $year_is_leap . "\n";

    my @days = (0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334);
    my @daysleap = (0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335);

    # The month is the first index pass the days array that the doy is greater than.

    my $i = 0;
    my $found = 0;
    my $NUM_MONTHS = 12;

    my $month_index = 0;
    while ($i < $NUM_MONTHS && $found == 0) {
        # Skip the index with value less than doy.

        # Use the appropriate array to compare with i_doy depends if the year is leap.
        if ($year_is_leap == 1) { 
            if ($i_doy > $daysleap[$i]) { 
               $i = $i + 1;
            } else {
                $month_index = $i;
                $found = 1;
            } 

        } else { 
            if ($i_doy > $days[$i]) { 
                $i = $i + 1;
            } else {
                $month_index = $i;
                $found = 1;
            } 
        }
    }

    # If the last value in days array was less than i_doy and we have run
    # out of index in days, then the month is december.

#print "convert_to_mm_day:found = $found\n";

    if ($found == 0) { 
        $o_mm = 12;
        if ($year_is_leap == 1) { 
            $o_day = $i_doy - $daysleap[11];
        } else {
            $o_day = $i_doy - $days[11];
        } 
    } else { 
        # The month_index is the month we were looking for.
        $o_mm = $month_index;
        if ($year_is_leap == 1) { 
            $o_day = $i_doy - $daysleap[$month_index - 1];
        } else {
            $o_day = $i_doy - $days[$month_index - 1];
        } 
    }

#print "convert_to_mm_day:o_year = " . $o_year . "\n";
#print "convert_to_mm_day:o_mm   = " . $o_mm . "\n";
#print "convert_to_mm_day:o_day  = " . $o_day . "\n";

    return ($o_year, $o_mm, $o_day);
}
