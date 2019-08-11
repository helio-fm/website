
### Setting up a node on Linux

Rough outline of setting up a Ubuntu server for deploying an Elixir app.

SSH into server and update packages:
```
apt-get update
apt-get upgrade
```

Install Erlang/Elixir/Hex:
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
##
#
# /etc/nginx/sites-available/default
#
# A nice tutorial:
# https://medium.com/@a4word/setting-up-phoenix-elixir-with-nginx-and-letsencrypt-ada9398a9b2c
#
# Don't forget to `service nginx restart` after changing this :)
#
##

upstream helio.fm {
    server 127.0.0.1:4000;
}

server {
    listen 80;
    listen [::]:80;

    server_name helio.fm www.helio.fm;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;

    location / {
        proxy_redirect off;
        proxy_pass http://helio.fm;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/musehackers.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/musehackers.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot

    if ($scheme != "https") {
        return 301 https://$host$request_uri;
    } # managed by Certbot
}

server {
    listen 80;
    listen [::]:80;

    server_name files.helio.fm;
    root /opt/musehackers/files;

    ssl_dhparam /etc/ssl/certs/dhparam.pem;

    location / {
        try_files $uri $uri/ =404;
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

I've considered keeping secrets in environment variables (note that they are only read in a compile-time), so `prod.secret.exs` is no longer needed and should be commented out in `prod.exs`. Before that it was uploaded to `/home/deploy/prod.secret.exs` and symlinked by edeliver into a build dir.

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


### Setting up a node on FreeBSD

#### Install bash and make is default shell:
```
pkg install bash
chsh -s bash
```

#### Set up Nginx and ipfw
```
pkg install nginx
grep rcvar /usr/local/etc/rc.d/*
ee /etc/rc.conf
```

Add:
```
nginx_enable="YES"
firewall_enable="YES"
firewall_type="workstation"
firewall_myservices="22/tcp 80/tcp 443/tcp"
firewall_allowservices="any"
```

Start services:
```
nohup service ipfw start >/tmp/ipfw.log 2>&1
service nginx start
```

#### Remove sendmail

`ee /etc/rc.conf`, add:
```
sendmail_enable="NONE"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"
```
Then `/etc/rc.d/sendmail onestop`

#### Set up Postgres:
```
pkg install postgresql11-server
```

Edit `ee /etc/login.conf`:
```
postgres:\
        :lang=en_US.UTF-8:\
        :setenv=LC_COLLATE=C:\
        :tc=default:
```
Then `cap_mkdb /etc/login.conf`.

Edit `ee /etc/rc.conf`:
```
postgresql_enable="YES"                                                  
postgresql_class="postgres"
```

`service postgresql initdb`
`service postgresql start`

Create DB:
```
create database whateverdb;
create user heliofm with encrypted password 'somepassword';
grant all privileges on database whateverdb to heliofm;
```

#### Set up Git and Elixir:
```
pkg install git
pkg install elixir
mix local.hex
```

Make sure to install latest OTP version, since there are weird bugs in Distillery with FreeBSD and earlier OTP: `pkg install erlang-rintime-21` and set update $PATH

#### Add user `deploy`

Set up ssh and `mkdir -p /home/deploy/edeliver`

#### Set up environment vars
```:setenv=SECRET_KEY_BASE=?,SECRET_KEY_GUARDIAN=?,DATABASE_HOSTNAME=?,DATABASE_USERNAME=?,DATABASE_PASSWORD=?,GITHUB_CLIENT_ID=?,GITHUB_CLIENT_SECRET=?,ETL_DOC_TRANSLATIONS=?,SYS_CONFIG_PATH=/opt/musehackers/musehackers/var/sys.config,VMARGS_PATH=/opt/musehackers/musehackers/var/vm.args,NODE_NAME=musehackers@127.0.0.1,REPLACE_OS_VARS=true,COOKIE=hex-string,......:\```

#### Set up Nginx config

Should looks like this:
```
# you must set worker processes based on your CPU cores, nginx does not benefit from setting more than that
worker_processes auto; #some last versions calculate it automatically

# number of file descriptors used for nginx
# the limit for the maximum FDs on the server is usually set by the OS.
# if you don't set FD's then OS settings will be used which is by default 2000
worker_rlimit_nofile 100000;

# only log critical errors
error_log /var/log/nginx/error.log crit;

#pid        logs/nginx.pid;

events {
    # determines how much clients will be served per worker
    # max clients = worker_connections * worker_processes
    # max clients is also limited by the number of socket connections available on the system (~64k)
    worker_connections 4000;
}

http {
    # cache informations about FDs, frequently accessed files
    # can boost performance, but you need to test those values
    open_file_cache max=200000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;

    # to boost I/O on HDD we can disable access logs
    access_log off;

    # copies data between one FD and other from within the kernel
    # faster than read() + write()
    sendfile on;

    # send headers in one piece, it is better than sending them one by one
    tcp_nopush on;

    # don't buffer data sent, good for small data bursts in real time
    tcp_nodelay on;

    # allow the server to close connection on non responding client, this will free up memory
    reset_timedout_connection on;

    # request timed out -- default 60
    client_body_timeout 10;

    # if client stop responding, free up memory -- default 60
    send_timeout 2;

    # server will close connection after this time -- default 75
    keepalive_timeout 30;

    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"'

    #gzip  on;


    upstream api {
        server 127.0.0.1:4001;
    }

    upstream web {
        server 127.0.0.1:4000;
    }

    server {
        server_name helio.fm www.helio.fm;

        location / {
            proxy_redirect off;
            proxy_pass http://web;
        }
    
        listen [::]:443 ssl http2 ipv6only=on; # managed by Certbot
        listen 443 ssl http2; # managed by Certbot
        ssl_certificate /usr/local/etc/letsencrypt/live/helio.fm/fullchain.pem; # managed by Certbot
        ssl_certificate_key /usr/local/etc/letsencrypt/live/helio.fm/privkey.pem; # managed by Certbot
        include /usr/local/etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
        ssl_dhparam /usr/local/etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
    }


    server {
        server_name api.helio.fm;

        location / {
            proxy_redirect off;
            proxy_pass http://api;
        }
    
        listen [::]:443 ssl http2; # managed by Certbot
        listen 443 ssl http2; # managed by Certbot
        ssl_certificate /usr/local/etc/letsencrypt/live/helio.fm/fullchain.pem; # managed by Certbot
        ssl_certificate_key /usr/local/etc/letsencrypt/live/helio.fm/privkey.pem; # managed by Certbot
        include /usr/local/etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
        ssl_dhparam /usr/local/etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
    }

    map $subdomain $expires {
        default off;
        ci epoch;
    }

    server {
        server_name  ~^(?<subdomain>.+)\.helio\.fm$;
        root /opt/musehackers/files/$subdomain;
        expires $expires;

        location / {
            try_files $uri $uri/ =404;
        }

        #listen [::]:443 ssl http2 ipv6only=on; # managed by Certbot
        listen 443 ssl http2; # managed by Certbot
        ssl_certificate /usr/local/etc/letsencrypt/live/helio.fm/fullchain.pem; # managed by Certbot
        ssl_certificate_key /usr/local/etc/letsencrypt/live/helio.fm/privkey.pem; # managed by Certbot
        include /usr/local/etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
        ssl_dhparam /usr/local/etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
    }

    server {
        listen 80;
        listen [::]:80;
        server_name helio.fm www.helio.fm api.helio.fm ci.helio.fm img.helio.fm;
        return 301 https://$host$request_uri; # managed by Certbot
    }
}
```

### Misc

Start server:
* `cd /opt/muse-hackers-playground/`
* `MIX_ENV=prod elixir --detached -S mix phx.server`

Kill elixir:
* `ps -eaf|grep elixir`
* find pid
* `kill 1111`

Certbot:
`certbot --nginx -d helio.fm -d www.helio.fm -d api.helio.fm -d ci.helio.fm -d img.helio.fm `

### Links

* [Setting up Ubuntu/Elixir/Postgres](https://gist.github.com/peterrudenko/d3fa7809462708e1bc88fd2319de23d5)

* [Setting up Phoenix with Nginx](https://medium.com/@a4word/setting-up-phoenix-elixir-with-nginx-and-letsencrypt-ada9398a9b2c)

* [Configuring Let's Encrypt](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04)

* [Up and running with Edeliver](https://gist.github.com/peterrudenko/701331647e66760e76aa1d36afa31b1b)

* [Setting up Travis deployment](https://oncletom.io/2016/travis-ssh-deploy/)
