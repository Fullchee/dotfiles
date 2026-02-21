---
applyTo: "**/tests/**/test_*.py"
---

- only write tests in "app/tests" and not in modules' own tests folders
- use pytest and pytest-django
    - Don't use unittest
    - Don't use django.test.TestCase
- Run tests with `docker-compose -f local-dev/docker-compose.yml run --rm django pytest path/to/test/file.py -s -vv` and not with `pytest` directly

- don't add `logger = logging.getLogger(__name__)` to test files
- test functions should not have docstrings, the name should be descriptive enough
- use fixtures instead of setUp/tearDown methods
- always pass in tzinfo=timezone.utc to fake.date_time(tzinfo=timezone.utc) in tests to avoid AmbigiuousTimeError
- use factories to create test data, don't create model instances directly
- only use pytest.mark.django_db when the test actually needs database access
- use from rest_framework.status codes instead of numeric numbers
- use existing client fixtures instead of creating Client() instances directly
- URLs in `api_urls.py` should be namespaced with `api:` prefix, e.g. `api:target_reports:initiative-type-list`
- don't explicitly import pytest fixtures, just use them as function arguments
- don't type hint return types of test functions

Test names/statements should follow a behavioural structure - depending on which is more clear in the given context:

- [area/component] - [subject] [action] ?[target] ?[result]
- [area/component] - [target] ?[result] ?[action] [subject]

Example

```python
class class TestEmailGenerationOutputAPI:
    def test_assigned_users_are_accessible_to_all_users_except_sales_users(self):
        pass
```

where

- area/component - TestEmailGenerationOutputAPI
- target - assigned_users
- result - are accessible
- subject - all users except sales_users
