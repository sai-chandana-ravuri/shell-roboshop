#!/bin/bash

SG_ID="sg-000c5b9d2b80050b6"
AMI_ID="ami-0220d79f3f480ecf5"


for instance in $@
do
    INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$1}]' \
    --query "Instances[0].InstanceId" \
    --output text )
    if [ $instance == "frontend" ]; then
        ID=$(
           aws ec2 describe-instances \
           --instance-ids $INSTANCE_ID \
           --query "Reservations[].Instances[].PublicIpAddress" \
           --output text
        )
    else
        ID=$(
        aws ec2 describe-instances \
           --instance-ids $INSTANCE_ID \
           --query "Reservations[].Instances[].PrivateIpAddress" \
           --output text
        )
    fi
done