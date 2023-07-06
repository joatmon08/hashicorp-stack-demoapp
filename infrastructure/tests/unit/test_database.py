import pytest
import re


@pytest.fixture
def databases(root_module_resources):
    return [resource for resource in root_module_resources if resource['type'] == 'aws_db_instance' and resource['values']['engine'] == 'postgres']


def test_postgresql_passwords_meet_minimum_conditions(databases):
    password_pattern = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{9,}$"
    weak_password = [database['values'].get('id') for database in databases if re.match(
        password_pattern, database['values'].get('password')) is None]
    assert len(weak_password) == 0, "databases {} have weak passwords".format(
        weak_password)
