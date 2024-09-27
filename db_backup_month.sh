#/bin/sh

bkpath="/work/dbbackup"

agomonth="`/bin/date '+%Y%m' --date '+3 month ago'`"
curmonth="`/bin/date '+%Y%m'`"
nowd="`/bin/date '+%d'`"
curdate="`/bin/date '+%Y%m%d'`"
curtime="`/bin/date '+%H%M'`"

if [ $nowd -eq 1 ]
then
        if [ -d $bkpath/$agomonth ]
        then
                rm -rf $bkpath/$agomonth
        fi
fi

if [ -d $bkpath/$curmonth ]
then
        chmod -R 0777 $bkpath/$curmonth
else
        mkdir $bkpath/$curmonth
        chmod -R 0777 $bkpath/$curmonth
fi

if [ -d $bkpath/$curmonth/$curdate ]
then
        chmod -R 0777 $bkpath/$curmonth/$curdate
else
        mkdir $bkpath/$curmonth/$curdate
        chmod -R 0777 $bkpath/$curmonth/$curdate
fi

if [ -d $bkpath/$curmonth/$curdate/$curtime ]
then
        chmod -R 0777 $bkpath/$curmonth/$curdate/$curtime
else
        mkdir $bkpath/$curmonth/$curdate/$curtime
        chmod -R 0777 $bkpath/$curmonth/$curdate/$curtime
fi

for db_name in $(mysql -e 'show databases' -s --skip-column-names -u test --password=`cat /var/db/.db.shadow` | grep -E "^dbname_"); do mysqldump -u test --password=`cat /var/db/.db.shadow` $db_name | gzip > "$bkpath/$curmonth/$curdate/$curtime/$db_name.sql.gz"; done


bkpath="/work/dbbackup"
ukpath="/home/user/dbbackup"

HOST=xxx.xxx.xx.x
USER=useraccount
PASS=

FROM_DIR=$bkpath/$curmonth/$curdate/$curtime
TO_DIR=$ukpath/$curmonth/$curdate

ssh -i /work/dbbackup/vitz-user.pem ${USER}@${HOST} "mkdir -p ${TO_DIR}"

scp -prq -i /work/dbbackup/vitz-user.pem ${FROM_DIR} ${USER}@${HOST}:${TO_DIR}
