#!/bin/perl
#/usr/local/bin/perl

#  Copyright 2012, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
#
# Function that writes message to final log message file.
#
#------------------------------------------------------------------------------------------------

sub write_final_log {

    my $message = shift;

    open(my $fh, '>>', $ENV{'FINAL_LOG_MESSAGE'}) or die "Could not open file '$ENV{'FINAL_LOG_MESSAGE'}' $!";
    print $fh "$message\n";
    close $fh;

}