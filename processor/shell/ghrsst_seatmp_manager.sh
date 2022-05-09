#!/bin/csh
#
# C-shell script to start the processing script.
#
# The parameters to this script are;
#
#    num_files_to_process             = (int) batch size
#    over_write_processed_modis_files = {yes,no} overwrite flag to overwrite if output file already exist.
#    dataset_name                     = {VIIRS} processing stream
#    processing_type                  = {QUICKLOOK,REFINED} processing type of stream.
#    run_this_jobs_in_parallel        = {yes,no} If set to true, each job will run in a sub process.

# Command line arguments
if ($#argv != 5) then
   echo "You must give exact 5 arguments."
   echo "    num_files_to_process             = (int) batch size"
   echo "    over_write_processed_modis_files = {yes,no} overwrite flag to overwrite if output file already exist."
   echo "    dataset_name                     = {VIIRS} processing stream"
   echo "    processing_type                  = {QUICKLOOK,REFINED} processing type of stream."
   echo "    run_this_jobs_in_parallel        = {yes,no} If set to true, each job will run in a sub process."
   echo "Example:"
   echo "source ghrsst_viirs_seatmp_manager.sh 25  yes VIIRS QUICKLOOK yes"
   echo "source ghrsst_viirs_seatmp_manager.sh 100 yes yes VIIRS REFINED yes"
   echo "source ghrsst_viirs_seatmp_manager.sh 2   yes VIIRS QUICKLOOK yes"
   echo "source ghrsst_viirs_seatmp_manager.sh 2   yes VIIRS REFINED   yes"
   exit(0)
endif

set num_files_to_process             = $argv[1]
set over_write_processed_modis_files = $argv[2]
set dataset_name                     = $argv[3]
set processing_type                  = $argv[4]
set run_this_jobs_in_parallel        = $argv[5]

echo "num_files_to_process             = $num_files_to_process"
echo "over_write_processed_modis_files = $over_write_processed_modis_files"
echo "dataset_name                     = $dataset_name"
echo "processing_type                  = $processing_type"
echo "run_this_jobs_in_parallel        = $run_this_jobs_in_parallel"

# Config file
source $HOME/generate/workspace/generate/processor/config/processor_config

# Make sure the machine we will be pushing the L2P to is alive and well.  
# Ignore if running a test execution and Exit if machine is down.
# Split the environment SEND_MODIS_L2P_SFTP_AUTHENTICATION_INFO with the equal
# sign, then further split by the @ symbol in the value 
# 'test@test.test.test.gov' to get access to the host name.
if ($TEST_EXECUTION == false) then
    set host_to_ping = `printenv | grep SEND_MODIS_L2P_SFTP_AUTHENTICATION_INFO | awk '{split ($0,a,"="); print a[2]}' | awk '{split ($0,b,"@"); print b[2]}'`
    echo "host_to_ping [$host_to_ping]"
    source $GHRSST_SHELL_LIB_DIRECTORY/pinger.csh $host_to_ping $OPS_MODIS_MONITOR_EMAIL_LIST

    # The exit status of the previous command will be 1 if machine is down.  We exit.
    if ($status == 1) then
    echo "Something is wrong.  Status of $GHRSST_SHELL_LIB_DIRECTORY/pinger.csh is [$status].  Must exit."
    exit 1
    endif
endif

# Logging.
# The touch command is to create a log file if one does not exist already.
# The >> re-direction of the perl script below requires that the file exist.
set log_filename = "$SEATMP_LOGGING/my_crontab_log_from_ghrsst_${processing_type}_${dataset_name}_seatmp_manager";
echo "touch $log_filename"
touch $log_filename

# Reset GAPFARMUSEMULTIPROCESSESEXECUTOR to true if desired to process the jobs in parallel.
# The IDL code will figure out how to spawn the jobs based on this variable either sequential
# as a sub processes.
if ($run_this_jobs_in_parallel == "yes") then
    setenv GAPFARMUSEMULTIPROCESSESEXECUTOR true
else 
    setenv GAPFARMUSEMULTIPROCESSESEXECUTOR false 
endif
echo "GAPFARMUSEMULTIPROCESSESEXECUTOR $GAPFARMUSEMULTIPROCESSESEXECUTOR"

# The parameters to ghrsst_generic_seatmp_manager.pl Perl script are:
#    num_files_to_process             = (int) batch size
#    over_write_processed_modis_files = {yes,no} over write flag to overwrite if output file already exist.
#    dataset_name                     = {VIIRS} processing stream
#    processing_type                  = {QUICKLOOK,REFINED} processing type of stream.
perl $GHRSST_PERL_LIB_DIRECTORY/ghrsst_seatmp_manager.pl $num_files_to_process $over_write_processed_modis_files $dataset_name $processing_type >> $log_filename