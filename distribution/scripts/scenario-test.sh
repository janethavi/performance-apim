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
# Build performance distribution
# ----------------------------------------------------------------------------

script_dir=$(dirname "$0")
script_dir=$(realpath "$script_dir")
. $script_dir/build.sh
INPUT_DIR=$2
OUTPUT_DIR=$4

performance_script=$script_dir/../../performance-dist/cloudformation/run-performance-tests.sh
$performance_script $INPUT_DIR $OUTPUT_DIR
