#!/bin/bash
#
# Script to download required IDL installer and license file.
#
# Command line arguments:
# [1] s3_bucket: URI of S3 bucket to get files from
# 
# Example usage: ./deploy-idl.sh "s3://bucket"

S3_BUCKET=$1
ROOT_PATH="$PWD"

aws s3 cp $S3_BUCKET/idl882-linux.tar.gz $ROOT_PATH/idl/install/idl882-linux.tar.gz
aws s3 cp $S3_BUCKET/sintegration_lic_server.dat $ROOT_PATH/idl/install/lic_server.dat
