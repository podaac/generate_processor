# processor

The processor processes the files produced from the Processor to create 3 datasets depending on the input parameters: 
1. MODIS_T-JPL-L2P-v2019.0;	https://podaac.jpl.nasa.gov/dataset/MODIS_T-JPL-L2P-v2019.0
2. MODIS_A-JPL-L2P-v2019.0;	https://podaac.jpl.nasa.gov/dataset/MODIS_A-JPL-L2P-v2019.0
3. VIIRS_NPP-JPL-L2P-v2016.2; https://podaac.jpl.nasa.gov/dataset/VIIRS_NPP-JPL-L2P-v2016.2

Top-level Generate repo: https://github.com/podaac/generate

## pre-requisites to building

A compressed IDL installer (idlxxx-linux.tar.gz) placed in the `processor/idl/install` directory.

An IDL license for executing IDL within the Docker container. TA license file obtained from the vendor ending in `.dat` should be placed in the `idl/install` directory.

The following IDL files must be compiled to `.sav` files:
- error_log_writer_helper_pro.sav
- is_granule_night_or_day.sav
- process_modis_datasets.sav
- idl_one_process_executor.sav
- idl_many_jobs_one_process_executor.sav
- idl_monitor_jobs_completion.sav

To compile IDL files:
1. `cd` to the IDL directory (`processor/idl`).
2. Execute `idl`.
3. Inside the IDL command prompt, execute: `.FULL_RESET_SESSION`
4. Inside the IDL command prompt, execute: `.COMPILE {file name without '.pro' extension}` 
    1. Example: `.COMPILE process_modis_datasets`
5. Inside the IDL command prompt, execute: `RESOLVE_ALL`
6. Inside the IDL command prompt, execute: `SAVE, /ROUTINES, FILENAME='{file name}.sav'`
    1. Example: `SAVE, /ROUTINES, FILENAME='process_modis_datasets.sav'`


### compile: error_log_writer_helper_pro.sav

```bash
.FULL_RESET_SESSION 
.COMPILE ghrsst_base_error_logger
.COMPILE actualize_directory
.COMPILE lock_named_resource
.COMPILE release_named_resource
.COMPILE ghrsst_error_logger
.COMPILE create_error_logger
.COMPILE error_log_writer_helper_pro
RESOLVE_ALL
SAVE,/ROUTINES,FILENAME='error_log_writer_helper_pro.sav'
```

### compile is_granule_night_or_day.sav
```bash
.FULL_RESET_SESSION   
.COMPILE ghrsst_base_error_logger   
.COMPILE actualize_directory
.COMPILE lock_named_resource
.COMPILE release_named_resource
.COMPILE ghrsst_error_logger
.COMPILE create_error_logger
.COMPILE read_netcdf_global_attribute
.COMPILE wrapper_ghrsst_notify_operator
.COMPILE verify_returned_status
.COMPILE read_hdf_global_attribute
.COMPILE convert_to_ascii_string
.COMPILE is_granule_night_or_day
RESOLVE_ALL
SAVE,/ROUTINES,FILENAME='is_granule_night_or_day.sav'
```

### compile idl_monitor_jobs_completion.sav
```bash
.FULL_RESET_SESSION 
.COMPILE ghrsst_base_error_logger 
.COMPILE ghrsst_error_logger
.COMPILE create_error_logger
.COMPILE error_log_writer_helper_pro
.COMPILE idl_email_ops_to_report_error
.COMPILE idl_monitor_jobs_completion
RESOLVE_ALL
SAVE,/ROUTINES,FILENAME='idl_monitor_jobs_completion.sav'
```


### compile convert_modis_from_netcdf_to_gds2_netcdf
```bash
.FULL_RESET_SESSION 
.COMPILE ghrsst_error_logger
.COMPILE convert_modis_from_netcdf_to_gds2_netcdf
RESOLVE_ALL
SAVE,/ROUTINES,FILENAME='convert_modis_from_netcdf_to_gds2_netcdf.sav'
```

### compile idl_one_process_executor.sav
```bash
.FULL_RESET_SESSION      
.COMPILE ghrsst_base_error_logger
.COMPILE ghrsst_processing_logger
.COMPILE ghrsst_error_logger
.COMPILE compress_and_ftp_push_modis_L2P_core_datasets
.COMPILE generate_modis_l2p_core_dataset
.COMPILE idl_one_process_executor
RESOLVE_ALL
SAVE,/ROUTINES,FILENAME='idl_one_process_executor.sav'
```

### idl_many_jobs_one_process_executor.sav
```bash
.FULL_RESET_SESSION      
.COMPILE ghrsst_processing_logger
.COMPILE ghrsst_error_logger
.COMPILE ghrsst_base_error_logger
.COMPILE generate_modis_l2p_core_dataset
.COMPILE idl_many_jobs_one_process_executor
RESOLVE_ALL
SAVE,/ROUTINES,FILENAME='idl_many_jobs_one_process_executor.sav'
```


