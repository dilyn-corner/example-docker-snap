# What is this?

This is an example snap which leverages the Docker snap distributed by Canonical
to use the docker binaries for its own purposes.

Specifically, this example snap demonstrates simple examples for what potential
use-cases might be.

## Building

You'll need `git`, `snap`, and `snapcraft`, along with the `docker` snap.

```
$ git clone https://github.com/dilyn-corner/example-docker-snap
$ cd example-docker-snap
$ snapcraft
$ snap install --dangerous ./tocker_*_amd64.snap
```

Then, simply connect the interfaces and run the snap.

```
$ snap connect tocker:docker docker:docker-daemon
$ snap connect tocker:docker-executables docker:docker-executables
$ tocker hello-world
```

## Explanations

### Running a Docker image

The simplest use-case is merely running `docker run $img`. If this is all we
want our snap to do, then a minimal `snapcraft.yaml` looks like:

```
name: tocker
base: core20
version: '0.1'
summary: A test of interacting with the Docker snap through another snap
description: |
  This snap moves a Docker-based workflow to a snap'd environment on Ubuntu
  Core. This snap shows how one would interact with the docker snap, namely
  through a content sharing interface to gain access to the docker executable,
  along with a simple script to call the docker executable.

grade: stable
confinement: strict

apps:
  tocker:
    command: usr/bin/tocker_run.sh
    plugs:
      - docker

parts:
  copy-script:
    plugin: dump
    source: src/

plugs:
  docker-executables:
    interface: content
    content: executables
    target: $SNAP/docker-bin
```

Going over this in section-order:
We setup some logistical information about our snap; the name, the version, the
base it sits on, a simple summary and description, along with some confinement
standards (we immediately opt for strict because we know there are only two
interfaces we're going to need).

We define our apps; in this case we only have the one, and it's our primary
application which will run `docker run $@`. We also add a plug to this app; the
`docker` plug allows a snap to use manage Docker containers. For more
information, see [the
documentation](https://snapcraft.io/docs/docker-interface). Note that neither of
the interfaces we'll be usingn are auto-connecting.

The application itself is defined by a parts section; here we use the dump
plugin to move our `tocker-run` script from the `src/usr/bin/` directory into
our snap.

Finally, we need another plug; this plug is a content interface plug, which
connects to the content interface slot the Docker snap defines. We make the
content shared by the Docker snap available in `$SNAP/docker-bin` to keep it
separated from the content of our own snap.

### Using docker-compose

If we wanted to run a Docker container managing a webserver, we only need to
extend our snap a small amount:

```
apps:
  {snip}
  ticker:
      command: usr/bin/tocker_ticker.sh
      daemon: simple
      plugs:
        - docker

Our src directory now looks like:
$ tree ./src
./src
└── usr
    ├── bin
    │   ├── tocker_ticker.sh
    │   ├── tocker_run.sh
    └── share
        └── composers
            ├── compositions
            │   └── index.html
            └── nginx-compose.yml

5 directories, 8 files

$ cat src/usr/bin/tocker_ticker.sh
#!/bin/sh

export PATH=$SNAP/docker-bin/bin:$PATH
export PYTHONPATH=$SNAP/docker-bin/lib/python3.6/site-packages:$PYTHONPATH
docker-compose -f $SNAP/usr/share/composers/hello-nginx.yml up

$ cat src/usr/share/composers/nginx-compose.yml
version: '3'

services:
  client:
    image: nginx
    ports:
      - 8000:80
    volumes:
      - $SNAP/usr/share/composers/compositions:/usr/share/nginx/html

$ cat src/usr/share/compositions/index.html
"Hello world!"
```

First, add a new app to our `apps:` section. This app will actually be a `simple
daemon` (see [here](https://snapcraft.io/docs/services-and-daemons) for other
options). Our daemon will be brought up immediately when our snap is installed,
and it will continue to run in the background until we stop it.

Next we extend our `parts:` section to include the script that will be run by
the `simple daemon` `ticker`, along with the `docker-compose.yml` and the
content of our webserver.

Add the relevant directories and files to our `src/` tree so that everything we
need ends up in the right places, and finally after rebuilding our snap and
installing it, the interfaces we connected earlier will still be connected, and
`snap` will automatically start our `simple daemon`. If you open a web browser and
navigate to http://localhost:8000, you should be greeted with the website hosted
by our Docker container!


### Using volumes

Suppose we want to create two Jenkins instances which share data between a
volume. It's a pretty simple process!

We will use two scripts that do all the heavy-lifting for us:

```
$ cat src/usr/bin/tocker_jenkins1.sh
#!/bin/sh

Export PATH=$SNAP/docker-bin/bin:$PATH

Docker run --name tocker-jenkins1 \
    -v jenkins-volume:/var/jenkins_home \
    -p 8080:8080 -p 50000:50000 \
    jenkins/jenkins

$ cat src/usr/bin/tocker_jenkins2.sh
#!/bin/sh

Export PATH=$SNAP/docker-bin/bin:$PATH

Docker run --name tocker-jenkins2 \
    -v jenkins-volume:/var/jenkins_home \
    -p 9090:9090 -p 60000:50000 \
    jenkins/jenkins
```

After adding these scripts to our `snapcraft.yaml`, we can run the first script
and go through the setup process. After, we can spin up the second instance and
find that no setup is required; the setup data is shared in the volume we
specified they use!

We could make these Jenkins instances run as daemons if we wanted; this is left
as an exercise.


### Using EdgeX

If you don't want to use the EdgeX snap already for available, you can use
available `docker-compose.yml` files (or your own) to run EdgeX Foundry in a
Docker Container similar to [the official
documentation](https://docs.edgexfoundry.org/2.0/getting-started/Ch-GettingStartedUsers/),
with some slight modification.

To do this I've added a new simple daemon like our `ticker` example, along with
a `docker-compose.yml` which I pulled from the [EdgeX Foundry GitHub, on the
Ireland
branch](https://github.com/edgexfoundry/edgex-compose/blob/ireland/docker-compose-no-secty.yml).
The compose file will require a small tweak before it can be properly used
within a snap. Because we want to use strict confinement, AppArmor will block
our snap from functioning properly if we don't remove the
```
security_opt:
  - no-new-privileges:true
```
lines from the compose file. Exclude these lines from the compose file you use,
and theoretically there shouldn't be any problems in starting our service!

Build & install the snap, and ensure you can see the services running and see
the web interfaces:

```
$ sudo docker-compose ps
$ curl http://localhost:59880/api/v2/ping
$ curl http://localhost:8500/ui/dc1/services
```

You can see the logs for your service through `snap`:
```
$ sudo snap logs tocker.tedgex
```

___
Currently under construction.
