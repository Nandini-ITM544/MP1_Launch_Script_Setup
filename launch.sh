#!/bin/bash 
#creating instances with parameters
declare -a instance_id 
mapfile -t instance_id  < <(aws ec2 run-instances --image-id $1 --count $2 --instance-type $3 --key-name $4 --security-group-ids $5 --subnet-id $6 --associate-public-ip-address --iam-instance-profile Name=$7 --user-data file:///home/controller/Documents/MP1_Environment_Setup_Final/install-env.sh --output table | grep InstanceId | sed "s/|//g" | tr -d ' ' | sed "s/InstanceId//g")
echo ${instance_id[@]} 
aws ec2 wait instance-running --instance-ids ${instance_id[@]}
aws elb create-load-balancer --load-balancer-name Project1 --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80 --security-groups $5 --subnets $6
aws elb register-instances-with-load-balancer --load-balancer-name Project1 --instances ${instance_id[@]}
aws elb configure-health-check --load-balancer-name Project1 --health-check Target=HTTP:80/index.html,Interval=30,UnhealthyThreshold=2,HealthyThreshold=2,Timeout=3
