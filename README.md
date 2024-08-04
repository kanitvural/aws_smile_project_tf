
# Building a Smile-Based Access Control System Using AWS: Let Your Smile Be Your Password



## Introduction

The adoption of AWS Cloud systems is rapidly increasing as both small and large enterprises recognize their advantages. AWS provides startups with significant benefits, enabling rapid project deployment while avoiding substantial upfront costs. Moreover, AWS offers promotional credits of up to $2,000 for project promotions.

In this article, I will guide you through the creation of a face detection application using AWS Rekognition. This project allowed me to quickly bring my vision to life without the need for extensive model training.

Below, you'll find an overview of the project, how it operates, and a step-by-step installation guide for those interested in trying it out. With Terraform, you can easily integrate this project into your AWS account and test it.

---


---


## The SMILE App

<div align="center">
  <img src="images/logo.png" alt="Local Image" width="500"/>
</div>

### Let your smile be your password.

Kanıt VURAL  
- [linkedin](https://www.linkedin.com/in/kanitvural/)
- [E-mail](mailto:kanitvural@gmail.com)


### Why the SMILE App?

- Many companies rely on card-based systems for employee access.
- These systems can be costly due to card and device expenses.
- Employees might forget their cards or use each other's cards, leading to security concerns.
- The SMILE app offers a cost-effective alternative using AWS technologies.

### What Does the SMILE App Do?

- Captures and records employees' faces. A smile in front of the camera grants access without the need for physical cards.
- Notifies a group of managers via email with the names of employees entering the premises.
- Analyzes entry data with hourly, daily, weekly, and yearly graphs.

### Purpose

The SMILE app is designed to cut costs and mitigate the issues associated with traditional card-based access systems. By leveraging AWS, it eliminates the need for physical cards and works on-demand, making it both efficient and economical.

This presentation will guide you through a simulated internal company system access scenario.


### TECHNOLOGIES USED

<div align="center">
  <img src="images/techs.png" alt="Local Image" width="1000"/>
</div>


### How the SMILE App Works

- Runs on a low-cost EC2 instance within a VPC.
- Automatically provisions DynamoDB and SES services upon initial setup via API Gateway.
- SES sends a verification message to the admin group, with email addresses recorded for future notifications.
- The EC2 instance acts as an intermediary, handling requests without the need for a more expensive machine.
- New employee photos are saved to S3, and camera images are stored in a separate S3 folder.
- AWS Rekognition analyzes the images to detect smiles.
- If a smile is detected, another request triggers AWS Rekognition’s face comparison model to verify identity.
- Verified entries are logged in DynamoDB, and managers are notified via SES.
- The system is designed for on-demand operation, keeping costs minimal.


### System Architecture Diagram

<div align="center">
  <img src="images/infrastructure.png" alt="Local Image" width="1000"/>
</div>


### Installation Guide

Open an AWS account:
https://aws.amazon.com/free/


Download Terraform:
https://www.hashicorp.com/

**Create Keypair for ec2:**

- Only change your username (Windows users can use git bash)
  
`ssh-keygen -t rsa -b 2048 -f C:/Users/YOUR_USERNAME/Desktop/smile2.pem`

**Clone the Repository:**

`git clone https://github.com/kntvrl/aws_smile_project_tf.git`

**Deploy with Terraform**

You can use vscode editor or whatever you want:

```
cd aws_smile_project_tf
terraform init
terraform plan 
terraform apply
Enter a value: yes
```
**Copy Terraform Outputs:**

<div align="left">
  <img src="images/terminal.png" alt="Local Image" width="800"/>
</div>

---

**Go to aws console and chose your region as london and change your mail address:**

<div align="left">
  <img src="images/region.png" alt="Local Image" width="200"/>
</div>

```
go to lambda > functions > lambda_email
in the code block area, type your email here and click deploy
```

<div align="left">
  <img src="images/lambda1.png" alt="Local Image" width="800"/>
</div>

---

<div align="left">
  <img src="images/change_email.png" alt="Local Image" width="800"/>
</div>

---

**Open your terminal and connect to ec2 instance:**
```
cd ~/desktop
ssh -i smile2.pem ec2-user@18.169.158.138 # public_ip that you copy from terraform output
command yes

ls # you need to see project file "aws_smile_project_tf" if not wait a little and type ls again

cd aws_smile_project_tf

```

---

**copy the env variables from terraform output here (ctrl x > y > enter):**

`sudo nano .env`

<div align="left">
  <img src="images/env.png" alt="Local Image" width="800"/>
</div>

---

**start the application:**

`sudo systemctl start smile`

---

**Go to your mail and verify your email adress**

---

**you can access the application with ec2_public_dns above:**
```
example:
ec2-18-171-252-102.eu-west-2.compute.amazonaws.com
```
---
**SSL certification:**

I used nginx server in this project, so if you want to open camera you need ssl certification, http sites don't allow to open web cam.

I used cloudflare for ssl certification 

---

**Get the ec2 ip and add the cloudflare dns :**

You need to have domain name for this application.

```
example:
18.171.252.102
```
<div align="left">
  <img src="images/cloudflare_dns.png" alt="Local Image" width="800"/>
</div>

---

**Welcome to smile app**

Record your picture and add your first and last name. Click “Add Person to the System” to register.

<div align="left">
  <img src="images/add_person.png" alt="Local Image" width="800"/>
</div>

---

Open your camera and smile :)

<div align="left">
  <img src="images/webcam.png" alt="Local Image" width="800"/>
</div>

---

You can also monitor the entrances

<div align="left">
  <img src="images/monitor.png" alt="Local Image" width="800"/>
</div>

---

And check your mailbox

<div align="left">
  <img src="images/mail.png" alt="Local Image" width="800"/>
</div>


---

**How to Delete the SMILE app**

Go back your editor and run

`terraform destroy`

Manually delete DynamoDB and SES services from AWS Console.

dynamodb service > Tables > select the db and delete.

<div align="left">
  <img src="images/dynamo_delete.png" alt="Local Image" width="800"/>
</div>

---

ses service > identities > select your mail and delete.

<div align="left">
  <img src="images/ses_delete.png" alt="Local Image" width="800"/>
</div>

---

# Optional

If you have an OpenAI API key, you can enable ChatGPT to make jokes when it detects you not smiling at the camera. Update `utils.py` in the EC2 instance by commenting out the relevant code sections, add your API key to the `.env` file, and restart the service.

`sudo nano utils.py`


<div align="left">
  <img src="images/chatgpt.png" alt="Local Image" width="800"/>
</div>

<div align="left">
  <img src="images/env.png" alt="Local Image" width="800"/>
</div>

`sudo systemctl restart smile`


# Conclusion

This guide demonstrates how to set up a face recognition-based access control system using AWS. For questions or further assistance, feel free to contact me. May your days be filled with smiles!

Kanıt VURAL  
- [linkedin](https://www.linkedin.com/in/kanitvural/)
- [E-mail](mailto:kanitvural@gmail.com)







