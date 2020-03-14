#!/bin/bash

WEB_IPS="34.250.40.84 34.250.40.84"

date_started="`date`"
echo "Starting small download and upload at ${date_started}"

for web_ip in ${WEB_IPS}; do
  curl http://${web_ip}:80/files/10B
  curl -X POST --header 'Content-Type: multipart/form-data' -F submit="Upload File Now" -F myfile=@/Users/aledsage/alb-cost-testing/1KB http://${web_ip}:80/files/upload.php
done

date_ended="`date`"
echo "Finished GET and POST jobs at ${date_ended}, started at ${date_started}"
