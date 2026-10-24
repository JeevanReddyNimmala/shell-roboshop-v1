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

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "adding rabbitmq "

dnf install erlang rabbitmq-server -y &>> $log_file
validate $? "installing RabbitMQ"

systemctl enable rabbitmq-server &>> $log_file
systemctl start rabbitmq-server &>> $log_file
validate $? "Enable & Start Rabbit MQ"

rabbitmqctl list_users | grep -qw "roboshop"
if [$? -ne 0]; then
    rabbitmqctl add_user roboshop roboshop123 &>> $log_file
    validate $? "creating user for RabbitMQ"
else
    echo  -e "$(timestamp) [INFO] RabbitMQ user aleady exists ...${Y}SKIPPING{N}"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validate $? "setting permissions for RabbitMQ"




echo "$(timestamp) Script completed in: $SECONDS seconds"
echo "$(timestamp) [INFO]   =====Script Completed Execution ====" | tee -a $log_file
