#!/bin/csh
# 
# This is a script used to replace sendmail functionality in Processor
# email_ops_to_report_error.pl as the Docker container installs and uses
# postfix and mailutils.


# # Start postfix
# /etc/init.d/postfix start

# Subject
set subject = "$MACHINE $GENERATE_VERSION Reporting MODIS L2P or MAF Error"

# Email content text file
set mail_content = $EMPTY_EMAIL_LOCATION/email_ops_error_report.txt

# Send mail
mail -r processor@generate.app -s "$subject" $OPS_MODIS_MONITOR_EMAIL_LIST < $mail_content

# # Stop postix
# sleep 5
# /etc/init.d/postfix stop

# Remove email message
rm $EMPTY_EMAIL_LOCATION/email_ops_error_report.txt

# Exit
exit 0