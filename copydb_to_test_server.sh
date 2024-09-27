#/bin/sh

DB_NAME="database_test"
FILE_PATH="/work/dbbackup/copytotest"
TO_PATH="dbcopy"
KEY_PATH="~/.ssh/id_rsa"

HOST=xxx.xx.xx.x
USER=username
PASS=
MYSQL_TEST_ACC="test"
MYSQL_TEST_PASS=`cat /var/db/.testdb.shadow`

echo "mysqldump db ${DB_NAME} ..."
mysqldump -udu_pshift --password=`cat /var/db/.db.shadow` --net-buffer-length 50000 --default-character-set=utf8 --quick --add-drop-table --result-file ${FILE_PATH}/${DB_NAME}.sql --databases ${DB_NAME}

if [ -f "${FILE_PATH}/${DB_NAME}.sql" ]; then
    echo "gzip ${FILE_PATH}/${DB_NAME}.sql ..."
    gzip -f ${FILE_PATH}/${DB_NAME}.sql
else
    echo "mysqldump Error..."
fi
echo "Moving file sql to test server..."
scp -i ${KEY_PATH} ${FILE_PATH}/${DB_NAME}.sql.gz ${USER}@${HOST}:~/${TO_PATH}

echo "SSH to test server..."
ssh -i ${KEY_PATH} ${USER}@${HOST} << EOF
    cd ${TO_PATH}
    echo "Unzip ${DB_NAME}.sql.gz ..."
    gzip -d ${DB_NAME}.sql.gz

    if [ -f "${DB_NAME}.sql" ]; then
        echo "Unzip Success..."
        echo "Mysql Importing..."
        mysql -u${MYSQL_TEST_ACC} --password=${MYSQL_TEST_PASS} ${DB_NAME} < ${DB_NAME}.sql

        if [ $? -eq 0 ]; then
            echo "Mysql importted success..."
        else
            echo "Mysql has error"
        fi
    else
        echo "Unzip Error..."
    fi
EOF
echo "DONE..."