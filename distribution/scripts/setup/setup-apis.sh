#!/bin/bash -e
# Copyright 2017 WSO2 Inc. (http://wso2.org)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ----------------------------------------------------------------------------
# Setup WSO2 API Manager
# ----------------------------------------------------------------------------

# This script will run all other scripts to configure and setup WSO2 API Manager

# Make sure the script is running as root.
if [ "$UID" -ne "0" ]; then
    echo "You must be root to run $0. Try following"
    echo "sudo $0"
    exit 9
fi

export script_name="$0"
export script_dir=$(dirname "$0")
export netty_host=""
export mysql_host=""
export mysql_user=""
export mysql_password=""
export os_user=""

function usageCommand() {
    echo "-n <netty_host> -m <mysql_host> -u <mysql_username> -p <mysql_password> -o <os_user>"
}
export -f usageCommand

function usageHelp() {
    echo "-n: The hostname of Netty service."
    echo "-a: The hostname of APIM Gateway."
    echo "-m: The hostname of MySQL service."
    echo "-u: MySQL Username."
    echo "-p: MySQL Password."
    echo "-o: General user of the OS."
}
export -f usageHelp

while getopts "gp:w:o:n:a:m:u:p:o:" opt; do
    case "${opt}" in
    n)
        netty_host=${OPTARG}
        ;;
    a)
        apim_host=${OPTARG}
        ;;    
    m)
        mysql_host=${OPTARG}
        ;;
    u)
        mysql_user=${OPTARG}
        ;;
    p)
        mysql_password=${OPTARG}
        ;;
    o)
        os_user=${OPTARG}
        ;;
    *)
        opts+=("-${opt}")
        [[ -n "$OPTARG" ]] && opts+=("$OPTARG")
        ;;
    esac
done
shift "$((OPTIND - 1))"

function validate() {
    if [[ -z $netty_host ]]; then
        echo "Please provide the hostname of Netty Service."
        exit 1
    fi
    if [[ -z $apim_host ]]; then
        echo "Please provide the hostname of WSO2 API Manager."
        exit 1
    fi
    if [[ -z $mysql_host ]]; then
        echo "Please provide the hostname of MySQL host."
        exit 1
    fi
    if [[ -z $mysql_user ]]; then
        echo "Please provide the MySQL username."
        exit 1
    fi
    if [[ -z $mysql_password ]]; then
        echo "Please provide the MySQL password."
        exit 1
    fi
    if [[ -z $os_user ]]; then
        echo "Please provide the username of the general os user"
        exit 1
    fi
}
export -f validate

function mediation_out_sequence() {
    cat <<EOF
<sequence xmlns=\"http://ws.apache.org/ns/synapse\" name=\"mediation-api-sequence\">
    <payloadFactory media-type=\"json\">
        <format>
            {\"payload\":\"\$1\",\"size\":\"\$2\"}
        </format>
        <args>
            <arg expression=\"\$.payload\" evaluator=\"json\"></arg>
            <arg expression=\"\$.size\" evaluator=\"json\"></arg>
        </args>
    </payloadFactory>
</sequence>
EOF
}
export -f mediation_out_sequence

function setup(){
    # # Start API Manager
    # sudo -u $os_user $script_dir/../apim/apim-start.sh -m 1G

    # Create APIs in Local API Manager
    sudo -u $os_user $script_dir/../apim/create-api.sh -a $apim_host-n "echo" -d "Echo API" -b $netty_host
    sudo -u $os_user $script_dir/../apim/create-api.sh -a $apim_host -n "mediation" -d "Mediation API" -b $netty_host
        -o "$(mediation_out_sequence | tr -d "\n\r")"

    # Generate tokens
    tokens_sql="$script_dir/../apim/target/tokens.sql"
    if [[ ! -f $tokens_sql ]]; then
        sudo -u $os_user $script_dir/../apim/generate-tokens.sh -t 4000
    fi

    if [[ -f $tokens_sql ]]; then
        mysql -h $mysql_host -u $mysql_user -p$mysql_password apim <$tokens_sql
    else
        echo "SQL file with generated tokens not found."
        exit 1
    fi
}