### compile: process_modis_datasets.sav

```bash
.FULL_RESET_SESSION
.COMPILE uncompress_one_modis_dataset
.COMPILE ghrsst_base_error_logger
.COMPILE actualize_directory
.COMPILE lock_named_resource
.COMPILE release_named_resource
.COMPILE ghrsst_processing_logger
.COMPILE create_processing_logger
.COMPILE write_to_processing_log
.COMPILE read_netcdf_global_attribute
.COMPILE read_hdf_global_attribute
.COMPILE convert_to_ascii_string
.COMPILE rename_output_file_to_gds2_format_without_file_move
.COMPILE verify_returned_status
.COMPILE ghrsst_error_logger
.COMPILE create_error_logger
.COMPILE error_log_writer
.COMPILE clean_up_modis_processing
.COMPILE erase_current_job
.COMPILE wrapper_ghrsst_notify_operator
.COMPILE string_to_number_conversion
.COMPILE read_long_variables_from_netcdf_file
.COMPILE read_float_variables_from_netcdf_file
.COMPILE calday
.COMPILE get_seconds_since_1981
.COMPILE write_modis_global_attributes
.COMPILE create_modis_cdf_file
.COMPILE read_gds1_netcdf_one_variable
.COMPILE find_netcdf_variable_attribute_info
.COMPILE convert_int_type_to_char_type
.COMPILE unmask
.COMPILE get_netcdf_variable_attribute_info
.COMPILE identify_bad_scan_lines
.COMPILE correct_bad_scan_lines_with_good_missing_values
.COMPILE remove_dateline_discontinuity
.COMPILE clean_up_modis_processing
.COMPILE perform_spline_fit_on_controlled_points
.COMPILE convert_to_negative_180_positive_180
.COMPILE write_modis_lat_lon_variable
.COMPILE write_netcdf_variable
.COMPILE write_modis_data_variable
.COMPILE perform_proximity_confidence_mapping
.COMPILE convert_to_signed_byte
.COMPILE apply_scaling_from_short_to_byte
.COMPILE apply_scaling_from_short_to_byte_for_stdv_variable
.COMPILE write_barebone_modis_data_variable
.COMPILE is_netcdf_variable_in_file
.COMPILE convert_additional_night_netcdf_variables
.COMPILE fill_bad_scan_lines_with_missing_value
.COMPILE convert_additional_day_netcdf_variables
.COMPILE append_ancillary_data_variable
.COMPILE convert_modis_from_netcdf_to_netcdf
.COMPILE read_hdf_global_attribute
.COMPILE get_hdf_variable_attributes
.COMPILE read_control_points_variable
.COMPILE read_hdf_l2_flag_variable
.COMPILE read_hdf_variable
.COMPILE read_one_dim_hdf_variable
.COMPILE is_hdf_variable_in_file
.COMPILE convert_additional_night_hdf_variables
.COMPILE convert_additional_day_hdf_variables
.COMPILE convert_modis_from_hdf_to_netcdf
.COMPILE read_long_variables_from_netcdf_file
.COMPILE validate_time_field
.COMPILE julday_to_seconds_since_1981
.COMPILE echo_message_to_screen
.COMPILE read_character_variables_from_netcdf_file
.COMPILE create_viirs_gds2_cdf_file
.COMPILE perform_spline_fit_on_controlled_points_with_improvements
.COMPILE identify_bad_scan_lines_fast
.COMPILE remove_dateline_discontinuity_fast
.COMPILE convert_to_negative_180_positive_180_fast
.COMPILE get_coverage_content_type
.COMPILE write_gds2_geographic_variable
.COMPILE write_gds2_normal_variable
.COMPILE write_gds2_variable
.COMPILE convert_additional_night_viirs_netcdf_variables_to_gds2
.COMPILE convert_additional_day_viirs_netcdf_variables_to_gds2
.COMPILE append_ancillary_data_variable_gds2
.COMPILE write_optional_gds2_wind_speed_variable
.COMPILE write_optional_gds2_dt_analysis_variable
.COMPILE convert_viirs_from_netcdf_to_gds2_netcdf
.COMPILE create_modis_gds2_cdf_file
.COMPILE convert_additional_night_netcdf_variables_to_gds2
.COMPILE convert_additional_day_netcdf_variables_to_gds2
.COMPILE convert_modis_from_netcdf_to_gds2_netcdf
.COMPILE read_float_variables_from_hdf_file
.COMPILE read_character_variables_from_hdf_file
.COMPILE convert_additional_night_hdf_variables_to_gds2
.COMPILE convert_additional_day_hdf_variables_to_gds2
.COMPILE convert_modis_from_hdf_to_gds2_netcdf
.COMPILE rename_output_file_to_gds1_format
.COMPILE rename_output_file_to_gds2_format
.COMPILE erase_one_staged_dataset
.COMPILE quarantine_one_staged_dataset
.COMPILE lock_processed_file_registry
.COMPILE release_processed_file_registry
.COMPILE append_to_L2P_processed_file_registry
.COMPILE perform_modis_cleanup_failed_processing
.COMPILE make_modisl2p_meta
.COMPILE convert_modis_and_make_meta
.COMPILE perform_compression_on_l2p_file
.COMPILE create_checksum_file
.COMPILE modis_checksums_verifier
.COMPILE verify_md5sum_value
.COMPILE create_unique_links_to_modis_l2p_files
.COMPILE modis_ftp_pusher
.COMPILE compress_and_ftp_push_modis_L2P_core_datasets
.COMPILE build_checksum_and_ftp_push_modis_L2P_core_datasets
.COMPILE is_variable_a_number
.COMPILE validate_day_of_year_field
.COMPILE write_gds2_modis_global_attributes
.COMPILE generate_modis_l2p_core_dataset
.COMPILE register_current_job
.COMPILE build_modis_processing_jobs
.COMPILE idl_email_ops_to_report_error
.COMPILE idl_one_process_executor
.COMPILE idl_many_jobs_one_process_executor
.COMPILE idl_monitor_jobs_completion
.COMPILE idl_multi_processes_executor
.COMPILE lock_idl_license_manager
.COMPILE how_many_runtime_licenses_available
.COMPILE release_idl_license_manager
.COMPILE get_runtime_licenses_available
.COMPILE lock_idl_license_manager
.COMPILE release_idl_license_manager
.COMPILE verify_taskdl_worker_started
.COMPILE farm_connect_taskdl
.COMPILE farm_submit_tasks
.COMPILE farm_disconnect_taskdl
.COMPILE farm_idl_jobs_to_taskdl
.COMPILE execute_idl_processing_jobs
.COMPILE erase_staged_datasets
.COMPILE process_modis_datasets

RESOLVE_ALL
SAVE,/ROUTINES,FILENAME='process_modis_datasets.sav'
```

