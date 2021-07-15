Docker GPhotos Sync
===================

A Docker container which runs the [`gphoto-cdp`][1] tool automatically to synchronize your Google Photos (in original quality!).

 [1]: http://github.com/perkeep/gphotos-cdp

[![Docker Image Version](https://img.shields.io/docker/v/jakewharton/gphotos-sync?sort=semver)][hub]
[![Docker Image Size](https://img.shields.io/docker/image-size/jakewharton/gphotos-sync)][layers]

 [hub]: https://hub.docker.com/r/jakewharton/gphotos-sync/
 [layers]: https://microbadger.com/images/jakewharton/gphotos-sync


Motivation
----------

Your photos are too valuable to leave solely in Google's hands. While it's extremely unlikely that Google would ever lose data, it's far more likely for you to lose access to your account (for whatever reason).

Currently, the only way to obtain original backups of your photos is through Google Takeout. Obtaining this backup is a tedious, manual process which is also not incremental.

Google Photos does have an API making traditional incremental backup feasible, but you do not have access to the original image making it a lossy solution.

The [`gphoto-cdp`][1] tool uses the Chrome Devtools Protocol to drive the normal web interface of Google Photos to download orignial copies in an incremental fashion. This repository is a Docker-ized version of the tools which runs it on a periodic basis.


Setup
-----

Select and create two directories:

 * The "download" directory where images will be stored. (From now on referred to as `/path/to/download`)
 * The "config" directory where your Google account authentication credentials will be stored. (From now on referred to as `/path/to/config`)


### Sign In

In order for the headless, automatic sync to work, you need to first authenticate with your Google account.

#### Linux

Open a terminal and run the following command.
```
chromium-browser --user-data-dir=/path/to/config https://photos.google.com
```

Click "Go to photos" and sign in to your Google account. You are free to use your real password or to create an app-specific password.

Close the Chrome window. You're done!

#### MacOS / Windows

To do this, we start a Linux-based Docker container with Chrome and remotely sign in.

In a terminal, run the following command, replacing `/path/to/config` with your chosen "config" directory.
```bash
$ docker run -p 6080:80 \
    -v /path/to/config:/config \
    dorowu/ubuntu-desktop-lxde-vnc
```

Visit http://localhost:6080 (or http://server-ip:6080 if running on a remote machine) which will connect to the container's desktop.

Inside the container desktop, click on the menu (lower left icon), go to "System Tools", and select "LXTerminal".
Run the following command.
```bash
google-chrome --user-data-dir=/config --no-sandbox https://photos.google.com
```
(Note: Do not change the `/config` path!)

Click "Go to photos" and sign in to your Google account. You are free to use your real password or to create an app-specific password.

Close the Chrome window inside the container desktop.

Close your browser's tab.

Press CTRL+C to quit the Docker image. You're done!


### Initial Sync

The first time this container runs, it will start from your oldest photo and cycle its way to your newest, downloading each along the way.
This is a _very_ slow operation that will take many hours or even days. Yes, days. In the process it will download tens or hundreds of gigabytes of images.

It is not required, but if you'd like to run this sync manually you can choose to do so.
This allows you to temporarily interrupt it at any point and also intervene if it gets stuck.

```bash
$ docker run -it --rm
    -v /path/to/config:/tmp/gphotos-cdp \
    -v /path/do/downloads:/download \
    jakewharton/gphotos-sync
    /app/sync.sh
```

This will run until all photos have been downloaded. At this point, you should set it up to run automatically on a schedule.


### Running Automatically

To run the sync automatically on a schedule, pass a valid cron specifier as the `CRON` environment variable.

```bash
$ docker run -it --rm
    -v /path/to/config:/tmp/gphotos-cdp \
    -v /path/do/download:/download \
    -e "CRON=0 * * * *" \
    jakewharton/gphotos-sync
```

The above version will run every hour and download any new photos. For help creating a valid cron specifier, visit [cron.help][2].

 [2]: https://cron.help/#0_*_*_*_*


### More

To be notified when sync is failing visit https://healthchecks.io, create a check, and specify the ID to the container using the `HEALTHCHECK_ID` environment variable.

Because the sync can occasionally fail, it's best to set a grace period on the check which is a multiple of your cron period. For example, if you run sync hourly give a grace period of two hours.

To write data as a particular user, the `PUID` and `PGID` environment variables can be set to your user ID and group ID, respectively.


### Diagnosing Blockages

The script will occasionally fail to download an image or video. This usually isn't something to worry about and it will resume when retried (either manually or automatically).

Sometimes, however, the script will get stuck on a single item and be unable to make progress. Usually this item will be a video.

When this happens, open the last Google Photos link from the logs. This is the last successful item that was download. Pressing the left arrow will move forward in time to the offending item. If you click "Download" in the three-dot menu and the item downloads then keep trying the sync. But if it fails to download, there is something wrong on Google's side. The only recourse is to delete the image or video. This will allow the script to continue on its next run.

Deleting an image or video should be a last resort. Retry at least 5 times, potentially waiting an hour or two in between. You can also get a Google Takeout of your Photos data and look for the item in the resulting archives.


### Docker Compose

```yaml
version: '2'
services:
  gphotos-sync:
    image: jakewharton/gphotos-sync:latest
    restart: unless-stopped
    volumes:
      - /path/to/config:/tmp/gphotos-cdp
      - /path/to/download:/download
    environment:
      - "CRON=0 * * * *"
      #Optional:
      - "HEALTHCHECK_ID=..."
      - "PUID=..."
      - "PGID=..."
```

Note: You may want to specify an explicit version rather than `latest`.
See https://hub.docker.com/r/jakewharton/gphotos-sync/tags.


Development
-----------

With Docker installed, `docker build .` will give you a SHA that you can use.
```
$ docker build .
...
Successfully built 7b431e7e9868
```

Use that SHA in place of `jakewharton/gphotos-sync` in the commands above to manually test.



LICENSE
======

MIT. See `LICENSE.txt`.

    Copyright 2020 Jake Wharton

The Chrome installation in the `Dockerfile` is from [Zenika/alpine-chrome][3].
`jhead` installation from [sourcelevel/engine-image-optim][4]

 [3]: https://github.com/Zenika/alpine-chrome
 [4]: https://github.com/sourcelevel/engine-image-optim
