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
SCRIPT_PATH=$PWD

mkdir -p $LOGS_FOLDER
echo "script started executing at: $(date)" |tee -a $LOG_FILE

#check the user have root access or not
if [ $USERID -ne 0 ]
then
    echo -e "$R error: please run with root access $N " &>>$LOG_FILE
    exit 1
else
    echo -e "$G running with root access $N" | tee -a $LOG_FILE
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

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Installing python3 packages"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "creating roboshop system user"
else
    echo -e "system user roboshop already created .....$y skipping   $N"
fi

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading payment"

rm -rf /app/*
cd /app 
unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzipping payment"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing depencies"

cp $SCRIPT_PATH/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "Copying payment service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon-reload"


systemctl enable payment &>>$LOG_FILE
VALIDATE $? "Enabling Payment"

systemctl start payment  &>>$LOG_FILE
VALIDATE $? "Starting payment"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
