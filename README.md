### Easily deploy a docker-compose.yml

This gem is a collection of scripts that I use to deploy my personal websites using docker-compose. This gem will help you:

- Generate a skeleton for you project
- Provision a server with Docker and Docker Compose
- Test your deployment on a vagrant machine
- Deploy your docker-compose project
- Backup the data that your applications generate

While these scripts are great for your personal projects, they will not help you with zero-downtime deploys, rotating your logs, or any of that other fancy stuff.

This doesn't provide much over using docker-machine, but it will simplify working with volumes and allow you to test your deployment in a realistic environment.


### The big picture

For my homepage, I serve up multiple applications from the same machine. For this reason, I have nginx to inspect incoming requests and route them to the correct application. As I add new applications, I need to change this setup. So I need to push a new nginx config file as part of my deployment process.

Some of my deployed applications generate data as they run. I want a simple way to download a snapshot of that data as backup. So I want to consolidate all of my data in one place.

While I want to keep the log files that my apps generate, I don't see a need to include those in the backup snapshots that I download. So I want to consolidate my logs somewhere separate from the important data.

DockerComposeDeploy scripts help me:

- push configuration for applications
- create data and log directories for applications
- backup data directories

As I add new apps I must update my nginx config. Testing this can be tricky, since nginx will make routing decisions based on the requested url. It's hard to really test this config when everything is hosted on `http://localhost`.  This tool will also:

- Push your project to a vagrant machine
- Create entries in `/etc/hosts` on the vagrant machine to help you test your nginx config

### Commands

Each command takes an optional `-e [environment]`. If the environment is not set, it will default to `test`. This environment corresponds to the entry in `config.yml`. There you can configure the connection string for sshing to the host. By default the `test` environment is set up to connect to the vagrant host configured in the Vagrantfile.

`dcd new [project_name]`: Scaffold a new project.

`dcd provision`: Install Docker & DockerCompose on the host machine.

`dcd deploy`: Push your `docker-compose.yml` to the host machine, create directories for volume-mapping (explained below), pull the required docker images, and run `docker-compose up`.

`dcd backup`: Tar, bzip, and download the `./sites/data` for safekeeping.

`dcd push [image_names]`: __If all of your images are on hub.docker.com, then you don't need this command.__ Normally you might push your docker images to http://hub.docker.com. However, you might have some images that you'd prefer to keep private. This command will take a local image, tar it, push it to the remote host. Using `dcd push` you do not need to push your private image to docker hub. This is significantly slower than using the registry because you need to push the entire image each time. Note that if you use this command, you will need to set `ignore_pull_failures: true` in your `config.yml`.


### Installation

```
gem install 'docker_compose_deploy'
```

This will add the executable `dcd`

In order to test your project using vagrant, you need to have vagrant installed: https://www.vagrantup.com/

### Creating a new project

We will generate a new project in the 'homepage' directory:

```
dcd new homepage
```

You should see the following output:

```
To see the skeleton app in action, run the following commands

# Move into the directory
1. cd homepage

# Use vagrant to create the virtual machine for testing (it will open a window and will display Ubuntu's desktop)
2. vagrant up

# Install docker and docker-compose on the vagrant machine
3. dcd provision

# Deploy the skeleton app to the vagrant machine
4. dcd deploy

# See the server in action:
5. Open firefox on the vagrant machine and visit http://www.test
```

Follow those steps!  When you visit `www.test` in the vagrant machine, you should see a page that says "site 1 or site 2"

### The Project Structure

Let's investigate each file, one by one.

---

__docker-compose.yml__

A natural place to start to inspect the `docker-compose.yml` file.  You will see three sites defined: proxy, site1, site2.

Each site that is deployed with `dcd` will be provided three directories to mount:

- `./sites/[app_name]/config`: This directory is pushed from your localhost to the remote. Each time you run `dcd deploy` the config directory for each application will be __removed and replaced__ by the directory found on your localhost (if any).  Notice that there is a file on your localhost at `./sites/proxy/config/nginx.conf`. This file will be copied to your host at deployment time.

- `./sites/[app_name]/data`: This directory is the permanent storage for your application. This directory will be created by `dcd` but it will not be changed or removed by `dcd. When running `dcd backup`, each application's `data` directory will be zipped up and downloaded for safekeeping.

- `./sites/[app_name]/log`: This directory is for storing logs. It is never removed, but it is also not included in backups. To see what's inside, you'll have to ssh to your server.

Although none of the sites in the skeleton make use of their data directories, the volume maps are included to indicate what mounts are available. Understanding how nginx is configured is beyond the scope of this project, but the configuration found at `./sites/proxy/config/nginx.conf` should be a good template to follow.

Once you've deployed the initial skeleton to the vagrant host, ssh to it (`vagrant ssh`) and look around the `~/sites` folder to see all the folders its created.

---

__config.yml__

This is where we configure what machines `dcd` will connect with. I only need two environments: 'test' and 'production'. The 'test' environment is the vagrant box, the 'production' environment uses my virtual machine on DigitalOcean.

When using the `dcd` command, you can specify the environment using the `-e` flag. If the `-e` is not set, it will default to 'test'. Here is an example:

```
dcd deploy -e production
```

You can also configure the `hosts` entry. These will be placed in the `/etc/hosts` file of the remote machine. This is only used on test machines so that we can have fake dns entries. Having these hosts entries allows us to trigger nginx rules that are hard to trigger when using `localhost`. For example:
```
server {
  listen 80;
  server_name site1.*;
  ...
}
```
Using a hosts entry allows us to visit `site.test` and trigger that handler.

You can read the comments in `config.yml` for more info.

__Vagrantfile__

Nothing special here. Note that a high port is forwarded to port 22 only to make the configuration for ssh-ing to the machine more predictable.

If you get locked out of your Ubuntu machine the password is `vagrant`.

__ssh_config_overrides__

The Controlmaster stuff at the top helps improve the performance of the multiple ssh commands that are run in quick succession.

The host at the bottom is the connection info for your vagrant machine. If you want to manually ssh to your vagrant machine you can do the following:

```
vagrant ssh
```
or

```
ssh -F ssh_config_overrides vagrant@default
```

If `dcd` cannot connect to your vagrant machine, you can run:

```
vagrant ssh-config >> ssh_config_overrides
```

This will update the ssh connection info to work with your vagrant machine.

### Deploying to DigitalOcean

I use a cheap vps on http://wwww.digitalocean.com to host my site. Create a droplet and copy its ip address.  Update `config.yml` with `root@[ip-address]` as the `production` connection string. Then run `dcd provision && dcd deploy`. Now configure your dns and you should be done!

### Issues/Questions

If you have any questions or problems using these scripts or somethings just not clear, please open an issue! I'm happy to try to help.
