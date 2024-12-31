#!/bin/bash

set -e

BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
CONFIG_BACKUP="$BACKUP_DIR/gitlab_config_backup.tar.gz"
MINIO_ALIAS="gitlab-backups"
MINIO_BUCKET="gitlabce"

pause_gitlab() {
  kubectl exec -n gitlabcek8s deploy/gitlab -- gitlab-ctl stop
}

resume_gitlab() {
  kubectl exec -n gitlabcek8s deploy/gitlab -- gitlab-ctl start
}

pause_gitlab

kubectl exec -n gitlabcek8s deploy/gitlab -- gitlab-backup create
kubectl exec -n gitlabcek8s deploy/gitlab -- tar -czvf $CONFIG_BACKUP /etc/gitlab /var/opt/gitlab /etc/letsencrypt

mc alias set $MINIO_ALIAS https://s3-api.it.com ACCESS_KEY SECRET_KEY
mc cp $BACKUP_DIR/*_gitlab_backup.tar $MINIO_ALIAS/$MINIO_BUCKET/backups/
mc cp $CONFIG_BACKUP $MINIO_ALIAS/$MINIO_BUCKET/configurations/

mc rm --recursive --force --older-than=7d $MINIO_ALIAS/$MINIO_BUCKET/backups/
mc rm --recursive --force --older-than=7d $MINIO_ALIAS/$MINIO_BUCKET/configurations/

resume_gitlab
