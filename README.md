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
$ snap install --dangerous ./tocker_2.0_amd64.snap
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
  This snap demonstrates how to move a Docker-based workflow to a snap'd
  environment on Ubuntu Core. This snap shows how one would interact with the
  docker snap, namely through a content sharing interface to gain access to the
  docker executable, along with a simple script to call the docker executable.

grade: stable
confinement: strict

apps:
  tocker:
    command: usr/bin/tocker
    plugs:
      - docker

parts:
  copy-script:
    plugin: dump
    source: src
    organize:
      tocker_run.sh: usr/bin/tocker

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
plugin to move our tocker-run script from the src/ directory into our snap,
specifically placing it in usr/bin/tocker.

Finally, we need another plug; this plug is a content interface plug, which
connects to the content interface slot the Docker snap defines. We make the
content shared by the Docker snap available in `$SNAP/docker-bin` to keep it
separated from the content of our own snap.

### Using docker-compose

If we wanted to run a Docker container managing a webserver, we only need to
extend our snap a small amount:

```
ticker:
    command: usr/bin/ticker
    daemon: simple
    plugs:
      - docker

parts:
  {snip}
    organize:
      tocker_run.sh: usr/bin/tocker
      tocker_compose.sh: usr/bin/ticker
      docker-compose.yml: usr/share/composers/hello-nginx.yml
      compositions: usr/share/composers/compositions


Our src directory now looks like:
$ tree ./src
src/
├── compositions
│   └── index.html
├── docker-compose.yml
├── tocker_compose.sh
└── tocker_run.sh

1 directory, 4 files

$ cat src/tocker_compose.sh
#!/bin/sh

export PATH=$SNAP/docker-bin/bin:$PATH
export PYTHONPATH=$SNAP/docker-bin/lib/python3.6/site-packages:$PYTHONPATH
docker-compose -f $SNAP/usr/share/composers/hello-nginx.yml up

$ cat src/docker-compose.yml
version: '3'

services:
  client:
    image: nginx
    ports:
      - 8000:80
    volumes:
      - $SNAP/usr/share/composers/compositions:/usr/share/nginx/html

$ cat src/compositions/index.html
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


___
Currently under construction.
