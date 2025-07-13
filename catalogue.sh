#!/bin/Bash

source ./common.sh

app_name=catalogue

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_PATH/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb client"

STATUS=$(mongosh --host mongodb.sankadevops.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.sankadevops.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "loading data into mongodb"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi

print_time