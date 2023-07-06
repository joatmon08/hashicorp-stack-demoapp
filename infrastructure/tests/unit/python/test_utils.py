import subprocess
import requests
import os

TERRAFORM_CLOUD_API = 'https://app.terraform.io/api/v2'
TERRAFORM_CLOUD_WORKSPACE_ID = os.environ['TFC_WORKSPACE_ID']
TERRAFORM_CLOUD_TOKEN = os.environ['TFC_TOKEN']

def initialize():
    process = subprocess.Popen(
        ['terraform', 'init'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    process.communicate()
    return process.returncode

def plan():
    payload = {
        "data": {
            "attributes": {
                "message": "Testing Terraform from pytest"
            },
            "type": "runs",
            "relationships": {
                "workspace": {
                    "data": {
                        "type": "workspaces",
                        "id": TERRAFORM_CLOUD_WORKSPACE_ID
                    }
                }
            },
            "plan-only": True
        }
    }
    run_details = requests.post(
        url = '{}/runs'.format(TERRAFORM_CLOUD_API),
        json = payload,
        headers = {
            'Content-Type': 'application/vnd.api+json',
            'Authorization': "Bearer {}".format(TERRAFORM_CLOUD_TOKEN)
        })
    id = run_details.json()['data']['id']
    plan_id = run_details.json()['data']['relationships']['plan']['id']
    return id, plan_id

def show(plan_id):
    return requests.get(
        url = '{}/plans/{}'.format(TERRAFORM_CLOUD_API, plan_id),
        headers = {
            'Content-Type': 'application/vnd.api+json',
            'Authorization': "Bearer {}".format(TERRAFORM_CLOUD_TOKEN)
        })

def apply():
    process = subprocess.Popen(
        ['terraform', 'apply', '-auto-approve'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    return process.returncode, stdout, stderr


def destroy():
    process = subprocess.Popen(
        ['terraform', 'destroy', '-auto-approve'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
    process.communicate()
    return process.returncode