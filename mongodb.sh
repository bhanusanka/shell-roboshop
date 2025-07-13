#!/bin/Bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "script started executing at: $(date)" |tee -a $LOG_FILE

#check the user have root access or not
if [ $USERID -ne 0 ]
then
    echo -e "$R error: please run with root access $N " &>>$LOG_FILE
    exit 1
else
    echo "running with root access" &>>$LOG_FILE
fi

#validate function takes input as exit status, and what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing  mongodb"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enabling mongodb"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "editing  mongodb conf file for remote connections"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restarting mongodb"



