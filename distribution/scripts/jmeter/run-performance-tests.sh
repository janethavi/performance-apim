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
# Run API Manager Performance Tests
# ----------------------------------------------------------------------------

script_dir=$(dirname "$0")
# Execute common script
. $script_dir/perf-test-common.sh

function initialize() {
    export apim_ssh_host=apim
    n=1
    apim_ips=$1
    jmeter_servers_ips=$2
    for ip in ${apim_ips[@]}; do
       echo "Starting APIM${n} service in $ip with $heap of heap memory"
       ssh -i $key_file ubuntu@$ip sudo bash ./Perf_dist/apim/apim-start.sh -m $heap
       echo "Installing SAR to APIM-$n"
       ssh -i $key_file ubuntu@$ip sudo bash ./Perf_dist/sar/install-sar.sh
       n=$(($n + 1))
    done
    if [[ ! -z $jmeter_servers_ips ]]; then
        echo "Copying tokens to JMeter-Servers"
        for jmeter_servers_ip in ${jmeter_servers_ips[@]}; do
            scp -i $key_file $HOME/tokens.csv ubuntu@$jmeter_servers_ip:/home/ubuntu
        done
    fi
}
export -f initialize

declare -A test_scenario0=(
    [name]="passthrough"
    [display_name]="Passthrough"
    [description]="A secured API, which directly invokes the back-end service."
    [jmx]="apim-test.jmx"
    [protocol]="https"
    [path]="/echo/1.0.0"
    [use_backend]=true
    [skip]=false
)
declare -A test_scenario1=(
    [name]="transformation"
    [display_name]="Transformation"
    [description]="A secured API, which has a mediation extension to modify the message."
    [jmx]="apim-test.jmx"
    [protocol]="https"
    [path]="/mediation/1.0.0"
    [use_backend]=true
    [skip]=false
)

function before_execute_test_scenario() {
    export apim_ips=("$@")
    local service_path=${scenario[path]}
    local protocol=${scenario[protocol]}
    apim_host_url=$(cat $HOME/apim-host-url.txt)
    jmeter_params+=("host=$apim_host_url" "port=8243" "path=$service_path")
    jmeter_params+=("payload=$HOME/${msize}B.json" "response_size=${msize}B" "protocol=$protocol"
        tokens="$HOME/tokens.csv")
}

function after_execute_test_scenario() {
    report_location=$1
    n=1
    apim_ssh_command="ssh -i $key_file -o "StrictHostKeyChecking=no" -T ubuntu@"
    for ip in ${apim_ips[@]}; do
        write_server_metrics apim${n} "$apim_ssh_command${ip}" org.wso2.carbon.bootstrap.Bootstrap
        download_file apim${n} "${apim_ssh_command}${ip}" /usr/lib/wso2/wso2am/2.6.0/wso2am-2.6.0/repository/logs/wso2carbon.log apim${n}/wso2carbon.log
        download_file apim${n} "${apim_ssh_command}${ip}" /usr/lib/wso2/wso2am/2.6.0/wso2am-2.6.0/repository/logs/gc.log apim${n}/apim${n}_gc.log
        n=$(($n + 1))
    done
}

test_scenarios
