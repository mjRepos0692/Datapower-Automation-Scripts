#!/bin/sh
# Take the deployment inputs
echo "Enter which server to deploy, in which domain and which DP policy to deploy"
read server_port domain MPG_Service
echo "Enter the branch where the export result is stored"
read branch_name

echo -e "\n DP Deployment Script Starts"

echo "Enter the DataPower Credentials:"
read -p 'username: ' user_var
read -sp 'password: ' pass_var

# Deployment Import
echo -e "\n Deployment Policy Import Starts"

file_n="*.zip"
#dest_loc="/d/Users/jay.maniar/WORK/Automation_DP/DP_Automated/DP"
# To pickup code from BitBucket
git clone "http://10.41.8.15:7990/scm/wiodp/${MPG_Service}.git"
cd $MPG_Service
git checkout $branch_name
cd "Deployment Policy"
cd $domain
#src_loc="/d/Users/jay.maniar/WORK/Automation_DP/DP_Automated/DP/${MPG_Service}/Deployment_Policy/${domain}/${file_n}"
echo $src_loc
cp /d/Users/jay.maniar/WORK/Automation_DP/DP_Automated/DP/${MPG_Service}/Deployment\ Policy/${domain}/${file_n} /d/Users/jay.maniar/WORK/Automation_DP/DP_Automated/DP/
cd ..
cd ..
cd ..

# creating a json which contains the base64 encoded zip file of Deployment Policy
JSON_STRING='{
  "Import": {
    "InputFile": "'"$( base64 ${MPG_Service}_Deploy_Policy.zip )"'",
    "Format": "ZIP",
    "OverwriteObjects": "on",
    "OverwriteFiles": "on",
    "RewriteLocalIP": "on"
  }
}'
echo $JSON_STRING > ${MPG_Service}_J_Policy.json

curl -k -u $user_var:$pass_var -d @${MPG_Service}_J_Policy.json https://sduidp${server_port}.temp.ad:5554/mgmt/actionqueue/${domain} > ${MPG_Service}_Policy_Result.Json

sleep 10s

curl -k -u $user_var:$pass_var -d @Save_Config.json https://sduidp${server_port}.temp.ad:5554/mgmt/actionqueue/${domain} > ${MPG_Service}_Save_Config_Policy_Result.json

echo -e "\n Configuration Saved Successfully"

echo -e "\n Deployment_Policy Import Completed"

$SHELL
