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

dnf install maven -y &>>$LOGS_FILE
VALIDATE $? "Installing maven"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo "Roboshop user already existed.. $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating a app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading project"

cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/shipping.zip &>>$LOGS_FILE
VALIDATE $? "Unzipping code"

cd /app 
mvn clean package &>>$LOGS_FILE
VALIDATE $? "Installing and Building shipping"

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "Moving and renaming shipping"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Configuring systemctl service"

dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "Installing mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql

systemctl daemon-reload &>>$LOGS_FILE
VALIDATE $? "Reloading shipping"

systemctl enable shipping &>>$LOGS_FILE
systemctl start shipping &>>$LOGS_FILE
VALIDATE $? "Enabling and starting shipping"