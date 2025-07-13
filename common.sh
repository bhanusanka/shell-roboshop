#!/bin/Bash

START_TIME=$(date +%s)
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
check_root()
{
    if [ $USERID -ne 0 ]
    then
        echo -e "$R error: please run with root access $N " &>>$LOG_FILE
        exit 1
    else
        echo "running with root access" | tee -a $LOG_FILE
    fi
}

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

print_time()
{
    END_TIME=$(date +%s)
    Total_Time=$(($END_TIME-$START_TIME))
    echo -e "script executed successfully $y Time taken : $Total_Time seconds ...$N"
}