 #!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.daws88c.online

R='\e[31m'
G='\e[32m'
Y='\e[33m'
B='\e[34m'
N='\e[0m'

if [ $USER_ID -ne 0 ]; then
   echo -e "$R Please use admin access to install.. $N" | tee -a $LOGS_FILE
   exit 1
else
   echo -e "$G Proceeding with installation.. $N"
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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disabling nodejs default version"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enabling nodejs 20 version"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Installing Nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo "Roboshop user already existed.. $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating a app directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading project"

cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/user.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping code"

npm install &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Configuring systemctl service"

systemctl daemon-reload
systemctl enable user &>>$LOGS_FILE
systemctl start user
VALIDATE $? "Starting and enabling user"





