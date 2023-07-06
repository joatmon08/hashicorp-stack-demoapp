import pytest
import requests
import os
import boto3
import hcl2
from botocore.config import Config

TERRAFORM_VARIABLES_FILE = 'terraform.auto.tfvars'


@pytest.fixture(scope="session")
def tfvars():
    with open(TERRAFORM_VARIABLES_FILE, 'r') as f:
        return hcl2.load(f)


@pytest.fixture(scope="session")
def aws(tfvars):
    config = Config(
        region_name=tfvars.get('region')
    )

    return config


@pytest.fixture
def eks(aws):
    return boto3.client('eks', config=aws)


@pytest.fixture
def rds(aws):
    return boto3.client('rds', config=aws)


def test_hcp_consul_available():
    addr = os.environ['CONSUL_HTTP_ADDR']
    response = requests.get("{}/v1/status/leader".format(addr))
    assert response.status_code == 200


def test_hcp_vault_available():
    addr = os.environ['VAULT_ADDR']
    response = requests.get("{}/v1/sys/health".format(addr))
    assert response.status_code == 200


def test_hcp_boundary_available():
    addr = os.environ['BOUNDARY_ADDR']
    response = requests.get(
        "{}/v1/auth-methods?scope_id=global".format(addr))
    assert response.status_code == 200


def test_kubernetes_available(tfvars, eks):
    response = eks.describe_cluster(
        name=tfvars.get('name'),
    )
    assert response['cluster'].get('status') == 'ACTIVE'


def test_postgresql_available(tfvars, rds):
    response = rds.describe_db_instances(
        DBInstanceIdentifier="{}-{}".format(tfvars.get('name'), 'products'),
    )
    assert len(response['DBInstances']) == 1
    assert response['DBInstances'][0]['DBInstanceStatus'] == 'available'
