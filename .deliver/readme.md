
### Setting up VPS

Rough outline of setting up a Ubuntu server for deploying an Elixir app.

SSH into server:

```
ssh root@ip.address
```

Update packages:

```
apt-get update
apt-get upgrade
```

Install erlang/elixir/hex:

```
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
apt-get update
apt-get install esl-erlang
apt-get install elixir
mix local.hex
mix local.rebar
```

#### Install Postgres

```
apt-get install postgresql postgresql-contrib
```

Switch to `postgres` role:

```
sudo -i -u postgres
```

Login to Postgres:

```
psql
```

Add password to `postgres` user:

```
alter user postgres with password '<password>';
```

Create database:

```
create database <db_name>;
```

#### Environment varibles

Create `/etc/environment`:

```
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8
FACEBOOK_APP_ID=123
FACEBOOK_APP_SECRET=123
SECRET_KEY_BASE=123
SECRET_KEY_GUARDIAN=123
DATABASE_HOSTNAME=localhost
DATABASE_USERNAME=123
DATABASE_PASSWORD=123
ETL_DOC_TRANSLATIONS=google_doc_key
```

Reload environment:

```
source /etc/environment
```

#### Nginx

Location: `/etc/nginx/sites-available/default`

Example config:

```
upstream musehackers.com {
    server 127.0.0.1:4000;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name musehackers.com www.musehackers.com;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;

    location / {
        proxy_redirect off;
        proxy_pass http://musehackers.com;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/musehackers.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/musehackers.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot

    if ($scheme != "https") {
        return 301 https://$host$request_uri;
    } # managed by Certbot
}
```

#### Let's Encrypt

```
letsencrypt-auto certonly -a manual --rsa-key-size 4096 --email example@email.com -d yourdomain.com
```

### Deploy and upgrade

Create a user called `deploy`:

- `ssh root@<droplet ip>`
- Create deploy user
  - `sudo adduser deploy`
  - add deploy to sudo group: `sudo adduser deploy sudo`
  - add passwordless sudo: `visudo` ->  `s/%sudo  ALL=(ALL:ALL) ALL/%sudo   ALL=NOPASSWD: ALL`
  - copy SSH public keys: `find .ssh -print | cpio -pdmv --owner=deploy ~deploy`
  - `su deploy`
- `sudo apt-get -y install git`
- `wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb`
- `sudo apt-get update`
- `sudo apt-get install -y elixir`
- `sudo apt-get install -y esl-erlang`
- `mix local.hex`
- `mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez`
- `sudo mkdir /opt && sudo chmod -R 777 /opt`
- setup `.deliver/config` file (repo already has one)

##### Secrets managements

I've considered keeping secrets in environment variables (note that they are only read in a compile-time), so `prod.secret.exs` is no longer needed and sohould be commented out in `prod.exs`. Before that it was uploaded to `/home/deploy/prod.secret.exs` and symlinked by edeliver into a build dir.

#### Deploy

`mix edeliver build release --verbose --branch=develop`
`mix edeliver deploy release to production --verbose`
`mix edeliver restart production`

Or:
`mix edeliver stop production`
`mix edeliver start production`

#### Upgrade

`mix edeliver build upgrade --auto-version=revision+branch-unless-master --verbose`
`mix edeliver upgrade production --verbose`
`mix edeliver migrate production`

#### CI

[Setting up Travis deployment](`https://oncletom.io/2016/travis-ssh-deploy/`)

Generate a dedicated SSH key (it is easier to isolate and to revoke);

```
ssh-keygen -t rsa -b 4096 -C 'build@travis-ci.org' -f ./deploy_rsa
```

Encrypt the private key to make it readable only by Travis CI (so as we can commit safely too!);

```
travis encrypt-file deploy_rsa --add
```

Copy the public key onto the remote SSH host;

```
ssh-copy-id -i deploy_rsa.pub <ssh-user>@<deploy-host>
```

Cleanup after unnecessary files;

```
rm -f deploy_rsa deploy_rsa.pub
```


Configure `.travis.yml` (already configured in this project):

```
addons:
  ssh_known_hosts: <deploy-host>

before_deploy:
- openssl aes-256-cbc -K $encrypted_<...>_key -iv $encrypted_<...>_iv -in deploy_rsa.enc -out /tmp/deploy_rsa -d
- eval "$(ssh-agent -s)"
- chmod 600 /tmp/deploy_rsa
- ssh-add /tmp/deploy_rsa

deploy:
  provider: script
  skip_cleanup: true
  script: mix edeliver update production --start-deploy
  on:
    branch: master
```

##### TODO

Hot to configure auto-versioning and hot upgrade?

### Misc

List processes: `ps -eaf|grep musehackers`

Start server:
* `cd /opt/muse-hackers-playground/`
* `MIX_ENV=prod elixir --detached -S mix phx.server`

Kill elixir:
* `ps -eaf|grep elixir`
* find pid
* `kill 1111`

### Links

* [Setting up Ubuntu/Elixir/Postgres](https://gist.github.com/peterrudenko/d3fa7809462708e1bc88fd2319de23d5)

* [Setting up Phoenix with Nginx](https://medium.com/@a4word/setting-up-phoenix-elixir-with-nginx-and-letsencrypt-ada9398a9b2c)

* [Configuring Let's Encrypt](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04)

* [Up and running with Edeliver](https://gist.github.com/peterrudenko/701331647e66760e76aa1d36afa31b1b)

* [Setting up Travis deployment](https://oncletom.io/2016/travis-ssh-deploy/)
