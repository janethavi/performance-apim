#!/usr/bin/env python

import boto3
import sys


def get_private_ip(
        aws_region, aws_access_key_id, aws_access_key_secret, instance_name):
    #   initialize the boto3 client
    client = boto3.client(
        'autoscaling', region_name=aws_region,
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_access_key_secret)
    #   get information of existing auto scaling groups
    response = client.describe_auto_scaling_groups()

    #   capture the auto scaling group based on tag name
    instance_ids = []
    ec2_responses = []
    ip_addresses= []
    for group in response['AutoScalingGroups']:
        tags = group['Tags']
        for tag in tags:
            if tag['Key'] == 'Name' and tag['Value'] == instance_name:
                instances = group['Instances']
                if instance_name == 'Jmeter-Server':
                    instance_ids.append(instances[0]['InstanceId'])
                    instance_ids.append(instances[1]['InstanceId'])
                else:
                    instance_ids.append(instances[0]['InstanceId'])
    #   get EC2 instance information
    ec2_client = boto3.client(
        'ec2', region_name=aws_region, aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_access_key_secret)
    if len(instance_ids) > 0:
        for id in instance_ids:
                ec2_responses.append(ec2_client.describe_instances(InstanceIds=[id]))
    if len(instance_ids) > 0:
        for ec2_response in ec2_responses:
            if len(ec2_response['Reservations']) > 0:
                if len(ec2_response['Reservations'][0]['Instances']) > 0:
                    ip_addresses.append(ec2_response['Reservations'][0] ['Instances'][0]['PrivateIpAddress'])        
        return ip_addresses
        
if __name__ == '__main__':
    region = sys.argv[1]
    access_key_id = sys.argv[2]
    access_key_secret = sys.argv[3]
    instance_name = sys.argv[4]
    print(
        get_private_ip(
            region, access_key_id, access_key_secret, instance_name))
