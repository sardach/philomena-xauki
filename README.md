# Philomena (Xauki fork)
<img src="assets/static/xauki-rect.png" width="200">

Hello, this is the Fork of Philomena running in https://xauki.com

I'm only posting this because my soul demnand me to comply with the AGPL license.

I never before writed or readed any line of elixir code or HTML slim and I don't consider myself a good programmer in general. All commits are considered "hacks" more than proper improvements. Use this project at your own risk.

Notable differences from the original repository:
- Translation to spanish langauge
- Dramatic style changes
- Cool marquee on the activity / index page
- Very basic "level system"
- Very basic "related images system"
- Integration of share on social networks
- Cut out a bunch of unnecessary features for the goals of xauki.com

Original Philomena source: https://github.com/derpibooru/philomena

## Getting started
On systems with `docker` and `docker-compose` installed, the process should be as simple as:

```
docker-compose build
docker-compose up
```

If you use `podman` and `podman-compose` instead, the process for constructing a rootless container is nearly identical:

```
podman-compose build
podman-compose up
```

Once the application has started, navigate to http://localhost:8080 and login with admin@example.com / trixieisbestpony

## Troubleshooting

If you are running Docker on Windows and the application crashes immediately upon startup, please ensure that `autocrlf` is set to `false` in your Git config, and then re-clone the repository. Additionally, it is recommended that you allocate at least 4GB of RAM to your Docker VM.

If you run into an Elasticsearch bootstrap error, you may need to increase your `max_map_count` on the host as follows:
```
sudo sysctl -w vm.max_map_count=262144
```

If you have SELinux enforcing, you should run the following in the application directory on the host before proceeding:
```
chcon -Rt svirt_sandbox_file_t .
```

This allows Docker or Podman to bind mount the application directory into the containers.

## Deployment
You need a key installed on the server you target, and the git remote installed in your ssh configuration.

    git remote add production philomena@<serverip>:philomena/

The general syntax is:

    git push production master

And if everything goes wrong:

    git reset HEAD^ --hard
    git push -f production master

(to be repeated until it works again)
