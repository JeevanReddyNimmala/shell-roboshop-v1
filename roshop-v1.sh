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

    if [ $instacne != "frontend" ]; then
        IP=$(aws ec2 describe-instances     --instance-ids i-0035f889324a68515 \
        --query 'Reservations[*].Instances[*].PrivateIpAddress'     --output text
        r53_record = "$instance.$doamin_name"
    ) 
    else

        IP=(aws ec2 describe-instances     --instance-ids i-0035f889324a68515 \
    --query 'Reservations[*].Instances[*].PublicIpAddress'     --output text
        )
        r53_record = "$doamin_name"
    fi

    # update r53 record

    aws route53 change-resource-record-sets \
    --hosted-zone-id "$hosted-zone-id" \
    --change-batch '{
        "Changes":[
            {
            "Action":"UPSERT",
            "ResourceRecordSet":{
            "Name":":r_53record_name",
            "Type":"A",
            "TTL":1,
            "ResourceRecords":[{"Value":"$IP"}]
            }
        }
    ]
}'

done

