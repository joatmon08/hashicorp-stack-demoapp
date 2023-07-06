import pytest
import warnings
import requests
from packaging import version


@pytest.fixture
def kubernetes_cluster(resource_changes, resource):
    return resource(resource_changes, 'aws_eks_cluster')[0]


@pytest.fixture
def kubernetes_cluster_subnet_ids(kubernetes_cluster):
    return [subnet for vpc in kubernetes_cluster['change']['after']['vpc_config'] if vpc.get('subnet_ids') is not None for subnet in vpc.get('subnet_ids')]


def test_kubernetes_cluster_should_be_in_private_subnets(private_subnets, kubernetes_cluster_subnet_ids):
    if len(kubernetes_cluster_subnet_ids) == 0:
        warnings.warn('No Kubernetes VPC configuration generated yet')
    if len(private_subnets) == 0:
        warnings.warn('No VPC subnets created yet')
    assert all(
        subnet in private_subnets for subnet in kubernetes_cluster_subnet_ids)


def test_kubernetes_cluster_version_should_not_be_latest(kubernetes_cluster):
    kubernetes_release_details = requests.get('https://api.github.com/repos/kubernetes/kubernetes/releases/latest', headers={
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28'
    })
    kubernetes_latest = version.parse(
        kubernetes_release_details.json().get('tag_name'))
    cluster_version = version.parse(
        kubernetes_cluster['change']['after'].get('version'))
    assert cluster_version < kubernetes_latest
