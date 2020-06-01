# Connect to Cloud SQL Instance.  Crate and populate table.
# Variables
$SERVER = "nrtmysql120"
$SAEMAIL = $SERVER + "@dataproc1-248508.iam.gserviceaccount.com"
$DATABASE = "db1"
$TABLE = "employees"
$PASSWORD="Password1234"
$USER = "mysqluser1"
$PROJECTID=gcloud config list --format 'value(core.project)'

# Create Cloud SQL Instance
$MySQL = gcloud sql instances create $SERVER --database-version=MYSQL_5_7 --tier=db-n1-standard-1 --region=us-east1 --root-password=$PASSWORD --quiet
$MYSQLIP = $(gcloud sql instances describe $SERVER --format="value(ipAddresses.ipAddress)")
$MYLOCALIP = (Invoke-WebRequest -uri "https://api.ipify.org/").Content

# Authorize Local Internet IP on MySQL instance
gcloud sql instances patch $SERVER --authorized-networks=$MYLOCALIP"/32" --quiet

# Create Database & Table
mysqlsh --host=$MYSQLIP --user=root  --password=$PASSWORD --sql --execute "create database if not exists $DATABASE ;"
mysqlsh --host=$MYSQLIP --user=root  --password=$PASSWORD --sql --execute "use $DATABASE ; drop table if exists $TABLE;"
mysqlsh --host=$MYSQLIP --user=root  --password=$PASSWORD --database=$DATABASE --sql --execute "create table employees (companyid VARCHAR(255),lastname VARCHAR(255),firstname VARCHAR(255),hiredate DATE,salary INT,fullname VARCHAR(255));"
mysqlsh --host=$MYSQLIP --user=root  --password=$PASSWORD --database=$DATABASE --sql --execute "describe employees;"
# mysqlsh --host=$MYSQLIP --user=root  --password=$PASSWORD --verbose --file createtable.sql

# Create MySQL User
mysqlsh --host=$MYSQLIP --user=root  --password=$PASSWORD --database=$DATABASE --sql --execute "CREATE USER $USER IDENTIFIED BY 'Password1234';"
mysqlsh --host=$MYSQLIP --user=root  --password=$PASSWORD --database=$DATABASE --sql --execute "GRANT ALL ON $DATABASE TO $USER IDENTIFIED BY 'Password1234';"
mysqlsh --host=$MYSQLIP --user=root  --password=$PASSWORD --database=$DATABASE --sql --execute "FLUSH PRIVILEGES;"
# mysqlsh --host=$MYSQLIP --user=root --password=$PASSWORD --verbose --file newuser.sql

# Populate table with csv records
gcloud sql import csv $SERVER gs://nrtbucket1/employees.csv --database=$DATABASE --table=$TABLE --quiet



# Check Data
mysqlsh --host=$MYSQLIP --user=root  --password=$PASSWORD --sql --execute "select * from db1.employees
order by salary desc
limit 10;"

