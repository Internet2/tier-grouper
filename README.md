# tier-grouper

## Building Grouper

We need both a Grouper container and a mysql database server, so we
will run two containers - one for grouper and one for mysql. To build 
the grouper container run the build script:
```
./build
```


## Initializing MySQL

For mySQL, we are using the standard Docker mySQL 5.7 container from Dockerhub
and taking advanatge of a couple feature of the container to initialize the database
and create a grouper user. 

If you installing a completely new instance, first run the _create-mysql-db_ script 
to create the database and grouper user. 

Note that this script assumes you want to store the database files in a the 
subdirectory 'mysql_persistent_data'. Edit the script if you want to place the
file ssomehwere else, and while you are it it, consider putting in stronger 
passwords for the grouper and root mysql users.

After you have created an empty database, you should stop the mysdql container
so the process of creating a new empty database should look something like this:
```
$ ./create-mysql-db 
94cea3c3953d3e25d504d36b621ac1203dcad5d3643884770f56fd0ec2e12220
rapiduser@rapid-80:~/tier-grouper-master$ sudo docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
94cea3c3953d        mysql:5.7           "docker-entrypoint.sh"   6 seconds ago       Up 4 seconds        3306/tcp            mysqlserver
$ ls ./mysql_persistant_data/
auto.cnf  ib_buffer_pool  ib_logfile0  ibtmp1  performance_schema
grouper   ibdata1         ib_logfile1  mysql   sys
$ sudo docker kill 94cea3c3953d
94cea3c3953d
$ sudo docker rm 94cea3c3953d
94cea3c3953d
$ 
```

Alternatively, you could use an existing mySQL database by copying the mySQL data files 
into a directory and pointing the mySQL container at it. This means editing the run-mysql
script to map the location mapping of /var/lib/mysql to point to your-special-location
something like this:

```
sudo docker run --name mysqlserver  \
        -e MYSQL_ROOT_PASSWORD=changeme \
        -v /your-special-location-goes-right-here:/var/lib/mysql \
        -d mysql:5.7  \
        --character-set-server=utf8     \
        --collation-server=utf8_bin     \
        --skip-character-set-client-handshake

```
## Run Grouper

Now that you have a database, run both mysql and grouper containers with this script
```
./run
```
which starts the mySQL container, then runs the grouper container and links the two containers 
so that Grouper can talk to the database.

