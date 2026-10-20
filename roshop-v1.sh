#!bin/bash


ami_id="ami-0055977a6e828a4f4"
instance-type="t3.micro"
domain_name="jsrgroup.online"
hosted_zone_id="Z00476562MNMUL8K5RS3C"

for instance in $@
do
    echo "Creating instacne: $instance"
done
