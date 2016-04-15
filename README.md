# tier-grouper

## Building Grouper

We need both a Grouper container and a mysql database server, so we
will run two containers - one for grouper and one for mysql. 

Because the Grouper application installer from the Grouper developers
depends on the database being present when the app is installed, we 
need to create the database first and have the database container 
running *before* starting the build script for the grouper container. 

*Step 1:* Create a mysql database, and persist the data in the directory mysql_persistent_data
Note you should change the default root password for the mysql database and the
password for the grouper database user in the create-mysql-db script
```
./create-mysql-db
```

Alternatively, you could use an existing mySQL database by copying the mySQL data files 
into a directory and pointing the mySQL container at it. This means editing the run-mysql
script to map the location mapping of /var/lib/mysql to point to your-special-location
something like this:

```
sudo docker run --name mysqlserver  \
         -v `pwd`/mysqlconf.d:/etc/mysql/conf.d \
        -e MYSQL_ROOT_PASSWORD=changeme \
        -v /your-special-location-goes-right-here:/var/lib/mysql \
        -d mysql:5.7  \
        --character-set-server=utf8     \
        --collation-server=utf8_bin     \
        --skip-character-set-client-handshake

```

*Step 2:* Now that there is a database and the mysql container is still running from
step 1, we can prepare to build the Grouper docker container. The Grouper app installer was
packaged as an interactive .war file which asks many questions. To automate the
build, we are using an expect script which can be found here:
```
./build-configs/grouper-install-expect.exp
```

For those interested, the expect script was created by running _autoexpect_ on a 
partially installed Grouper environment like this:
```
export JAVA_HOME=/usr/java/latest
cd /home/grouper/2.2.2/ 
autoexpect java -jar grouperInstaller.jar
```
While you probably don't want to create a new expect script, you robably want to edit the
script the docker build script uses. This script sets a default password for the Grouper app,
and also uses the default grouper database password. So if you want a stronger password than
'changeme', edit the file ./build-configs/grouper-install-expect.exp before you build the container.

*Step 3:* Now we are ready to build the Grouper container. Do this by running the build script:
```
./build
```


## Run Grouper

Now that you have a database and a Grouper container, run both mysql and grouper containers with this script
```
./run
```
which starts the mySQL container, then runs the grouper container.

