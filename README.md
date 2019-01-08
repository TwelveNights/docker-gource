# Docker Gource Image

[Docker](https://www.docker.com) container that has the capability to generate [Gource](https://code.google.com/p/gource) videos in a headless environment.

## Customizable Environment Variables

Let me know if you would like more to be customizeable.

+ RES (default: 1920x1080)
+ DEPTH (default: 24)
+ TITLE (default: "")

## Base Docker Image

+ [ubuntu:14.04](https://registry.hub.docker.com/_/ubuntu/)

## Requirements

+ [Docker](http://www.docker.com/)

## Usage

### Build or Download Image

Download [automated build](https://registry.hub.docker.com/u/twelvenights/gource/) from public [Docker Hub Registry](https://registry.hub.docker.com/):

```sh
docker pull twelvenights/gource
```

Alternatively, you can build an image from the `Dockerfile`:

```sh
git clone git@github.com:twelvenights/docker-gource.git
cd docker-gource
docker build -t twelvenights/gource .
```

### Running

```sh
docker run --rm --name gource \
    -v REPO_ROOT:/repoRoot \
    -v RESULTS_FOLDER:/results \
    -v AVATARS_FOLDER:/avatars \
    --env TITLE="My overridden title text" \
    twelvenights/gource
```

### Override options

There are several options you can override using environment variables passed to the container:

+ DEPTH: The color depth to use as an option to `screen`. (default: 24)
+ EXTRA_OPTS: Any extra options to *gource* you wish to add.
+ FONT_COLOR: Font colour used by the date and title in hex (`--font-colour`). (default: FFFF00)
+ FONT_SIZE: Font size used by the date and title (`--font-size`). (default: 25)
+ FPS: Framerate of output (25,30,60), used by both gource (`-r`) and ffmpeg (`-r`). (default: 30)
+ HIDE: Hide one or more display elements (`--hide`).  (default: dirnames,filenames)
+ RES: Set the viewport size. (default: 1920x1080)
+ SEC_PER_DAY: Speed of simulation in seconds per day (`--seconds-per-day`). (default: 1)
+ TITLE: Set a title (`--title`). (default: Example title)
+ USER_SCALE: Change scale of user avatars (`--user-scale`). (default: 4.0)

If you want repository usernames to be replaced with images then put images to avatars folder.
Name for the avatar image must match the username (e.g taivokasper.png).

### Example: Automatically download Github repository

```sh
docker run --rm --name gource \
    -v $HOME/Videos/gource:/results \
    --env TITLE="Docker Evolution" \
    twelvenights/gource docker/docker
```
