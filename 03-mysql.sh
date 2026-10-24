#!bin/bash
user_id=$(id -u)
log_folder="/var/log/shell_practice"
log_file="${log_folder}/${0}.log"
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

dnf module enable mysql:8.4 -y &>> $log_file
dnf install mysql-server -y &>> $log_file
validate $? "mysql-server installation"

systemctl enable mysqld
systemctl start mysqld
validate $? "mysql-server enable and start"

mysql_secure_installation --set-root-pass RoboShop@1
validate $? "setting username and password"




echo "$(timestamp) Script completed in: $SECONDS seconds"
echo "$(timestamp) [INFO]   =====Script Completed Execution ====" | tee -a $log_file
