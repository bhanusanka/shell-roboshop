#!/bin/Bash

source ./common.sh
app_name=mysql
check_root

echo "please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD


dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "installing mysql server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "enabling mysql"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "starting mysql"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VALIDATE $? "setting mysql root password"

print_time