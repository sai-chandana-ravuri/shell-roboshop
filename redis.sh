#!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"

R='\e[31m'
G='\e[32m'
Y='\e[33m'
B='\e[34m'
N='\e[0m'

if [ $USER_ID -ne 0 ]; then
   echo -e "$R Please use admin access to install.. $N" | tee -a $LOGS_FILE
   exit 1
else
   echo -e "$G Proceeding with installation.."
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
if [ $1 -eq 0 ]; then
   echo -e "$2...$G SUCCESS $N" | tee -a $LOGS_FILE
else
   echo -e "$2...$R FAILURE $N" | tee -a $LOGS_FILE
   exit 1
fi
}

dnf module disable redis -y &>>$LOGS_FILE
dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "Enable redis:7"

dnf install redis -y  &>>$LOGS_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

systemctl enable redis &>>$LOGS_FILE
systemctl start redis &>>$LOGS_FILE
VALIDATE $? "Enable and Starting redis:7"