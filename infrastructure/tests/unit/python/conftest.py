import pytest
import json
import test_utils

PLANNED_STATE_CONFIGURATION_FILE = 'plan.json'

@pytest.fixture(scope="session")
def generate(request):
    marker = request.node.get_closest_marker("mode")
    if marker == 'remote':
        run_id, plan_id = test_utils.plan()
        assert plan_id
        plan = test_utils.show(run_id)
        yield plan
    else:
        with open(PLANNED_STATE_CONFIGURATION_FILE, 'r') as f:
            yield json.load(f);


@pytest.fixture
def resource_changes(generate):
    return generate['resource_changes']

@pytest.fixture
def planned_values(generate):
    return generate['planned_values']

@pytest.fixture
def child_modules(planned_values):
    return planned_values['root_module']['child_modules']

@pytest.fixture
def resource():
    def _get_resource(resource_changes, resource_type):
        resources = []
        for resource in resource_changes:
            if resource['type'] == resource_type:
                resources.append(resource)
        return resources
    return _get_resource