#!bin/bash
user_id=$(id -u)
log_folder="/var/log/shell_practice"
log_file="${log_folder}/${0}.log"
domain_name="jsrgroup.online"
scripts_dir=$(dirname "$(realpath "$0")")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ] ; then
    echo "Run this with SUDO access"
    exit 1
fi

mkdir -p $log_folder
echo  "script started ececution at $(date +"%F %T")"

timestamp(){
 date +"%F %T"
}

validate (){
    if [ $1 -ne 0 ] ; then
    echo  -e "$(timestamp) [ERROR] ${2} ...${R}FAILED${N}" | tee -a $log_file
    exit 1
else
    echo  -e "$(timestamp) [INFO] ${2} .. ${G}SUCCUSS${N}" | tee -a $log_file
fi
}

 
echo "$(timestamp) [INFO]   =====Script Started Execution ====" | tee -a $log_file

dnf module enable maven:3.9 -y &>> $log_file
validate $? "Enable Java"
dnf install maven java-25-openjdk-devel -y &>> $log_file
validate $? "Install Java"
alternatives --set  java "/usr/lib/jvm/java-25-openjdk/bin/java"
validate $? "Setting Java 25 as default version for installing and usage"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME

validate $? "setting JAVA_Home for maven"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop

rm -rf /app
mkdir -p /app
validate $? "Creating App directory"

curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip
validate $? "downloading the Shipping"

cd /app
unzip /tmp/shipping.zip

validate $? "unziping the Shipping"

cd /app
mvn clean package
validate $? "Installing de pendencies"

mv target/shipping.jar shipping.jar
validate $? "moving shipping.jar file"

dnf install mysql -y &>> $log_file
validate $? "Insatlling mysql client"

mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/master-data.sql
validate $? "loading shipping data"
mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/app-user.sql
validate $? "loading user data"

systemctl daemon-reload
systemctl enable shipping
validate $? "enabled shipping"
systemctl start shipping
validate $? "Start Shipping"


echo "$(timestamp) Script completed in: $SECONDS seconds"
echo "$(timestamp) [INFO]   =====Script Completed Execution ====" | tee -a $log_file
