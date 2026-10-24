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

dnf module disable redis -y
dnf module enable redis:7 -y
dnf install redis -y &>> $log_file
validate $? "install redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? "allowing remote connections"

systemctl enable redis &>> $log_file
systemctl start redis &>> $log_file
validate $? "Enable and start redis"


echo "$(timestamp) Script completed in: $seconds"
echo "$(timestamp) [INFO]   =====Script Completed Execution ====" | tee -a $log_file
