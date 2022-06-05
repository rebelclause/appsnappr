import os
from starlite import Starlite, MediaType, get

PROJECT_TAG=os.environ.get("PROJECT_TAG")

@get(path="/", media_type=MediaType.TEXT)
def heythere() -> str:
    return f"Hello, {PROJECT_TAG}"

@get(path="/snapped", media_type=MediaType.TEXT)
def health_check() -> str:
    return "UP_SNAP {}".format(PROJECT_TAG)

@get(path="/ssnaped", media_type=MediaType.TEXT)
def health_check_1() -> str:
    return "up-snap %s" %PROJECT_TAG 

app = Starlite(route_handlers=[heythere, health_check, health_check_1)

if __name__ == '__main__':
    ...
