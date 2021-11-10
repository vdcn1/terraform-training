import boto3
import os
import json
from flask import Flask
import requests
from ec2_metadata import ec2_metadata
from botocore.exceptions import ClientError

app = Flask(__name__)

@app.route("/tags")
def retrieve_tags():
    ec2 = boto3.client('ec2', region_name="us-east-2")
    print(ec2_metadata.instance_id)
    response = ec2.describe_instances(InstanceIds=[ec2_metadata.instance_id])
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            for tags in instance["Tags"]:
                tag_list = []
                tag_list.append(tags)
    response = dict(zip(tag_list))
    return res

@app.route("/shutdown")
def shutdown_instance():
    ec2 = boto3.client('ec2', region_name="us-east-2")
    current_instance = ec2_metadata.instance_id 
    ec2.stop_instances(InstanceIds=[str(current_instance)])
    return "Shuting down...\n"