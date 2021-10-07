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
$ snap install --dangerous ./tocker_1.0_amd64.snap
```

Then, simply connect the interfaces and run the snap.

```
$ snap connect tocker:docker docker:docker-daemon
$ snap connect tocker:docker-executables docker:docker-executables
$ tocker hello-world
```

Currently under construction, expected additions include:
```
docker-compose
???
Explanations
```
