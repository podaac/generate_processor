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