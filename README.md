Docker GPhotos Sync
===================

A Docker container which runs the [`gphoto-cdp`][1] tool automatically to synchronize your Google Photos (in original quality!).

 [1]: http://github.com/perkeep/gphotos-cdp


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
To do this, we start a Linux-based Docker container with Chrome and remotely sign in.


In a terminal, run the following command, replacing `/path/to/config` with your chosen "config" directory.
```
$ docker run -p 6080:80 \
    -v /path/to/config:/config \
    dorowu/ubuntu-desktop-lxde-vnc
```

Visit http://localhost:6080 which will connect to the container's desktop.

Inside the container desktop, open a terminal and run the following command.
```
chromium-browser --user-data-dir=/config --no-sandbox https://photos.google.com
```
(Note: Do not change the `/config` path!)

Click "Go to photos" and sign in to your Google account. You are free to use your real password or to create an app-specific password.

Close the Chrome window inside the container desktop.

Close your browser's tab.

Press CTRL+C to quit the Docker image.


### Initial Sync

The first time this container runs, it will start from your oldest photo and cycle its way to your newest, downloading each along the way.
This is a _very_ slow operation that will take many hours or even days. Yes, days. In the process it will download tens or hundreds of gigabytes of images.

It is not required, but if you'd like to run this sync manually you can choose to do so.
This allows you to temporarily interrupt it at any point and also intervene if it gets stuck.

```
$ docker run -it --rm --cap-add=SYS_ADMIN \
    -v /path/to/config:/tmp/gphotos-cdp \
    -v /path/do/downloads:/download \
    JakeWharton/gphotos-sync
```

This will run until all photos have been downloaded. At this point, you should set it up to run automatically on a schedule.


### Running Automatically

To run the sync automatically on a schedule, pass a valid cron specifier as the `CRON` environment variable.

```
$ docker run -it --rm --cap-add=SYS_ADMIN \
    -v /path/to/config:/tmp/gphotos-cdp \
    -v /path/do/download:/download \
    -e "CRON=0 * * * *"
    JakeWharton/gphotos-sync
```

The above version will run every hour and download any new photos. For help creating a valid cron specifier, visit [cron.help][2].

 [2]: https://cron.help/#0_*_*_*_*


### Monitoring

To be notified when sync is failing visit https://healthchecks.io, create a check, and specify the URL to the container using the `CHECK_URL` environment variable.

Because the sync can occasionally fail, it's best to set a grace period on the check which is a multiple of your cron period. For example, if you run sync hourly give a grace period of two hours.


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
    image: JakeWharton/gphotos-sync:latest
    restart: unless-stopped
    volumes:
      - /path/to/config:/tmp/gphotos-cdp
      - /path/to/download:/download
    environment:
      - "CRON=0 * * * *"
      - "CHECK_URL=..." #Optional!
```



LICENE
======

MIT. See `LICENSE.txt`.

    Copyright 2020 Jake Wharton

Much of the container scripts were derived from [bcardiff/docker-rclone][3]:

 [3]: https://github.com/bcardiff/docker-rclone
