#!/bin/bash

terraform output -json > output.json

RECOGNITION_URL=$(jq -r '.recognition_url.value' output.json)
RECORDS_URL=$(jq -r '.records_url.value' output.json)
EMAIL_URL=$(jq -r '.email_url.value' output.json)
DETECTION_URL=$(jq -r '.detection_url.value' output.json)

cat <<EOL > .env
LOCAL_DIRECTORY=./temp_images
S3_ARCHIVE_FOLDER_NAME=archive
S3_SMILE_FOLDER_NAME=smile
S3_SMILE_FOLDER_URL=https://kntbucketlondon.s3.eu-west-2.amazonaws.com/smile
S3_BUCKET_NAME=kntbucketlondon
RECOGNITION_URL=$RECOGNITION_URL
RECORDS_URL=$RECORDS_URL
EMAIL_URL=$EMAIL_URL
DETECTION_URL=$DETECTION_URL
REGION_NAME=eu-west-2
DYNAMODB_NAME=smile
OPENAI_API_KEY=ADD_YOUR_API_KEY
EOL
