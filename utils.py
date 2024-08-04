import os
import logging
import boto3
from botocore.exceptions import NoCredentialsError, ClientError
from dotenv import load_dotenv
from datetime import datetime, timezone
import requests
import pandas as pd
import time

# AWS UTILS #

load_dotenv()
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

s3_bucket = os.getenv('S3_BUCKET_NAME')
region_name = os.getenv('REGION_NAME')
dynamodb_name = os.getenv('DYNAMODB_NAME')
archive_folder_name = os.getenv('S3_ARCHIVE_FOLDER_NAME')
smile_folder_name = os.getenv('S3_SMILE_FOLDER_NAME')
smile_folder_url = os.getenv('S3_SMILE_FOLDER_URL')
recognition_url = os.getenv('RECOGNITION_URL')
records_url = os.getenv('RECORDS_URL')
email_url = os.getenv('EMAIL_URL')
detection_url = os.getenv('DETECTION_URL')
file_name = ""

s3 = boto3.client("s3")
dynamodb = boto3.client('dynamodb', region_name)



def upload_to_s3(local_path, remote_path, bucket):
    try:
        s3.upload_file(Filename=local_path, Bucket=bucket, Key=remote_path)
        logging.info(f'Successfully uploaded {local_path} to s3://{bucket}/{remote_path}')
    except FileNotFoundError:
        logging.error(f'The file was not found: {local_path}')
    except NoCredentialsError:
        logging.error('Credentials not available')
        

def archive(file_path, firstname, lastname):

    if not file_path or not firstname or not lastname:
        return "No image or first name or last name provided"
    
    person_name = f"{firstname.lower()}_{lastname.lower()}"
    
    file_name = f"{person_name}.{file_path.split('.')[-1]}"
    s3_path = f"{archive_folder_name}/{file_name}"

    try:
        s3.head_object(Bucket=s3_bucket, Key=s3_path)
        return f"Error: {person_name} is already in the system."
    except:
        pass  

    upload_to_s3(file_path, s3_path, s3_bucket)
    return f"{person_name}'s image saved to the system as {file_name}"

# GRADIO IMAGE CHANGE EVENT 
def smile(file_path):
    global file_name
    
    if file_path is None:
        return "No image selected"
    
    smile_id = datetime.now(timezone.utc).strftime("%Y%m%d%H%M%S")
    file_name = f"{smile_id}.{file_path.split('.')[-1]}"
    s3_path = f"{smile_folder_name}/{file_name}"  
    upload_to_s3(file_path, s3_path, s3_bucket)
    return f"{smile_id} image saved to the system as {file_name}"


# GRADIO IMAGE CHANGE EVENT FOR 1 SECOND INTERVAL
def smile_with_interval(file_path):
    return_value = smile(file_path)
    time.sleep(1) 
    return return_value


# FACE RECOGNIZATION AND DETECTION API FUNCTIONS
def recognize():
    
    global file_name
    
    try:
        response = s3.list_objects_v2(Bucket=s3_bucket, Prefix=archive_folder_name)
        
        if len(response['Contents']) < 1:
            return {"error": "No images found in the specified S3 bucket and prefix"}
        
        source_images = [obj['Key'].replace(archive_folder_name, '').strip('/') for obj in response['Contents']]
        
        payload = {
            "target_image": file_name,
            "source_images": source_images
        }
        
        try:
            api_response = requests.post(recognition_url, json=payload)
            api_response.raise_for_status()
            return api_response.json()
        except requests.exceptions.RequestException as e:
            return {"error": f"API request failed: {e}"}
    
    except Exception as e:
        return {"error": f"Failed to list objects from S3: {e}"}


# FACE DETECTION FUNCTIONS RETURNS ALL FACE ANALYSIS
def detect_face_all():
    
    global file_name

    payload = {
        "image_key": file_name
    }
    
    try:
        response = requests.post(detection_url, json=payload)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        return {"error": f"API request failed: {e}"}


#IT READS SMILE VALUE AND RETURNS ONLY TRUE OR FALSE
def detect_face_smile():
    global file_name
    payload = {
        "image_key": file_name
    }
    
    try:
        response = requests.post(detection_url, json=payload)
        response.raise_for_status()
        result = response.json()
        
       
        if result.get("FaceDetails"):
            for face in result["FaceDetails"]:
                if "Smile" in face:
                    return face["Smile"]["Value"]
        return False
    
    except requests.exceptions.RequestException as e:
        return {"error": f"API request failed: {e}"}
    

# DYNAMODB POST
def post_records(firstname, lastname):
    
    global file_name
    
    image_url = f"{smile_folder_url}/{file_name}"
    payload = {
        "firstname": firstname,
        "lastname": lastname,
        "image_url": image_url
    }

    try:
        response = requests.post(records_url, json=payload)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        return {"error": f"API request failed: {e}"}

    
# DB FUNCTIONS
def check_db():
    try:
        response = dynamodb.describe_table(TableName=dynamodb_name)
        if response['Table']['TableName'] == dynamodb_name:
            return True
        else:
            return False
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceNotFoundException':
            return False
        else:
            raise
        
# GET RECORDS FROM DYNAMO DB
def get_records_from_db():

    try:
        response = dynamodb.scan(TableName=dynamodb_name)
        items = response['Items']
        records = []
        for item in items:
            record = {
                'Firstname': item.get('firstname', {}).get('S', 'Unknown'),
                'Lastname': item.get('lastname', {}).get('S', 'Unknown'),
                'Time': item.get('time', {}).get('S', 'Unknown'),
                'Image_url': item.get('image_url', {}).get('S', 'No URL')               
            }
            
            records.append(record)
            
        df = pd.DataFrame(records)
        df['Time'] = pd.to_datetime(df['Time'], format='%d/%m/%Y/%H:%M:%S')
        return df
    except Exception as e:
        print(f"Error retrieving records: {e}")
        return pd.DataFrame(columns=['Firstname', 'Lastname', 'Time', 'Image_url'])


# SES VERIFICATION EMAIL FUNCTION

def send_email(firstname, lastname):
    payload = {
        'firstname': firstname,
        'lastname': lastname
    }
    response = requests.post(email_url, json=payload)
    print(f"Response from API: {response.status_code} {response.text}")
    
    

# CHATGPT OPEN AI

# if you have openai api credits add your api key to .env and turn on these codes

# from openai import OpenAI
# api_key = os.getenv('OPENAI_API_KEY')


# client = OpenAI(api_key=api_key)

def generate_joke():
    
#     response = client.chat.completions.create(
#         model="gpt-3.5-turbo", 
#         messages=[
#             {"role": "system", "content": "You are a comedy assistant and you make short, witty puns. I want you to make jokes that are connected to everyday life and creative. Your jokes should include puns and irony, be short, and concise."},
#             {"role": "user", "content": "Make me a very funny joke. Write only the joke you produce as a response without using additional words, and fit it within 50 words. Your response should not exceed 50 words."}
#         ],
#         max_tokens=80,
#         temperature=0.9
#     )
    
#     message = response.choices[0].message.content
    message = "Why was the data scientist sad? Because he had too many missing values in his life!"
    return message
    
    
    