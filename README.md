# Canvas setup manual
> These files are intended to setup a clean canvas environment! These are made especially for the Devdroplets deploy schema.

With this documentation, you'll set up a fresh / new canvas environment within the devdroplets server. 


From here on out, we're assuming that: Your current directory is the root of this folder, you are loggedin on the devdroplets.ga webserver, and you have access to create docker containers with docker-compose.
The following steps we will discuss how you:
- Set up the image that will initially be the canvas webserver
- Set up the docker container stack

### Image creation
To deploy canvas, you'll first have to build the _canvas-lms_ image. This image is easily create by pulling the already created "template" image from the canvas repository, and building / compiling on top of that image with single run containers.
All these commands come from the `docker_pull_image.sh` file presented inside the canvas-lms repository. [For reference](https://github.com/instructure/canvas-lms/blob/master/script/docker_pull_image.sh).

To pull the "template" image from the canvas repository, run the following command:
```bash
docker-compose pull web
```
This *might* take a while.
After the pull has been completed, you'll have your own fresh template image with the source code from *canvas-lms* repository. Now we need to rewrite the lock files within the image. Runn the following commands:
```bash
docker run --rm instructure/canvas-lms:master cat Gemfile.lock > Gemfile.lock
docker run --rm instructure/canvas-lms:master cat yarn.lock > yarn.lock
```
After these two, you will need to build the actual files and setup the database. Next up, run this command:
```bash
docker-compose run --rm web bash -c "bundle; bundle exec rake db:create db:initial_setup"
```
If everything went succesful, then the image is built and ready to be deployed. Deploying can be done automatically via the docker-compose command like so:
```bash
docker-compose up -d
```
This creates the canvas-lms stack. And the deamon that runs it so.

# Makefile
You can also use the `Makefile` to do your bidding. The following scripts can be used:
- `make restart` / `make` - Restart the canvas env
- `make start` - Start the canvas env
- `make backup` - Create a backup.tar from the canvas env (BACKUP?="backup.tar")
- `make restore` - Restore backup.tar to canvas env (BACKUP?="backup.tar")
- `make clean` - Remove the whole canvas env
- `make create` - Create the whole canvas env from fresh
- `make recreate` - Recreate the whole canvas env freshly

All these commands can be used to do stuff automatically. Everything is defined inside the `Makefile` itself. 