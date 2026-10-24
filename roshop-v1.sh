#!bin/bash


ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="jsrgroup.online"
hosted_zone_id="Z00476562MNMUL8K5RS3C"

for instance in $@
do
    echo "Creating instacne: $instance"
    
    instance_id=$(aws ec2 run-instances \
                --image-id $ami_id \
                --instance-type $instance_type \
                --security-groups "Roboshop-common" "roboshop-$instance" \
     --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
                --query 'Instances[0].InstanceId' \
                --output text
    )
    

    echo "Instance Id: $instance_id"

    if [[ $instance != "frontend" ]]; then
        IP=$(aws ec2 describe-instances     --instance-ids $instance_id \
        --query 'Reservations[].Instances[].PrivateIpAddress'     --output text
        ) 
            r53_record="$instance.$domain_name"
    else

        IP=$(aws ec2 describe-instances     --instance-ids $instance_id \
    --query 'Reservations[].Instances[].PublicIpAddress'     --output text
        )
        r53_record="$domain_name"
    fi

    echo "$IP"

    # update r53 record
 echo "update record $domain_name"
    aws route53 change-resource-record-sets \
    --hosted-zone-id $hosted_zone_id \
    --change-batch '{
        "Changes":[
            {
            "Action":"UPSERT",
            "ResourceRecordSet":{
            "Name":"'$r53_record'",
            "Type":"A",
            "TTL":1,
            "ResourceRecords":[{"Value":"'$IP'"}]
            }
        }
    ]
}'
echo "updated R53 record for $instance"

done

