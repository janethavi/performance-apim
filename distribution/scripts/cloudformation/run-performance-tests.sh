#!/bin/bash -e
# Copyright (c) 2018, WSO2 Inc. (http://wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# ----------------------------------------------------------------------------
# Run performance tests on AWS Cloudformation Stacks
# ----------------------------------------------------------------------------

export script_name="$0"
export script_dir=$(dirname "$0")

export wso2am_distribution=""
export mysql_connector_jar=""
export wso2am_ec2_instance_type=""
export wso2am_rds_db_instance_class=""

export aws_cloudformation_template_filename="apim_perf_test_cfn.yaml"
export application_name="WSO2 API Manager"
export ec2_instance_name="wso2am"
export metrics_file_prefix="apim"
export run_performance_tests_script_name="run-performance-tests.sh"

function usageCommand() {
    echo "-A <wso2am_ec2_instance_type> -D <wso2am_rds_db_instance_class>"
}
export -f usageCommand

function usageHelp() {
    #echo "-a: WSO2 API Manager Distribution."
    #echo "-c: MySQL Connector JAR file."
    echo "-A: Amazon EC2 Instance Type for WSO2 API Manager."
    echo "-D: Amazon EC2 DB Instance Class for WSO2 API Manager RDS Instance."

}
export -f usageHelp

# export test_plan=$1

declare -A arr_prop
set -x
cd $2
echo "List"
ls
cat testplan-props.properties
file="$2/testplan-props.properties"
set +x
if [ -f "$file" ]
then
    while IFS='=' read -r key value; do
        arr_prop["$key"]="$value"
    done < $file
    wso2am_ec2_instance_type=${arr_prop["wso2am_ec2"]}
    wso2am_rds_db_instance_class=${arr_prop["rds_ec2"]}
else
  echo "$file not found."
  exit 1
fi

# while getopts ":u:y:m:d:n:s:b:r:J:N:t:p:w:A:D:" opt; do
#     case "${opt}" in
#     A)
#         wso2am_ec2_instance_type=${OPTARG}
#         ;;
#     D)
#         wso2am_rds_db_instance_class=${OPTARG}
#         ;;
#     *)
#         opts+=("-${opt}")
#         [[ -n "$OPTARG" ]] && opts+=("$OPTARG")
#         ;;
#     esac
# done
# shift "$((OPTIND - 1))"

function validate() {
    # if [[ ! -f $wso2am_distribution ]]; then
    #     echo "Please provide WSO2 API Manager distribution."
    #     exit 1
    # fi

    export wso2am_distribution_filename=wso2am-2.6.0.zip

    # if [[ ${wso2am_distribution_filename: -4} != ".zip" ]]; then
    #     echo "WSO2 API Manager distribution must have .zip extension"
    #     exit 1
    # fi

    # if [[ ! -f $mysql_connector_jar ]]; then
    #     echo "Please provide MySQL Connector JAR file."
    #     exit 1
    # fi

    export mysql_connector_jar_filename=mysql-connector-java-8.0.16.jar

    # if [[ ${mysql_connector_jar_filename: -4} != ".jar" ]]; then
    #     echo "MySQL Connector JAR must have .jar extension"
    #     exit 1
    # fi

    if [[ -z $wso2am_ec2_instance_type ]]; then
        echo "Please provide the Amazon EC2 Instance Type for WSO2 API Manager."
        exit 1
    fi

    if [[ -z $wso2am_rds_db_instance_class ]]; then
        echo "Please provide the Amazon EC2 DB Instance Class for WSO2 API Manager RDS Instance."
        exit 1
    fi
}
export -f validate

function create_links() {
    wso2am_distribution=$(realpath $wso2am_distribution)
    mysql_connector_jar=$(realpath $mysql_connector_jar)
    ln -s $wso2am_distribution $temp_dir/$wso2am_distribution_filename
    ln -s $mysql_connector_jar $temp_dir/$mysql_connector_jar_filename
}
export -f create_links

function get_test_metadata() {
    echo "application_name=$application_name"
    echo "wso2am_ec2_instance_type=$wso2am_ec2_instance_type"
    echo "wso2am_rds_db_instance_class=$wso2am_rds_db_instance_class"
}
export -f get_test_metadata

function get_cf_parameters() {
    echo "WSO2APIManagerDistributionName=$wso2am_distribution_filename"
    echo "MySQLConnectorJarName=$mysql_connector_jar_filename"
    echo "WSO2APIManagerInstanceType=$wso2am_ec2_instance_type"
    echo "WSO2APIManagerDBInstanceClass=$wso2am_rds_db_instance_class"
    echo "MasterUsername=wso2carbon"
    echo "MasterUserPassword=wso2carbon#9762"
}
export -f get_cf_parameters

function get_columns() {
    echo "Scenario Name"
    echo "Heap Size"
    echo "Concurrent Users"
    echo "Message Size (Bytes)"
    echo "Back-end Service Delay (ms)"
    echo "Error %"
    echo "Throughput (Requests/sec)"
    echo "Average Response Time (ms)"
    echo "Standard Deviation of Response Time (ms)"
    echo "99th Percentile of Response Time (ms)"
    echo "WSO2 API Manager GC Throughput (%)"
    echo "Average WSO2 API Manager Memory Footprint After Full GC (M)"
}
export -f get_columns

#$script_dir/cloudformation-common.sh "${opts[@]}" -- "$@"
$script_dir/cloudformation-common.sh "$2"