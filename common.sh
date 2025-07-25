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

app_setup()
{
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

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name"

    rm -rf /app/*
    cd /app 
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzipping $app_name"
}

nodejs_setup()
{
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "disabling default nodejs"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "enabling nodejs"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "installing nodejs"

    npm install 
    VALIDATE $? "installing dependencies"
}

maven_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven and Java"

    mvn clean package  &>>$LOG_FILE
    VALIDATE $? "Packaging the shipping application"

    mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
    VALIDATE $? "Moving and renaming Jar file"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Install Python3 packages"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"

    cp $SCRIPT_PATH/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
    VALIDATE $? "Copying payment service"

}

systemd_setup()
{
    cp $SCRIPT_PATH/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Copying $app_name service"

    systemctl daemon-reload &>>$LOG_FILE
    systemctl enable $app_name &>>$LOG_FILE
    systemctl start $app_name
    VALIDATE $? "Starting $app_name"
}
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