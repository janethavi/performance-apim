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
# Build Performance-Distribution in AMIs
# ----------------------------------------------------------------------------
perf_apim_dir=$(dirname "$0")
perf_apim_dir=$(realpath "$perf_apim_dir")
home_dir=$perf_apim_dir/../..

INPUT_DIR=$1
deployment_prop_file=$INPUT_DIR/"deployment.properties"
infraRepoDir=""

declare -A propArray
if [ -f "$deployment_prop_file" ]
then
    while IFS='=' read -r key value; do
        propArray["$key"]="$value"
    done < $deployment_prop_file
    deploymentRepoDir=${propArray[depRepoLocation]}
    infraRepoDir=$(echo "$deploymentRepoDir" | sed "s/DeploymentRepository/InfraRepository/")
else
  echo "Error: deployment.properties file not found."
  exit 1
fi

# performance_common_repo=https://github.com/janethavi/performance-common.git
# git -C $home_dir clone $performance_common_repo

pushd $infraRepoDir
git checkout test-grid
mvn -N io.takari:maven:wrapper
mvn -N io.takari:maven:wrapper -Dmaven=3.5.2
./mvnw clean install
popd
pushd $home_dir
mvn clean install
mkdir $home_dir/performance-dist
find $home_dir/distribution/target/ -name '*.tar.gz' -execdir tar -C $home_dir/performance-dist -xzvf '{}' \;
popd
