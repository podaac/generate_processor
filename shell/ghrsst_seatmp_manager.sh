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

# Config file
source /app/config/processor_config
set module = "grhsst_seatmp_manager.sh"

# Command line arguments
if ($#argv != 7) then
   echo "You must give exact 7 arguments."
   echo "    num_files_to_process             = (int) batch size"
   echo "    over_write_processed_modis_files = {yes,no} overwrite flag to overwrite if output file already exist."
   echo "    dataset_name                     = {VIIRS} processing stream"
   echo "    processing_type                  = {QUICKLOOK,REFINED} processing type of stream."
   echo "    run_this_jobs_in_parallel        = {yes,no} If set to true, each job will run in a sub process."
   echo "    job_index                        = {0,1...i} Index of data to find job input."
   echo "    job_index                        = {string} String name of JSON File to select input from."
   echo "Example:"
   echo "source ghrsst_viirs_seatmp_manager.sh 25  yes VIIRS QUICKLOOK yes 0 processor_timestamp_list_VIIRS.json"
   echo "source ghrsst_viirs_seatmp_manager.sh 100 yes yes VIIRS REFINED yes 0 processor_timestamp_list_VIIRS.json"
   echo "source ghrsst_viirs_seatmp_manager.sh 2   yes VIIRS QUICKLOOK yes 1 processor_timestamp_list_VIIRS.json"
   echo "source ghrsst_viirs_seatmp_manager.sh 2   yes VIIRS REFINED   yes 3 processor_timestamp_list_VIIRS.json"
   exit(0)
endif

set num_files_to_process             = $argv[1]
set over_write_processed_modis_files = $argv[2]
set dataset_name                     = $argv[3]
set processing_type                  = $argv[4]
set run_this_jobs_in_parallel        = $argv[5]
set job_index                        = $argv[6]
set json_file                        = $argv[7]

# Determine index value
if ($job_index == -235) then
    setenv INDEX $AWS_BATCH_JOB_ARRAY_INDEX;
else
    setenv INDEX $job_index
endif

# Log data about execution of component
echo "$module - INFO: Job identifier: $AWS_BATCH_JOB_ID"
echo "$module - INFO: Job index: $INDEX"
echo "$module - INFO: Json file: $json_file"
if ($dataset_name == "MODIS_A") then
    set dataset = "MODIS Aqua"
else if ($dataset_name == "MODIS_T") then
    set dataset = "MODIS Terra"
else
    set dataset = $dataset_name
endif
echo "$module - INFO: Dataset: $dataset"
echo "$module - INFO: Processing type: $processing_type"
echo "$module - INFO: num_files_to_process[arg] = $num_files_to_process"
echo "$module - INFO: over_write_processed_modis_files[arg] = $over_write_processed_modis_files"
echo "$module - INFO: run_this_jobs_in_parallel[arg] = $run_this_jobs_in_parallel"
echo "$module - INFO: unique_identifier = $RANDOM_NUMBER"

# Make sure the machine we will be pushing the L2P to is alive and well.  
# Ignore if running a test execution and Exit if machine is down.
# Split the environment SEND_MODIS_L2P_SFTP_AUTHENTICATION_INFO with the equal
# sign, then further split by the @ symbol in the value 
# 'test@test.test.test.gov' to get access to the host name.
if ($TEST_EXECUTION == false) then
    set host_to_ping = `printenv | grep SEND_MODIS_L2P_SFTP_AUTHENTICATION_INFO | awk '{split ($0,a,"="); print a[2]}' | awk '{split ($0,b,"@"); print b[2]}'`
    echo "$module - INFO: host_to_ping [$host_to_ping]"
    source $GHRSST_SHELL_LIB_DIRECTORY/pinger.csh $host_to_ping $OPS_MODIS_MONITOR_EMAIL_LIST

    # The exit status of the previous command will be 1 if machine is down.  We exit.
    if ($status == 1) then
    echo "$module - INFO: Something is wrong.  Status of $GHRSST_SHELL_LIB_DIRECTORY/pinger.csh is [$status].  Must exit."
    exit 1
    endif
endif

# Logging.
# The touch command is to create a log file if one does not exist already.
# The >> re-direction of the perl script below requires that the file exist.
set log_filename = "$SEATMP_LOGGING/my_crontab_log_from_ghrsst_${processing_type}_${dataset_name}_{$RANDOM_NUMBER}_seatmp_manager";
echo "$module - INFO: Log filename: $log_filename"
touch $log_filename

# Reset GAPFARMUSEMULTIPROCESSESEXECUTOR to true if desired to process the jobs in parallel.
# The IDL code will figure out how to spawn the jobs based on this variable either sequential
# as a sub processes.
if ($run_this_jobs_in_parallel == "yes") then
    setenv GAPFARMUSEMULTIPROCESSESEXECUTOR true
else 
    setenv GAPFARMUSEMULTIPROCESSESEXECUTOR false 
endif
echo "$module - INFO: Run jobs in parallel: $GAPFARMUSEMULTIPROCESSESEXECUTOR"

# Set the input file name as an environment variable
setenv JSON_FILE $json_file

# The parameters to ghrsst_generic_seatmp_manager.pl Perl script are:
#    num_files_to_process             = (int) batch size
#    over_write_processed_modis_files = {yes,no} over write flag to overwrite if output file already exist.
#    dataset_name                     = {VIIRS} processing stream
#    processing_type                  = {QUICKLOOK,REFINED} processing type of stream.
perl $GHRSST_PERL_LIB_DIRECTORY/ghrsst_seatmp_manager.pl $num_files_to_process $over_write_processed_modis_files $dataset_name $processing_type $job_index | tee $log_filename

# Check exit code

set exit_code=$status
echo "$module - INFO: Exit code: $exit_code"
if ( $exit_code == 0 ) then
    echo "$module - INFO: SUCCESSFUL execution: 'startup_level2_combiners.csh' exiting."
    exit(0)
else
    echo "$module - INFO: FAILED execution: 'startup_level2_combiners.csh' exiting." 
    exit(1)
endif