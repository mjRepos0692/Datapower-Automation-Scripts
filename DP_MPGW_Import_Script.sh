#!/bin/sh
# Take the publish inputs

echo "Enter which server to deploy, in which domain, which export MPGW service to use and which policy to refer"
read server_port domain MPG_Service
DP_Policy="${MPG_Service}_Deploy_Policy_${domain}"

echo "Enter the branch where the export result is stored"
read branch_name

echo -e "\n DP Deployment Script Starts"

echo "Enter the DataPower Credentials:"
read -p 'username: ' user_var
read -sp 'password: ' pass_var

alias jq=./jq-win64.exe
# Service Import
echo -e "\n MPG Import Starts"

file_n="*.zip"
dest_loc="/d/Users/jay.maniar/WORK/Automation_DP/DP_Automated/DP"
# To pickup code from BitBucket
git clone "http://10.41.8.15:7990/scm/wiodp/${MPG_Service}.git"
cd $MPG_Service
git checkout $branch_name
src_loc="/d/Users/jay.maniar/WORK/Automation_DP/DP_Automated/DP/${MPG_Service}/${file_n}"
cp $src_loc $dest_loc
cd ..

# creating a json which contains the base64 encoded zip file of Deployment Policy
JSON_STRING='{
  "Import": {
    "InputFile": "'"$( base64 ${MPG_Service}.zip )"'",
    "Format": "ZIP",
    "OverwriteObjects": "on",
    "OverwriteFiles": "on",
    "RewriteLocalIP": "on",
	"DeploymentPolicy": "'"${DP_Policy}"'"
  }
}'
echo $JSON_STRING > ${MPG_Service}_J.json

curl -k -u $user_var:$pass_var -d @${MPG_Service}_J.json https://sduidp${server_port}.temp.ad:5554/mgmt/actionqueue/${domain} > ${MPG_Service}_Result.Json

sleep 10s

curl -k -u $user_var:$pass_var -d @Save_Config.json https://sduidp${server_port}.temp.ad:5554/mgmt/actionqueue/${domain} > ${MPG_Service}_Save_Config_Result.json


echo -e "\n Configuration Saved Successfully"

echo -e "\n Service Import Completed"

$SHELL


