 #!/bin/bash

USER_ID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="/var/log/shell-roboshop/$0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.daws88c.online
MYSQL_HOST=mysql.daws88c.online

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

dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATE $? "Installing python"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo "Roboshop user already existed.. $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating a app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading project"

cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping code"

cd /app 
pip3 install -r requirements.txt
VALIDATE $? "Installing dependencies"

systemctl daemon-reload
VALIDATE $? "Reloading service"

systemctl enable payment 
systemctl start payment
VALIDATE $? "Enable and starting payment"