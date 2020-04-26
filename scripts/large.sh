#!/bin/bash

WEB_IPS="34.250.40.84 34.250.40.84"

# 10GB download: 100 files of size 128MB; 50 files per IP.

date_started="`date`"
echo "Starting 10GB of downloads at ${date_started}"
for i in {1..50}; do
  echo "Batch $i of 50"
  for web_ip in ${WEB_IPS}; do
    curl http://${web_ip}:80/files/128MB | wc -c
  done
done
date_ended="`date`"
echo "Finished GET jobs at ${date_ended}, started at ${date_started}"



# 10GB uploads: 10240 files of size 1MB; 5120 files per IP.
# Done in batches of 32 parallel calls (16 per IP); 320 batches.

date_started="`date`"
echo "Starting 10GB of uploads at ${date_started}"
for i in {1..320}; do
  echo "Batch $i of 320, at $(date)"
  for j in {1..16}; do
    for web_ip in ${WEB_IPS}; do
      curl -X POST --header 'Content-Type: multipart/form-data' -F submit="Upload File Now" -F myfile=@/Users/aledsage/Downloads/1MB http://${web_ip}:80/files/upload.php &
    done
  done
  echo "Waiting for jobs: $(jobs -p | wc -l)"
  for job in `jobs -p`; do
    wait $job || echo "Job $job failed"
  done
done
date_ended="`date`"
echo "Finished POST jobs at ${date_ended}, started at ${date_started}"
date
