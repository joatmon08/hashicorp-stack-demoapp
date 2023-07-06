import pytest
import hcl2

NETWORK_FILE = 'vpc.tf'


@pytest.fixture(scope="module")
def terraform_configuration():
    with open(NETWORK_FILE, 'r') as f:
        return hcl2.load(f)


@pytest.fixture
def vpc_module(terraform_configuration):
    return terraform_configuration['module'][0]['vpc']

@pytest.mark.no_deps
def test_configuration_for_vpc_enables_dns_hostnames(vpc_module):
    assert vpc_module['enable_dns_hostnames']

@pytest.mark.no_deps
def test_configuration_for_vpc_uses_data_source_for_azs(vpc_module):
    assert 'data.aws_availability_zones' in vpc_module['azs']
