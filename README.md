# Automated Backup & Restore for GitLab CE

[![GitLab CE](https://img.shields.io/badge/GitLab%20CE-Backup%20%26%20Restore-blue)](https://gitlab.com/) [![Kubernetes](https://img.shields.io/badge/Kubernetes-Automation-green)](https://kubernetes.io/) [![MinIO](https://img.shields.io/badge/MinIO-S3%20Compatible-orange)](https://min.io/)

This repository provides a solution for automating **GitLab CE** backup and restoration in a **Kubernetes** environment. Integrated with **MinIO S3 Bucket** for efficient backup storage, ensuring data is easily recoverable in case of failures.

---

## **Features**

- **Automated Backups:** Scheduled backups using Kubernetes CronJobs.
- **Simple Restoration:** On-demand restoration using Kubernetes Jobs.
- **MinIO Integration:** Utilizes S3-compatible MinIO storage for backup retention and management.
- **Highly Configurable:** Configuration based on environment variables.
- **Data Integrity:** Pauses GitLab services during backup/restoration to ensure data consistency.
- **Notifications:** Optional integration with Slack or email for failure alerts.

---

## **Architecture**

### **Components**

1. **Backup CronJob**
   - Runs daily (default: 2 AM) to back up GitLab data and configurations.
   - Stores backups in a MinIO bucket.

2. **Restore Job**
   - Downloads backups from MinIO and restores them to the GitLab CE instance.
   - Designed for manual scenarios or disaster recovery.

3. **Kubernetes Resources**
   - ConfigMaps and Secrets for secure MinIO access and configuration.
   - Volumes for temporary storage during backup/restoration.

4. **MinIO Storage**
   - Retains backups for a configurable retention period (default: 7 days).
   - Manages backup versions using timestamps.

---

## **Structure**

```plaintext
gitlab-backup-restore/
├── Dockerfiles/
│   ├── backup.Dockerfile        # Dockerfile for the backup container
│   ├── restore.Dockerfile       # Dockerfile for the restore container
├── scripts/
│   ├── backup.sh                # Main script for backups
│   ├── restore.sh               # Main script for restorations
├── kubernetes/
│   ├── cronjob-backup.yaml      # Kubernetes CronJob for backups
│   ├── job-restore.yaml         # Kubernetes Job for restorations
│   ├── configmap.yaml           # ConfigMap for environment variables
│   ├── secret-minio.yaml        # Secret for MinIO credentials
├── configs/
│   ├── example-env.sh           # Example configuration for local testing
│   ├── README.md                # Documentation for configurations
├── README.md                    # Main documentation
```

---

## **Setup & Usage**

### **1. Prerequisites**

- A Kubernetes cluster with GitLab CE deployed in the `gitlabcek8s` namespace.
- A MinIO instance with a bucket configured for backup storage.
- Access to `kubectl` for managing Kubernetes resources.
- A container registry for storing Docker images.

---

### **2. Configuration**

#### **Step 1: Clone the Repository**
```bash
git clone https://server-gitlab.it.com/it/devops/gitlabce-backup-restore.git
cd gitlab-backup-restore
```

#### **Step 2: Configure MinIO Secrets**
Set up MinIO credentials as a Kubernetes Secret:
```bash
kubectl create secret generic minio-credentials -n gitlabcek8s \
    --from-literal=access_key=your-access-key \
    --from-literal=secret_key=your-secret-key
```

#### **Step 3: Configure Backup Settings**
Update the `configmap.yaml` file with your MinIO bucket and endpoint:
```yaml
data:
  minio_endpoint: "https://s3-api.it.com"
  minio_bucket: "gitlabce"
  backup_dir: "/backups"
```
Apply the ConfigMap:
```bash
kubectl apply -f kubernetes/configmap.yaml
```

#### **Step 4: Build and Push Docker Images**
Build and push the Docker images for backup and restoration:
```bash
docker build -t harbor.it.com/it/gitlab-backup:latest -f Dockerfiles/backup.Dockerfile .
docker build -t harbor.it.com/it/gitlab-restore:latest -f Dockerfiles/restore.Dockerfile .
docker push harbor.it.com/it/gitlab-backup:latest
docker push harbor.it.com/it/gitlab-restore:latest
```

#### **Step 5: Deploy Backup CronJob**
Apply the CronJob manifest:
```bash
kubectl apply -f kubernetes/cronjob-backup.yaml
```

#### **Step 6: Restore Backup (if needed)**
Manually initiate a restoration by updating the `job-restore.yaml` file with the desired timestamp and applying it:
```yaml
args:
  - "TIMESTAMP"
```
Deploy the restore Job:
```bash
kubectl apply -f kubernetes/job-restore.yaml
```

---

## **Monitoring & Notifications**

### **Slack Notifications**
To integrate Slack notifications for backup/restoration failures:
1. Create a Slack Webhook.
2. Add the Webhook URL as a ConfigMap or Secret.
3. Update the `backup.sh` and `restore.sh` scripts to send notifications using `curl`.

### **Log Monitoring**
View logs for backup/restoration Jobs using:
```bash
kubectl logs job/gitlab-backup -n gitlabcek8s
kubectl logs job/gitlab-restore -n gitlabcek8s
```

---

## **Customization**

- **Backup Schedule:** Modify the `schedule` field in the `cronjob-backup.yaml` file to adjust the frequency.
- **Retention Period:** Update the `--older-than=7d` parameter in the scripts to change retention settings.
- **Storage Location:** Change the `minio_bucket` or `minio_endpoint` in the ConfigMap for different storage configurations.

---

## **Best Practices**

- Regularly test the restoration process in a staging environment.
- Monitor CronJob and Job status using Kubernetes tools like Prometheus or Grafana.
- Use encrypted MinIO buckets for enhanced security.
