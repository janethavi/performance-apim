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
script_dir=$(pwd)
echo "Script dir $script_dir"
INPUT_DIR=$2
OUTPUT_DIR=$4

performance_dist_name="performance-apim-distribution.tar.gz"
performance_dist=$2/$performance_dist_name

cp $performance_dist $script_dir

tar xvf $performance_dist_name

performance_script="target/cloudformation/perform-test.sh"
run_command=$performance_script
$run_command $INPUT_DIR $OUTPUT_DIR
