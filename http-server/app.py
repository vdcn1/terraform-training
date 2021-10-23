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
    instance = ec2.Instance(ec2_metadata.instance_id)
    return instance.tags

@app.route("/shutdown")
def shutdown_instance():
    ec2 = boto3.client('ec2', region_name="us-east-2")
    current_instance = ec2_metadata.instance_id
    ec2.stop_instances(InstanceIds=[str(current_instance)])
    return "Shuting down..."