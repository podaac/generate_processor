sub is_leap_year
{
        # link up the local vars to the one passed in (through @_)
        my $the_year = $_[0];

        #  A year is a leap year if it is
        #                       divisible by 4
        #                       but if it is divisible by 100 then it isn't
        #                       unless it is divisible by 400 also
        #
        if (($the_year % 4) == 0)
        # divisible by 4
        {
                if (($the_year % 100) == 0)
                # divisible by 100, 4
                {
                        if (($the_year % 400) == 0)
                        {
                                # divisible by 400, 100, and 4
                                return 1; # it is a leap year
                        }
                        else
                        # divisible by 100, 4
                        {
                                return 0; # not a leap year
                        }
                }
                else
                # divisible by 4
                {
                        return 1; # it is a leap year
                }
        }
        else
        # not divisible by 4
        {
                return 0; #not a leap year
        }
}

