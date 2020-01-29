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
    # export apim_host=$(get_ssh_hostname $apim_ssh_host)
    # echo "Downloading tokens to $HOME."
    # scp $apim_ssh_host:apim/target/tokens.csv $HOME/
    if [[ $jmeter_servers -gt 1 ]]; then
        for jmeter_ssh_host in ${jmeter_ssh_hosts[@]}; do
            echo "Copying tokens to $jmeter_ssh_host"
            # scp $HOME/tokens.csv $jmeter_ssh_host:
            cp $script_dir/../apim/target/tokens.csv $HOME
            scp $HOME/tokens.csv $jmeter_ssh_host:
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
    jmeter_params+=("host=$apim_host_url" "port=8243" "path=$service_path")
    jmeter_params+=("payload=$HOME/${msize}B.json" "response_size=${msize}B" "protocol=$protocol"
        tokens="$HOME/tokens.csv")
    n=1
    for ip in ${apim_ips[@]}; do
        echo "Starting APIM${n} service in $ip with $heap of heap memory"
        ssh -i $key_file ubuntu@$ip sudo bash ./apim/apim-start.sh -m $heap
        n=$(($n + 1))
    done
}

function after_execute_test_scenario() {
    report_location=$1
    n=1
    apim_ssh_command="ssh -i $key_file -o "StrictHostKeyChecking=no" -T ubuntu@"
    for ip in ${apim_ips[@]}; do
        write_server_metrics apim${n} "$apim_ssh_command${ip}" org.wso2.carbon.bootstrap.Bootstrap
        download_file apim${n} "${apim_ssh_command}${ip}" /usr/lib/wso2/wso2am/2.6.0/wso2am-2.6.0/repository/logs/wso2carbon.log wso2carbon.log
        download_file apim${n} "${apim_ssh_command}${ip}" /usr/lib/wso2/wso2am/2.6.0/wso2am-2.6.0/repository/logs/gc.log wso2carbon.log
        n=$(($n + 1))
    done
}

test_scenarios