## build command

`docker build --build-arg IDL_INSTALLER=idlxxx-linux.tar.gz --build-arg IDL_VERSION=idlxx --tag processor:0.1 .`

Build arguments:
- LICENSE_SERVER: The IP address of an IDL license server.
- IDL_INSTALLER: The file name of the IDL installer.
- IDL_VERSION: The version of IDL that will be installed.

## execute command

MODIS A: 
`docker run --name gen-proc -v /processor/input:/data/input -v /processor/output:/data/output -v /processor/logs:/data/logs -v /processor/scratch:/data/scratch -v /usr/local:/usr/local processor:0.1 15 yes MODIS_A QUICKLOOK no`
`docker run --name gen-proc -v /processor/input:/data/input -v /processor/output:/data/output -v /processor/logs:/data/logs -v /processor/scratch:/data/scratch -v /usr/local:/usr/local processor:0.1 100 yes MODIS_A REFINED no`

MODIS T: 
`docker run --name gen-proc -v /processor/input:/data/input -v /processor/output:/data/output -v /processor/logs:/data/logs -v /processor/scratch:/data/scratch -v /usr/local:/usr/local processor:0.1 15 yes MODIS_T QUICKLOOK no`
`docker run --name gen-proc -v /processor/input:/data/input -v /processor/output:/data/output -v /processor/logs:/data/logs -v /processor/scratch:/data/scratch -v /usr/local:/usr/local processor:0.1 100 yes MODIS_T REFINED no`

VIIRS: 
`docker run --name gen-proc -v /processor/input:/data/input -v /processor/output:/data/output -v /processor/logs:/data/logs -v /processor/scratch:/data/scratch -v /usr/local:/usr/local processor:0.1 50 yes VIIRS QUICKLOOK no`
`docker run --name gen-proc -v /processor/input:/data/input -v /processor/output:/data/output -v /processor/logs:/data/logs -v /processor/scratch:/data/scratch -v /usr/local:/usr/local processor:0.1 50 yes VIIRS REFINED no`

**NOTES**
- In order for the commands to execute the `/processor/` directories will need to point to actual directories on the system.
- IDL is installed and configured by the Dockerfile.
- The Procesor component currently uses postfix and mailutils to send some notifications via email. It may make sense to move the mail functionality out of the container and let the Generate cloud infrastructure handling email notifications.

## aws infrastructure

The processor includes the following AWS services:
- AWS Batch job definition.
- CloudWatch log group.
- Elastic Container Registry repository.

## terraform 

Deploys AWS infrastructure and stores state in an S3 backend using a DynamoDB table for locking.

To deploy:
1. Edit `terraform.tfvars` for environment to deploy to.
2. Edit `terraform_conf/backed-{prefix}.conf` for environment deploy.
3. Initialize terraform: `terraform init -backend-config=terraform_conf/backend-{prefix}.conf`
4. Plan terraform modifications: `terraform plan -out=tfplan`
5. Apply terraform modifications: `terraform apply tfplan`

`{prefix}` is the account or environment name.