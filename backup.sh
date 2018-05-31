#!/bin/bash
# A Simple Shell Script to Backup Red Hat / CentOS / Fedora / Debian / Ubuntu Apache Webserver and SQL Database
# Path to backup directories
DIRS="/home/vivek/ /var/www/html/ /etc"
 
# Store todays date
NOW=$(date +"%F")
 
# Store backup path
BACKUP="/backup/$NOW"
 
# Backup file name hostname.time.tar.gz
BFILE="$(hostname).$(date +'%T').tar.gz"
PFILE="$(hostname).$(date +'%T').pg.sql.gz"
MFILE="$(hostname).$(date +'%T').mysql.sq.gz"
 
# Set Pgsql username
PGSQLUSER="vivek"
 
# Set MySQL username and password
MYSQLUSER="vivek"
MYSQLPASSWORD="myPassword"
 
# Remote SSH server setup
SSHSERVER="backup.example.com" # your remote ssh server
SSHUSER="vivek"                # username
SSHDUMPDIR="/backup/remote"    # remote ssh server directory to store dumps
 
# Paths for binary files
TAR="/bin/tar"
PGDUMP="/usr/bin/pg_dump"
MYSQLDUMP="/usr/bin/mysqldump"
GZIP="/bin/gzip"
SCP="/usr/bin/scp"
SSH="/usr/bin/ssh"
LOGGER="/usr/bin/logger"
 
# make sure backup directory exists
[ ! -d $BACKUP ] && mkdir -p ${BACKUP} 
 
# Log backup start time in /var/log/messages
$LOGGER "$0: *** Backup started @ $(date) ***"
 
# Backup websever dirs
$TAR -zcvf ${BACKUP}/${BFILE} "${DIRS}"
 
# Backup PgSQL
$PGDUMP -x -D -U${PGSQLUSER} | $GZIP -c > ${BACKUP}/${PFILE}
 
# Backup MySQL
$MYSQLDUMP  -u ${MYSQLUSER} -h localhost -p${MYSQLPASSWORD} --all-databases | $GZIP -9 > ${BACKUP}/${MFILE}
 
# Dump all local files to failsafe remote UNIX ssh server / home server
$SSH ${SSHUSER}@${SSHSERVER} mkdir -p ${SSHDUMPDIR}/${NOW}
$SCP -r ${BACKUP}/* ${SSHUSER}@${SSHSERVER}:${SSHDUMPDIR}/${NOW}
 
# Log backup end time in /var/log/messages
$LOGGER "$0: *** Backup Ended @ $(date) ***"
