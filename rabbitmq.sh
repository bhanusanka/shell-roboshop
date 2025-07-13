#!/bin/Bash

source ./common.sh
app_name=rabbitmq
check_root


echo "please enter rabbitmq password to setup"
read -s RABBITMQ_PASSWORD



cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Adding Rabbitmq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "installing Rabbitmq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "enabling Rabbitmq server"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "starting Rabbitmq server"

rabbitmqctl add_user roboshop $RABBITMQ_PASSWORD &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

print_time