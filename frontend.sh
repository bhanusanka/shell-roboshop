#!/Bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-script-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_PATH=$PWD

mkdir -p $LOGS_FOLDER
echo "script started executing at: $(date)" |tee -a $LOG_FILE

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

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling default nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "enabling nginx 1.24"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "removing default content nginx"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping frontend"

rm -rf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "remove default conf"

cp $SCRIPT_PATH/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "copying nginx.conf"

systemctl restart nginx 
VALIDATE $? "restaring nginx"


