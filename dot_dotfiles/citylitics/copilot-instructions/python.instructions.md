---
applyTo: "**/*.py"
---

- Python 3.9
- Google style docstrings
- Add type hints to function params and return types to code that you modify. Do not add type hints to unedited code.
- only write tests in "app/tests" (use pytest and pytest-django, don't use unittest nor django.test.TestCase)
- `reorder-python-imports` for ordering imports (don't use isort)
- When logging, define `logger = logging.getLogger(__name__)` at the top of the file and use `logger.debug()`, `logger.info()`, etc.
- prefer docstring single line comments over inline `#` comments (so it appears on hover in IDEs)

## Type hints

- use `list` instead of `List` from `typing` (same for `dict`, `tuple`, `set`, etc.)
- don't import or use `Any` from `typing`
- Use `Union` and not `|` for union types (because we use Python 3.9)

## Django

- Django 3.2
- Django model choices: use TextChoices instead of tuples
- use drf `Response` instead of `JsonResponse` for API responses
- Django ORM: minimize the number of database calls
- import ValidationError from `django.core.exceptions`, not from `django.forms`
- URLs and the path name should be in snake case

## Database

- We use MySQL 8.4 and SQLite in tests
- we don't use Postgres
