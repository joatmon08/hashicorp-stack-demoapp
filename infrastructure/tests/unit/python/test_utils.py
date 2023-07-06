import subprocess
import requests
import time
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
                "message": "Testing Terraform from pytest",
                "plan-only": True
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
        }
    }
    run_details = requests.post(
        url='{}/runs'.format(TERRAFORM_CLOUD_API),
        json=payload,
        headers={
            'Content-Type': 'application/vnd.api+json',
            'Authorization': "Bearer {}".format(TERRAFORM_CLOUD_TOKEN)
        })
    run_id = run_details.json()['data']['id']
    plan_id = run_details.json()['data']['relationships']['plan']['data']['id']
    return run_id, plan_id


def show(run_id):
    plan = None
    while True:
        plan = requests.get(
            url='{}/runs/{}/plan/json-output'.format(TERRAFORM_CLOUD_API, run_id),
            headers={
                'Content-Type': 'application/vnd.api+json',
                'Authorization': "Bearer {}".format(TERRAFORM_CLOUD_TOKEN)
        })
        if plan.status_code != 204:
            break

        time.sleep(120)
    return plan.json()


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


test = {'data': {'id': 'run-7dLAgKYQusRREawN', 'type': 'runs', 'attributes': {'actions': {'is-cancelable': True, 'is-confirmable': False, 'is-discardable': False, 'is-force-cancelable': False}, 'allow-config-generation': False, 'allow-empty-apply': False, 'auto-apply': False, 'canceled-at': None, 'created-at': '2023-07-06T13:48:43.665Z', 'has-changes': False, 'is-destroy': False, 'message': 'Testing Terraform from pytest', 'plan-only': False, 'refresh': True, 'refresh-only': False, 'replace-addrs': None, 'source': 'tfe-api', 'status-timestamps': {'plan-queueable-at': '2023-07-06T13:48:43+00:00', 'queuing-at': '2023-07-06T13:48:44+00:00'}, 'status': 'pending', 'target-addrs': None, 'trigger-reason': 'manual', 'terraform-version': '1.5.1', 'permissions': {'can-apply': True, 'can-cancel': True, 'can-comment': True, 'can-discard': True, 'can-force-execute': True, 'can-force-cancel': True, 'can-override-policy-check': True}, 'variables': []}, 'relationships': {'workspace': {'data': {'id': 'ws-Mjb4JsG1e4i5dJ7s', 'type': 'workspaces'}}, 'apply': {'data': {'id': 'apply-kkFKDbu6DjK5pzYM',
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         'type': 'applies'}, 'links': {'related': '/api/v2/runs/run-7dLAgKYQusRREawN/apply'}}, 'configuration-version': {'data': {'id': 'cv-FrzbsRkFaiWWnRWE', 'type': 'configuration-versions'}, 'links': {'related': '/api/v2/runs/run-7dLAgKYQusRREawN/configuration-version'}}, 'created-by': {'data': {'id': 'user-qPxjX9WzyfFSpSXC', 'type': 'users'}, 'links': {'related': '/api/v2/runs/run-7dLAgKYQusRREawN/created-by'}}, 'plan': {'data': {'id': 'plan-i2npsSHM3bhEFxD1', 'type': 'plans'}, 'links': {'related': '/api/v2/runs/run-7dLAgKYQusRREawN/plan'}}, 'run-events': {'data': [{'id': 're-8zFFe6k2s87YoPPX', 'type': 'run-events'}], 'links': {'related': '/api/v2/runs/run-7dLAgKYQusRREawN/run-events'}}, 'task-stages': {'data': [{'id': 'ts-oQ64ZwS11NXfYfgj', 'type': 'task-stages'}], 'links': {'related': '/api/v2/runs/run-7dLAgKYQusRREawN/task-stages'}}, 'policy-checks': {'data': [], 'links': {'related': '/api/v2/runs/run-7dLAgKYQusRREawN/policy-checks'}}, 'comments': {'data': [], 'links': {'related': '/api/v2/runs/run-7dLAgKYQusRREawN/comments'}}}, 'links': {'self': '/api/v2/runs/run-7dLAgKYQusRREawN'}}}
