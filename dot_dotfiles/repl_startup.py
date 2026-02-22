from functools import partial

try:
    from rich import inspect, pretty, print, traceback

    help = partial(inspect, help=True)
    pretty.install()
    traceback.install()
    print("rich setup concluded.")
except ImportError:
    print("pip install rich to get a prettier CLI experience")
