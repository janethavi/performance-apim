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
perf_apim_dir=$(dirname "$0")
home_dir=$perf_apim_dir/..

performance_common_repo=https://github.com/janethavi/performance-common.git
git -C $home_dir clone $performance_common_repo
ln -s $home_dir/performance-common perf_common

pushd perf_common
git checkout test-grid
mvn -N io.takari:maven:wrapper
mvn -N io.takari:maven:wrapper -Dmaven=3.5.2
./mvnw clean install
popd
pushd $perf_apim_dir
mvn -N io.takari:maven:wrapper
mvn -N io.takari:maven:wrapper -Dmaven=3.5.2
mvn clean install
mkdir $home_dir/Perf_dist
ln -s $home_dir/Perf_dist Perf_dist
find $perf_apim_dir/distribution/target/ -name "*.tar.gz" -exec sh -c 'tar xvf {} -C Perf_dist' \;
popd