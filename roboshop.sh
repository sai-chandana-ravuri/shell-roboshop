#!/bin/bash

SG_ID="sg-000c5b9d2b80050b6"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z08145131ZQYG4A7JX2E8"
DOMAIN_NAME="daws88c.online"

for instance in $@
do
    INSTANCE_ID=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --count 1 \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query "Instances[0].InstanceId" \
    --output text )
    if [ $instance == "frontend" ]; then
        ID=$(
           aws ec2 describe-instances \
           --instance-ids $INSTANCE_ID \
           --query "Reservations[].Instances[].PublicIpAddress" \
           --output text
        )
        RECORD_NAME="$DOMAIN_NAME"
    else
        ID=$(
        aws ec2 describe-instances \
           --instance-ids $INSTANCE_ID \
           --query "Reservations[].Instances[].PrivateIpAddress" \
           --output text
        )
        RECORD_NAME="$instance.$DOMAIN_NAME"
    fi
    echo "IP Address is: $ID"
    aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch "{
    \"Comment\": \"Updating a record\",
    \"Changes\": [{
    \"Action\": \"UPSERT\",
    \"ResourceRecordSet\": {
    \"Name\": \"$RECORD_NAME\",
    \"Type\": \"A\",
    \"TTL\": 300,
    \"ResourceRecords\": [{ \"Value\": \"$ID\" }]
        }
       }]
      }"
  echo "Record updated for $instance"   
done