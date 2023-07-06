import pytest
import json
import test_utils


@pytest.fixture(scope="module")
def generate():
    run_id, plan_id = test_utils.plan()
    assert plan_id
    plan = test_utils.show(plan_id)
    yield plan.json()['data']['attributes']

@pytest.fixture
def resource_changes(generate):
    return generate['resources_changes']

def test_kubernetes_cluster_should_be_in_private_subnets(resource_changes):
    assert resource_changes == 'test'
