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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "Copying Mongo Repo.."

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing Mongodb Server.."

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enabling Mongodb Server.."

systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "Starting Mongodb Server.."

sed 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf 
VALIDATE $? "Allowing connections from internet.."

systemctl restart mongod &>>$LOGS_FILE
VALIDATE $? "Restarting Mongodb Server.."