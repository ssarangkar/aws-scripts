#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Need exactly two input parameters  1. EB Environment name 2. Command to run"
    echo "Example    runonallinstances.sh my-elasticbeanstalk-app ls"
    exit 1
fi

#Cleanup 
if [ -f instanceids.txt ]; then 
	rm instanceids.txt 
fi 
if [ -f allips.txt ]; then 
	rm allips.txt  
fi 
if [ -f commandtorun.txt ]; then 
	rm commandtorun.txt
fi 

environmentname="$1"
commandtorun="$2"

echo $commandtorun > commandtorun.txt

aws elasticbeanstalk describe-environment-resources --environment-name  $environmentname --query 'EnvironmentResources.Instances' --output text > instanceids.txt 
 
input="/Users/ssarangkar/work/scripts/instanceids.txt"
while IFS= read -r var
do
	aws ec2 describe-instances --instance-ids  $var --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text >> allips.txt	
done < "$input"

while IFS= read -r ip
do
	ssh  -oControlMaster=no -oControlPath=~/.ssh/ssh-%r-%h-%p ec2-user@$ip /bin/bash < commandtorun.txt

done < "/Users/ssarangkar/work/scripts/allips.txt"

#Cleanup 
rm instanceids.txt  allips.txt  commandtorun.txt
