import pytest
import hcl2

NETWORK_FILE = 'vpc.tf'


@pytest.fixture(scope="module")
def terraform_configuration():
    with open(NETWORK_FILE, 'r') as f:
        return hcl2.load(f)


@pytest.fixture
def vpc_module_configuration(terraform_configuration):
    return terraform_configuration['module'][0]['vpc']


@pytest.mark.no_deps
def test_configuration_for_vpc_enables_dns_hostnames(vpc_module_configuration):
    assert vpc_module_configuration['enable_dns_hostnames']


@pytest.mark.no_deps
def test_configuration_for_vpc_uses_data_source_for_azs(vpc_module_configuration):
    assert 'data.aws_availability_zones' in vpc_module_configuration['azs']


def test_vpc_subnets_have_correct_netmask(vpc_subnets):
    wrong_subnets = [subnet['values'].get('id') for subnet in vpc_subnets if not subnet['values'].get(
        'cidr_block').endswith('/24')]
    assert len(
        wrong_subnets) == 0, "subnets {} should have /24 CIDR block".format(wrong_subnets)
