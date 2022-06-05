# Secure Local or FQDN Nginx-Letsencrypt, Development and Production Toolchain

Launch a secure site with a single command within moments of obtaining the code, for local development, or for production, using your registered fully-qualified domain name.

## Features:

- Local secure site certificate generation and mapping.
- Automated Let's Encrypt certificate renewal for remote sites or those using a FQDN and dynamic DNS services.
- No service description requirement, making use of docker's restart policy.
- Quick turnaround with few details to provide.
- Top level edits for low level results.
- One stop image staging, naming, or optional upgrading.

This repo is a companion extension to the article where core code usage is explained: 
[Dockerize NGINX to Let's Encrypt](https://ilhicas.com/2019/03/02/Nginx-Letsencrypt-Docker.html)

# Build, run, and host -- secure local, secure remote 

## Initial configuration and quickstart
> `.env`

Minimal changes to this file are necessary and mostly self-explanatory.

Any change you make to the FQDN should be reflected in the host's (the computer running the docker containers) hosts file:

Your hosts file will have one to several entries. The loopback addresses range from 127.0.0.1 - 127.0.0.8, and it is likely one of these is free to use. To be fair, the real range of reserved addresses for loopback is 127.0.0.0 – 127.255.255.255, but you'll conventionally see the first range mentioned.

The FQDN entry made in `.env` (without a subdomain prefix) will be paired in the hosts file with a local loopback:

```
127.0.0.5       appsnappr.com
```

Access and edit your hosts file on Linux like so:

```
sudo nano /etc/hosts

```

Upon saving the hosts file, the change should be instantaneous for any new lookups. 

The project should now be accessible and will route requests to use TLS. 

If the FQDN you chose is registered and through a DNS lookup points to a hosted IP, prepare to see someone else's site.

There should be no need to tag on a secure port, or use the https:// scheme; just the FQDN, like `appsnappr.com`.

> NOTE: Though completely unnecessary, for the purposes of this project, `appsnappr.com` is presently a registered, parked domain. So, from June 2022 through to June 2023, by making the hosts file change alone, this project can be run locally, providing a named resource served over TLS-enabled HTTP. Lookups to Internet Domain Name Servers (DNS) will fall back on the hosts file definition.
>
> Knowing more about IP routing may help you strategize other loopback scenarios using IPs alone for the FQDN. Calling your site in the browser would then require entry of an IP address in your browser's address bar.

## Persistence

This step isn't exactly necessary, but it may be a bit clearer once it is done.

So, upon any change to the PROJECT_TAG, make a directory with its exact name in the same root as `.env`, following the prefix convention of the folder `._appsnappr (._)`. Once a custom name has been settled on, this folder can be deleted before the project is brought up. Since the project runs all of its containers as the `root` user persisted volumes can not be deleted without `sudo`, and these cause trouble for backups. Consequently, `.gitignore` is set to honor the special prefix mentioned above, to avoid sending the directories contained within the persisted volume. If `rclone` is used, it is easiest to create a `cron job` and persist logs and other relevant data from containers in the background. Much of this is out of scope for this implementation, and there is no pip installable version of it, though, it should be mentioned, PHP, GO and Node developers (and others), will be able to make use of the basic setup to get a leg up on developing and later hosting their dynamic content projects securely, out of the box.

## Choosing the staging in `.env`

Once you open `.env` it should be readily apparent what to do with the so-called `quadlets`. The default selects development, and this is the one you would overwrite, or replicate, making sure `STAGE` is `dev`, as would match the override template engaged to launch alongside `docker-compose` (it is this template, using a dot delimeted filename, which indicates which STAGE is selected -- when uncommented), and the template itself that provides the environment variable and value for conditional code generation, the magic behind appsnappr's implementation of domain name flexibility. It's not too complicated, just very spread out for such a contained grouping of files, meaning tons of time can be saved. A quick look through its files should help.

The mode should be staging, a stage with the name 'dev'.

Being local to a machine which does not require Let's Encrypt for a FQDN and that has a working Internet connection, run `docker-compose up` to build and test the localhost project.

Make changes to site as you feel necessary.


## Stages: docker-compose overrides

Overrides use three complementary mechanisms that make it possible to use the singular `docker-compose` command to config, build, and launch various stages: 

- COMPOSE_FILE variable definitions which provide pancake-style file mappings; found in `.env', in the project root;
- docker-compose overrides (though not the canonical `docker-compose.override.yml` which would automatically map to docker-compose.yml on launch were it in the root directory alongside that file);
- Selective `env_file:` stacking in stage override files within service descriptions, leveraging that key's layered environment variable override logic.
  


> `env_file:`

secrets and environment variable exports
- a single '.secret.env' file is easiest to maintain
- a single file per stage means values are exported to any service that lists them
- all secret keys are presently shown with defaults in '.common.env', listed in first position wherever used in a stage override
    - 'env_file:' arrays overwrite values top to bottom, repeitions read last being the accepted value
    - 'env_file: arrays add keys and their values for those that don't exist in the chain



- presently, only postgresql is the same throughout stages, unless user and pass are changed, then the database will require a corresponding user and pass change via psql, or it will have to be rebuilt using docker-compose and the service description. which is a happenstance of moving between stages anyway. This is mentioned in the event the environment for both development and production is the same, as building from a single compose file will rebuild all assets. If the data is to be saved workaround research may be necessary.

Before changing any environment variables, it's recommended you first build the `proxy` service locally. See the commands below.

Then, build the `site` service.

You can build all services at once and bring the project up by casting:

`docker-compose up`

Check the starter host `appsnappr` redirects to TLS using secure port 443 when trying to access `appsnappr.com` in the browser. As is the case with self-signed certificates, a warning is issued by the browser.

Choose advanced and follow the instructions, accepting the certificate as valid. Next, the simple endpoint 'Hello, World' should load.

In this development mode, if you did not use the `-d flag` to `docker-compose up`, you can watch the each service's output in the terminal. The Python project will reload the `site` service if you make changes to the files in the project folder. The production site copies all files necessary into the container, so reloads don't happen. This feature is also recommended to be switched off with your choice of server workers, ie. uvicorn or gunicorn. There will still be files in the virtual environment directory but they can no longer be changed during runtime unless you enter a container and change them, a move which does not persist if you happen to rebuild the container in question. Your CI pipeline may help you with versioning, so your task might be configured to delete project files from the server once the container is built. Practices vary, so you might want to check around.

--- Note: spaces only between services listed following `up`, `down`, `build` or `restart`, but Docker will tell you that ---

## Build one, multiple or all service(s):

_ all
  
`docker compose build`

_ one (remove <>)

`docker compose build <service>` 

_ multiple; space separated list of service names

`docker compose build <service service service>` 

## Lauch existing or build non-existing containers for one, multiple or all services, as above;

`docker-compose up <service>`

# Customizing 

The `.env` file in the root directory of the project is key.

Docker exports the variables listed here to all docker container service environments running under the same docker-compose service description instance, all of which lease LAN IPs from dockers DNS, always at 127.0.0.11. 

Custom code written by other developers and altered for use in this project is used to manage the interpolation of environment variables into a `nginx.conf.template`, to produce a working configuration file. A different internal name is used, but the idea is the same. See `endpoint.sh` and feel free to clean up the deluge of commented code there. Writing this now, I can predict it will still look a mess in the far-flung future, when people merge with their identity waves spontaneously and traverse the universe on solar radiation in search of BRAINSSS!!!! Heck if the code is going to be a mashup, why not the pop culture references to indoctrination tropes for nervous people with an itch?

Customization beyond `FQDN`, `ADMIN_EMAIL` and the various images listed in `.env` destined for the runtime `nginx.conf` are very possible. The `AS_` prefix is a handy means of consolidating variables you might want to use in your own custom Nginx template. So long as your variables are environment variables to the `proxy` service, and you use the prefix, you will be able to follow the convention of placing dollar references `${AS_NEW_PROXY_VARIABLE}` and have the Nginx configuration interpolate the values into place to produce the working configuration mentioned above when you build the container following changes to any of the relevant files.

The file `endpoint.sh` safely gets around a measure `nginx` uses to prevent external environment variable insertion. Variables from environment are interpolated to string values before nginx.conf is used by nginx, so only the hand behind launching the project may influence variable insertion -- between run sessions, never during. 

From this, you can add more variables to `.env`, making `enpoint.sh` aware of what it must pick up on to insert at corresponding 'dunder' insertion points in `nginx.conf.template`. Keeping the double underscore, upper case convention makes variables easy to spot.

Further, `nginx.conf.template` may be edited to include new routes and other server logic, however, to retain remote host certificate generation and validation which uses Let's Encrypt and its related DNS challenge method, there are two things that must remain immutable (within logical reason):

- The proxy service description and .sh script-referenced volume where certificates are saved between refreshes should not be removed from the description of the volume in the `proxy` service definition;


- The route `.well_known_challenge` in the `nginx.conf.template` needs to exist. The template can be edited to include other logic, as mentioned above, but removing the route will prevent Let's Encrypt from generating and saving certificates germane to running a secure site operating on port 443.

Out-of-the-box build magics between Dockerfile and `docker-compose` are used to name final stage images and allow for seamless version upgrades thereafter. 

On changes to base images for one or more services in the `.env` file, the simplest way to instantiate them is to enter the root directory where `docker-compose` lives, run `docker-compose down`, and follow this by `docker-compose up`. All services should rebuild. Check with `docker images list`

Changing IPs in the docker-compose file under any service description is not covered here. As it is, `ports:` and `expose:` are used to fine tune internal:external, or internal-only service availability, with expose:` revealing a service to its LAN contemporaries, not to the WAN.

An override of a common setup reveals this. Default `postgres` container setup recommendations show a `ports:` mapping, but even if you were to use `pgadmin` to administer the database, only `pgadmin` would need to be accessible outside the docker network, the two services would communicate on the LAN. As it stands, the project shows this internal relation between `site` and `postgres`. `site` runs behind the nginx service `proxy` and is never accessible external to the docker DNS-managed network, `site` communicating internally with `postgres`. `links:` are used as the alternative to `depends-on`. `restart:` sets individual service restart conditions, doing so with further restart context interpreted through each service's annotated `links:`.

[Understanding the Nginx Configuration File Structure and Configuration Contexts](https://www.digitalocean.com/community/tutorials/understanding-the-nginx-configuration-file-structure-and-configuration-contexts)

[Secure the Nginx Server with Let's Encrypt SSL](https://www.interserver.net/tips/knb-category/nginx/)

# Pull requests (or, better, forks) sought for Nginx template param includes detailing requirements for other service configurations and routes (locations)

Many setups are possible. The Nginx template is not overly complex, or particularly relevant to all cases by being general and robust enough to anticipate hosting similarities and the points at which the criteria are most divergent. So, developers who wish to help others using `appsnappr` are encouraged to share modular bits of configuration, as with `proxy_params`, `uwsgi_params`, `secure_params`, files you'll find in the `proxy` docker service folder, the `appsnappr` core, if you will.

Pull requests for this sort of addition are welcomed, though a fork featuring your well-tested specializations might make life easier for everyone, ensuring that the base conditions and features are well documented. Hit me up so a link can be provided offering more detail than diving through all the forks can give. As there are many webservers out there and they are increasingly moving to plug-and-play over many common setups, repo traffic may be light, so for many common things, it might be best to consider this project 'intermediate' and its developer 'not in the office' for tech support. 

The number of links attached to this verbose READ.me should tell you something about who's really running the show, and you might be one of those persons; and the number has been severely cut back from the real box-stuffing number of bookmark links and bleary-eyed traversals of the Interwebs. So, really, thank you. If you use this, tell someone else, and they may also be able to help you if you want to extend it. This is a good opportunity to give a shout-out to StackOverlow and the amazing and talented people around the world who find their way there and leave behind bits, chunks and mountains of searingly relevant content. Thank You.

# Docker stuffs

Docker DNS at 127.0.0.11 leases IPs to each service in the docker network. Discovery is available via docker CLI.

In the above context using `docker compose down` will purge all containers and delete the common network. Knowing this is useful for debugging containers if changes are made to ports, or other network mappings such as the name of a service. Changing the name of a service while containers are running will create orphan containers might have to be pruned with `docker container prune` since for each call to `docker-compose <up, down, build, restart, etc.>` the compose file is referenced.

# Host stuffs - mostly about opening ports to let the traffic 

For Linux users, `iptables`, or, far simpler, `ufw`.

TCP ports 80 and 443 should be added as allowed with ufw enabled on the host of your docker container project.

If it's Windows, it's likely doable, and probably just as simple, but no information has been gathered to provide information here. If you feel it is important, please feel free to put in a pull request.

# Operational stuffs

## Simple monitoring via terminal

Two top-level views of what parts of the project are running: 

`docker ps`

`docker stats`

## Development using a volume bind mount

The micro-service container 'site' listed in `docker-compose.yml` uses a bind mount on the current working directory `${PWD}`. 

Set to `--reload` in the service's command, Uvicorn, the ASGI server/worker, will refresh your project. 

In development, as a matter of convenience, running containers from a terminal window outside the IDE is recommended. 

> TIP: You might consider tooling like pyenv or a virtual development environment if the Python version of the Linux distribution you are coding with differs from that of the one you've decided `site` should use to run code that will be hosted behind the `nginx proxy`. To debug code using your IDE in the event the container version is newer than the development host intentionally craft code to conform to the oldest version in the setup. 
 
The likeliest scenario is the Python version accessible to the IDE will lag behind the container version. Use a shebang `#! /usr/bin/python3.x` at the top of each module as a reminder of the lesser version. One other alternative depends on features available in the IDE to run a virtualized interpreter session. In all cases, if the containers are running and code is changed, Uvicorn will delay for a moment until the changes are picked up and then reload. 

Changes to a locally secure nginx implementation may require you to delete the nginx directory, or to chown the offending directory, so that it may be accessed again for the next debugging cycle. Automating one approach or the other with a shell script could be useful.

Some of the options related to development, the `--debug` switch, for instance, or the use of the `-d; --detach` flag on docker-compose launch, are manual settings which you may wish to change moving the code from development to production.

### Alternate container debugging using the IDE

[VSCODE: Build and run a Python app in a container](https://code.visualstudio.com/docs/containers/quickstart-python)

[Using a Docker Compose-Based Python Interpreter in PyCharm](https://kartoza.com/en/blog/using-docker-compose-based-python-interpreter-in-pycharm/)


## Linux readiness

`sudo apt-get install docker.io docker-compose`

Add current user to the docker group:

`usermod -a -G docker $USER`

Launch all services of the project (remote or local, depending on your site's exposure):

`docker-compose up -d` 

## Troubleshooting, other

Resolve the docker-compose file, interpolating all variables.

`docker-compose config` 

`groups`

`stat /var/run/docker.sock`

`ps aux | grep dockerd`

`docker ps`

`docker stats`

`docker --help`

`alias group='cut -d : -f 1 /etc/group'`

`alias users='cut -d : -f 1 /etc/passwd'`

### A single file per stage means values are exported to any service that lists them.

### All secret keys are presently shown with defaults in '.common.env', listed in first position wherever used in a stage override.

## Deployment, other

[Uvicorn Docs: Running Behind nginx](https://www.uvicorn.org/deployment/#running-behind-nginx)

[Gunicorn](https://docs.gunicorn.org/en/stable/deploy.html)

[Daphne](https://github.com/django/daphne)

### Static IP routing for a VPS or non-fixed IP endpoints with fixed domain names using dynamic DNS, either from a DNS service provider:

[DNS/Dynamic DNS Provider, Zoneedit](https://www.zoneedit.com/) 

[ZoneEdit: Common DNS Terms](https://support.zoneedit.com/en/knowledgebase/article/glossary-of-common-domain-and-dns-terms)

### VPS Hosting Providers

[Amazon.com Lightsail](https://aws.amazon.com/lightsail/)

[Interserver.net](https://www.interserver.net/vps/)

[DigitalOcean.com](https://www.digitalocean.com/solutions/vps-hosting)

[Lightsail tutorial, including docker desktop setup on Mac: ~15min](https://youtu.be/7Tn8icO-dOk)

# Not Explored

## End-to-end encryption

Notice the `nginx.conf` file refers to the docker DNS discoverable service name in the `location directive for "/"` in the secure site description, but that its scheme as proxy is `http`. 

On Linux this could be replaced by a Unix socket, or certificates could be supplied to the Uvicorn service worker to which this proxy refers. 

`Uvicorn` serves ASGI application instances reachable by, default, at `port 8000`.

Port 8000 is only specified in the nginx.conf proxy mapping.

In docker-compose, under the service `site`, the uvicorn command specifies a universal host, and `--debug=True`.

## Dynamic DNS

To use this in a remote to proxy a FQDN, it is necessary to register a site name. The destination of hostname to IP mapping must be discoverable by DNS.

This project can run where a hosted IP terminates, or it can run on a qualifying device having a dynamically assigned IP provided, in this latter case, a dynamic DNS service broadcasts the mapping in sufficient time for changes to the endpoint IP for it to be picked up by devices seeking to connect via the known mapped name, the FQDN.

What hasn't been explored here is how you might use a forwarding service to host your FQDN without the need for a self-managed VPS, using, for instance, a Raspberry Pi, home network computer, smart router, or other devices having compatible software, and connection modes as those examples.

# Tooling around with Docker for this 'build

Ran into some troubles and found that some of the observations made along the way might come in useful to someone using this project to get a head start on their development. It's not some framework authentication scheme with database, but a secure site in a minute on which to hang your own code isn't a bad thing... or is it?

Part way through retooling the original docker-composed based port of Ilhicas' codes, my eye got caught by an older implementation of `extends:`, a keyword approach which, at the time I was reading the unversioned example, I did not know was not only old, but outright deprecated -- since docker-compose version 2.1.

That was 30 minutes of my life I won't get back, and another 30 unraveling newly discovered quirks in interpolation I had to that point also not been aware of. 

But learning is fun, and the task was greatly simplified by Nginx features which have come around since version 1.19 catering to many codes using envsubst from bash files to create template files that pass along environment variables.

The method is loosely documented on the Nginx Docker Hub page.

Sadly, extends features were reduced into version 3, ending at version 2.1 extends syntax that would allow segmented and conditional substitution and mergers with services. A pancake method using the official docker-compose-overrides.yml file appears to have been chosen as the official replacement

So, how to get around the pancake?

What is the pancake? And who said CI/CD could do that to coding folks anyhow?

The pancake gets honorable mention because catering to by Docker developers by way of a clear set of docker-compose interpolation rules over keyed values is likely rooted in evolving CI/CD standardization and the zeitgeist of yaml-like service descriptions from Ansible to Red Hat and IBM *all sort of glommed together officially, not to mention flavors of git and other development, validation and deployment pipeline services and infrastructure. `extends:` in that context was only ever really a little guy looking up at the stars soon to be wondering why they all turned out to be alien landing craft. But that's a story for another universe of streaming television. Please, just don't let knowing that take you away from reading the growing spread of documentation and watching all the explainer videos from eople who haven't watched so much TV, but instead decided to devote every waking moment to consolidating what could otherwise be seen as a disinformation of transparency, the opaque nature of 140 browser tabs to explain one quotation mark out of place... you know what I mean even if you haven't exactly done this yourself. Just try not to open a novel of paragraphs surrounded by advertising spread across a threadbare horizon of pins and sliding lists held to one meager line...

...because CI/CD pipeline debugging would be easier with known substitution behaviours. So, with the pancake method, a compositional launch appoach like `~$ docker-compose -f docker-compose.yml -f some-other-compose.yml` makes it impossible to simply change one .env variable to get the desired staging arguments as conditionally dependent segments from one other file. Multiple files must be kept, each exclusive to its own stage using documented override behaviour. 

Docker developers decided an override file with a specific name would be read in on a docker-compose launch if it exists in the same directory as the launch file. Clever methods to glean project run state from this pair is probably why the official documentation mentions the method above. Where pancaking doesn't fail to impress with docker-compose is it's use in build: under the key `cache_from:`, and this is the primary feature which this project uses that prevents rollback to version 2.1. The feature wasn't available until somewhere around docker-compose version 3.4. Using it, you can define the primary image on which your service will be based, likely a pull from the Docker Hub repository, and stack the `cache_from:` images to reflect this choice, making the top image in that list reflective of the image you'd like to build. It will get the name you've put there, and you can see this in the list of docker images, from the CLI; `docker images`. From then on, unless you specifically build the project again, and the original Dockerfile has changed, the built image will be chosen. It's a great feature. If you change the input for the image and it's also the final cached image, the whole chain builds again, making versioning a snap.

So, to version a service image, all you have to do is edit the reference to the prime image in the `.env` file next to the docker-compose file (always now officially the project's root folder), and build. It's up to you to differentiate a version tagging system from the PROJECT_TAG variable which, for this implemention, is really the project name which goes down the chain. But that change is simple. Just add a <service>_VER=sometag to `.env`, and populate `cache_from:`, though the simplest way to keep versions is to retag them before uploading them to the Docker Hub repository, should the need arise for you to refer back to project history. 

The intent of the project isn't to get too detailed about approaches diverging from getting Nginx up and running locally or remotely using secure certificates generated locally or obtained using one of the ACME challenge methods made available by Let's Encrypt. If you desire to reduce these words in volume by extending (no pun intended) features which simplify staging and versioning in ways that use project-specific modalities in obvious and revealing ways, mainly using `.env`, `.env_file:` and other environment variable round tripping, please drop me a line before you decide to put in a pull request. If you suggest a feature via Github -- where this project is hosted -- please be prepared to put in some time to develop it. It might otherwise be fun to scavenge any forks for ideas, but a central place for best features and practices might be better. In short, this project relying on your expertise is probably going to serve it and any community that comes to it better than these relying on mine.

While, from a soggyily bespoke perspective, it might be great if both `extends:` methods were to coexist in the Dockerverse without adding to confusion, it is unlikely the older `extends:` feature syntax will be coming back. Owing to new features that make life easier, versioning a docker-compose file back to 2.1 would take a lot more rework than catering to a pancake stack, and composing 'dev', 'prod', 'ci' pipeline launches using this officially sanctioned method from the CLI: `~$ docker-compose -f docker-compose.yml -f some-other-compose.yml`

A consensus reached by the Docker developers on limits to interpolation is summed by, "Compose only does variable interpolation in values, not keys." -- See Daniel's comment [here](https://github.com/docker/compose/pull/3108#issuecomment-248038373).

REFERENCES:

[Docker: version 3 -- feature changes, removals and additions](https://docs.docker.com/compose/compose-file/compose-versioning/#version-3)

[Docker: Overview of docker-compose](https://docs.docker.com/compose/)# a single '.secret.env' file is easiest to maintain

    # 'env_file:' arrays overwrite values top to bottom, repeitions read last being the accepted value
    # 'env_file: arrays add keys and their values for those that don't exist in the chain

[Docker: Dockerfile](https://docker.com/dockerfile)

[Docker: docker-compose, extends:, to version 2.1](https://docs.docker.com/compose/extends/)

[Docker: docker-compose, extends:, understanding the use of multiple compose files](https://docs.docker.com/compose/extends/#multiple-compose-files)

[Docker: docker-compose, using the special variable "compose_file" to set sequenced file project launches according to staging semantics, to effect simple 'dev', 'prod' and 'ci' overrides and automated command line 'pancaking'](https://docs.docker.com/compose/reference/envvars/#compose_file)

[Docker: environment variables, interpolation, variable substitution](https://docs.docker.com/compose/environment-variables/)

[How to pass arguments to entrypoint in docker-compose](https://stackoverflow.com/questions/37366857/how-to-pass-arguments-to-entrypoint-in-docker-compose-yml#41968585)


[Gunicorn: settings](https://docs.gunicorn.org/en/stable/settings.html)



###### Ambiguity is the face and friend of money, unless you must pay its bill.
##### Always read the fine print to see who will win at laughter.
##### Make love to war until trenches are dug, stopping well before coffin makers are allowed to work overtime.
##### May any steps you take into the night lead you to find the breaking dawn of a new day.
