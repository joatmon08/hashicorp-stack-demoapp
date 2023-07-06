import pytest
import warnings

@pytest.fixture
def vpc_module(child_modules):
    for module in child_modules:
        if module['address'] == 'module.vpc':
            return module
    return None

@pytest.fixture
def private_subnets(vpc_module):
    private_subnets = []
    for resource in vpc_module['resources']:
        if resource['type'] == 'aws_subnet' and not resource['values']['map_public_ip_on_launch']:
            if resource['values'].get('id') == None:
                continue
            private_subnets.append(resource['values'].get('id'))
    return private_subnets

@pytest.fixture
def kubernetes_cluster(resource_changes, resource):
    return resource(resource_changes, 'aws_eks_cluster')[0]

def test_kubernetes_cluster_should_be_in_private_subnets(private_subnets, kubernetes_cluster):
    cluster_subnet_ids = [subnet for vpc in kubernetes_cluster['change']['after']['vpc_config'] if vpc.get('subnet_ids') is not None for subnet in vpc.get('subnet_ids')]
    if len(cluster_subnet_ids) == 0:
        warnings.warn('No Kubernetes VPC configuration generated yet')
    if len(private_subnets) == 0:
        warnings.warn('No VPC subnets created yet')
    assert all(subnet in private_subnets for subnet in cluster_subnet_ids)