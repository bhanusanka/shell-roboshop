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
VALIDATE() {
    if [ $1 -eq 0 ]
    then 
        echo -e "Installing $2 is ...$G succcess $N" |tee -a $LOG_FILE
    else    
        echo -e "installing $2 is ...$R failure $N" |tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling default redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis 7"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing redis"



