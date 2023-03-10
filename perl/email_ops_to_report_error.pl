#! /usr/local/bin/perl

#  Copyright 2008, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

#
# Function email an operator of error in the MODIS and L2P Processing.
#
# Assumption:
#
#   1) TBD 
#
#------------------------------------------------------------------------------------------------

# Location of GHRSST PYTHON DIRECTORY
$GHRSST_PYTHON_LIB_DIRECTORY = $ENV{GHRSST_PYTHON_LIB_DIRECTORY};

sub email_ops_to_report_error {
    
    # Get input.
    my $ref_error_message = shift;

    # Required notify input.
    my @l_error_message = @$ref_error_message;
    my $message = join(" ",@l_error_message);
    my $sigevent_type = "ERROR";
    my $sigevent_data = "";

    # Create the system call and execute it
    $python_argument_strings = "-t \"$sigevent_type\" -d \"$message\" -i \"$sigevent_data\"";
    $call_system_command_str = "$GHRSST_PYTHON_LIB_DIRECTORY/notify.py $python_argument_strings";
    system("$call_system_command_str")  == 0 or die "ghrsst_notify_operator: $call_system_command_str failed: $?";

    # Check for errors.
    if ($? == -1) {
        print "ghrsst_notify_operator: system $args[0] < $args[1] failed to execute: $?\n";
    } elsif ($? == 256){
        print "ghrsst_notify_operator: Cannot find file $args[1].\n";
    } elsif ($? == 0){
        print "ghrsst_notify_operator: system $args[0] < $args[1] executed with: $?\n";
        print "ghrsst_notify_operator: Everything is OK.\n";
    } else {
        print "ghrsst_notify_operator: system $args[0] < $args[1] executed with: $?\n";
    }
}