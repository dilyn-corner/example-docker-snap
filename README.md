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


___
Currently under construction.
