#!/bin/bash

set -e

BACKUP_DIR="/backups"
TIMESTAMP=$1
CONFIG_BACKUP="$BACKUP_DIR/gitlab_config_backup.tar.gz"
MINIO_ALIAS="gitlab-backups"
MINIO_BUCKET="gitlabce"

pause_gitlab() {
  kubectl exec -n gitlabcek8s deploy/gitlab -- gitlab-ctl stop
}

resume_gitlab() {
  kubectl exec -n gitlabcek8s deploy/gitlab -- gitlab-ctl start
}

restore_backup() {
  kubectl exec -n gitlabcek8s deploy/gitlab -- gitlab-backup restore BACKUP=$TIMESTAMP
}

restore_config() {
  kubectl exec -n gitlabcek8s deploy/gitlab -- tar -xzvf $CONFIG_BACKUP -C /
}

pause_gitlab

mc alias set $MINIO_ALIAS https://s3-api.it.com ACCESS_KEY SECRET_KEY
mc cp $MINIO_ALIAS/$MINIO_BUCKET/backups/${TIMESTAMP}_gitlab_backup.tar $BACKUP_DIR/
mc cp $MINIO_ALIAS/$MINIO_BUCKET/configurations/gitlab_config_backup.tar.gz $BACKUP_DIR/

restore_backup
restore_config

kubectl exec -n gitlabcek8s deploy/gitlab -- gitlab-ctl reconfigure
resume_gitlab

kubectl exec -n gitlabcek8s deploy/gitlab -- gitlab-rake gitlab:check SANITIZE=true
