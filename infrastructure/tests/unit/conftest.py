import pytest
import json
import requests
import time
import os

TERRAFORM_CLOUD_API = 'https://app.terraform.io/api/v2'
TERRAFORM_CLOUD_WORKSPACE_ID = os.environ['TFC_WORKSPACE_ID']
TERRAFORM_CLOUD_TOKEN = os.environ['TFC_TOKEN']


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
            url='{}/runs/{}/plan/json-output'.format(
                TERRAFORM_CLOUD_API, run_id),
            headers={
                'Content-Type': 'application/vnd.api+json',
                'Authorization': "Bearer {}".format(TERRAFORM_CLOUD_TOKEN)
            })
        if plan.status_code != 204:
            break

        time.sleep(120)
    return plan.json()


MOCK_PLAN_FILE = os.getenv('MOCK_PLAN_FILE', 'mocks/pass.json')


@pytest.fixture(scope="session")
def generate(request):
    marker = request.node.get_closest_marker("mode")
    if marker == 'remote':
        run_id, plan_id = test_utils.plan()
        assert plan_id
        plan = test_utils.show(run_id)
        yield plan
    else:
        with open(MOCK_PLAN_FILE, 'r') as f:
            yield json.load(f)


@pytest.fixture(scope="session")
def resource_changes(generate):
    return generate['resource_changes']


@pytest.fixture(scope="session")
def planned_values(generate):
    return generate['planned_values']


@pytest.fixture(scope="session")
def root_module_resources(planned_values):
    return planned_values['root_module']['resources']


@pytest.fixture(scope="session")
def child_modules(planned_values):
    return planned_values['root_module']['child_modules']


@pytest.fixture(scope="session")
def resource():
    def _get_resource(resource_changes, resource_type):
        resources = []
        for resource in resource_changes:
            if resource['type'] == resource_type:
                resources.append(resource)
        return resources
    return _get_resource


@pytest.fixture(scope="session")
def vpc_module(child_modules):
    for module in child_modules:
        if module['address'] == 'module.vpc':
            return module
    return None


@pytest.fixture(scope="session")
def vpc_subnets(vpc_module):
    return [resource for resource in vpc_module['resources'] if resource['type'] == 'aws_subnet']


@pytest.fixture(scope="session")
def private_subnets(vpc_subnets):
    return [subnet['values'].get('id') for subnet in vpc_subnets if not subnet['values']['map_public_ip_on_launch'] and subnet['values'].get('id') is not None]
