from starlite import Starlite, MediaType, get


@get(path="/", media_type=MediaType.TEXT)
def heythere() -> str:
    return "Hello, ApPsNaPpEr"

@get(path="/snapped", media_type=MediaType.TEXT)
def health_check() -> str:
    return "up-snap appsnappr"


app = Starlite(route_handlers=[heythere, health_check])


if __name__ == '__main__':
    ...
