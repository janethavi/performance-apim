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
# Setup Performance distribution in product nodes
# ----------------------------------------------------------------------------

script_dir=$(dirname "$0")
script_dir=$(realpath $script_dir)
apim_ips=("$@")

perf_dist_location=$(find /home/ubuntu/Resources/performance-apim/distribution/target -name '*.tar.gz' )
perf_dist_name=$(echo $perf_dist_location | cut -d '/' -f 8-)
for i in "${apim_ips[@]}"
do
    scp -i $key_file -o "StrictHostKeyChecking=no" $perf_dist_location ubuntu@$apim_ips[i]:/home/ubuntu
    # scp -i $key_file -o "StrictHostKeyChecking=no" $script_dir/setup_perf_dist.sh ubuntu@$apim_ips[i]:/home/ubuntu
    ssh -i $key_file -o "StrictHostKeyChecking=no" ubuntu@$apim_ips[i] tar xzf /home/ubuntu/$perf_dist_name
done