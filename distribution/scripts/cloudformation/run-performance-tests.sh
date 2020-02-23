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

export wso2am_ec2_instance_type=""
export wso2am_rds_db_instance_class=""

export number_of_product_nodes=2

export aws_cloudformation_template_filename="apim_perf_test_cfn.yaml"
export application_name="WSO2 API Manager"
export metrics_file_prefix="apim"
export run_performance_tests_script_name="run-performance-tests.sh"
export mysql_host=""
export apim_endpoint=""
export mysql_username=""
export mysql_password=""


input_dir=$1
output_dir=$2
deployment_prop_file=$input_dir/"deployment.properties"
testplan_prop_file=$input_dir/../"testplan-props.properties"
echo "Test output directory is $output_dir"
declare -A propArray
if [ -f "$deployment_prop_file" ]
then
    while IFS='=' read -r key value; do
        propArray["$key"]="$value"
    done < $deployment_prop_file
    mysql_host=${propArray[RDSHost]}
    apim_endpoint=${propArray[GatewayHttpsUrl]}
else
  echo "Error: deployment.properties file not found."
  exit 1
fi
if [ -f "$testplan_prop_file" ]
then
    while IFS='=' read -r key value; do
        propArray["$key"]="$value"
    done < $testplan_prop_file
    mysql_username=${propArray[DBUsername]}
    mysql_password=${propArray[DBPassword]}
    IFS=' '
else
  echo "Error: testplan_prop.properties file not found."
  exit 1
fi

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
$script_dir/perform-test.sh "$input_dir" "$output_dir"