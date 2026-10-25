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

dnf install golang -y &>> $log_file
validate $? "golang installation"


id roboshop &>> $log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating user for dispatch"
else
    echo  -e "$(timestamp) [INFO]  User aleady exists ...${Y}SKIPPING${N}"

fi 

rm -rf /app
mkdir -p /app
validate $? "Creating App directory"

curl -L -o /tmp/dispatch.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/dispatch-v4.zip &>> $log_file
validate $? "downloading the dispatch"

cd /app
unzip /tmp/dispatch.zip &>> $log_file

validate $? "unziping the dispatch"

cd /app
go build -o dispatch .
validate $? "insatalling dependencies"

sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/dispatch.service"
cp "$scripts_dir/dispatch.service" /etc/systemd/system/dispatch.service

systemctl daemon-reload
validate $? "daemon-reload"
systemctl enable dispatch
validate $? "Enable dispatch"
systemctl restart dispatch
validate $? "Start/Restarting the dispatch"

echo "$(timestamp) Script completed in: $SECONDS seconds"
echo "$(timestamp) [INFO]   =====Script Completed Execution ====" | tee -a $log_file
