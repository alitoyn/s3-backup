#! /bin/bash
success_push() {
        curl -s -k -u $PUSHBULLET_API_KEY \
                -X POST https://api.pushbullet.com/v2/pushes \
                --header 'Content-Type: application/json' \
                --data-binary \
                '{"type": "note", "title": "Backup", "body": "Backup success"}' \
                >/dev/null 2>&1
}

fail_push() {
        curl -s -k -u $PUSHBULLET_API_KEY \
                -X POST https://api.pushbullet.com/v2/pushes \
                --header 'Content-Type: application/json' \
                --data-binary \
                '{"type": "note", "title": "Backup", "body": "Backup failed"}' \
                >/dev/null 2>&1
}

# Local .env
if [ -f .env ]; then
        # Load Environment Variables
        export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

if AWS_PROFILE=$AWS_PROFILE /usr/local/bin/aws s3 sync $BACKUP_PATH $BUCKET_PATH >$LOG_PATH; then
        echo "success" $(date) >>$LOG_PATH
        success_push
else
        echo "failed" $(date) >>/home/ali/logs/ali-nextcloud-sync.logs
        fail_push
fi
