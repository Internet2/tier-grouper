# tier-grouper

## Building Grouper

We need both a Grouper container and a mysql database server, so we
will run two containers - one for grouper and one for mysql. 

Because the Grouper application installer from the Grouper developers
depends on the database being present and running when the app is installed, 
we need to create the database first and have the database container 
running *before* starting the build script for the grouper container. The
database also has to be running at a predictable location since Grouper's
isntall script asks for a hostname for the database.

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
step 1, we can prepare to build the Grouper docker container. Note that our install assumes that the database container is running at the IP address 172.17.0.2 - if you want to build with a different address, update this in the expect script located in
```
configs/grouper-install-expect.exp
```
Why an expect script? The Grouper app installer was packaged as an interactive .war 
file which asks many questions, so we automated the build with an expect script.


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

In the simplest case, you can see if things are running by pointing your 
web browser at
```
http://your-server-here:8080/grouper
```
You will be promted to log in. If you haven't changed the defaults from the build
process, you can use the username 'GrouperSystem' and the password 'changeme'
to get the the web user interface.

### troubleshooting

If the containers build, but you cannot get a response from the Grouper web user
interface, you might have run into a firewall issue. On Centos 7 you can open port 8080
and verify that it is open like this:
```
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload
firewall-cmd --zone=public  --list-ports
```
