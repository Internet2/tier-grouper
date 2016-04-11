FROM   centos:7
MAINTAINER Mark McCahill "mark.mccahill@duke.edu"

USER root

RUN yum -y update &&  \
    yum -y install \
	       dos2unix \
           wget \
           unzip; \
    yum clean all

RUN cd /opt

#
# set the locale
#
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  


################## start OpenJDK ###################### 
#
RUN yum -y update &&  \
    yum -y install \ 
             java-1.8.0-openjdk.x86_64  \
             java-1.8.0-openjdk-devel.x86_64 ;  \
    mkdir /usr/java ; \
    ln -s /etc/alternatives/java_sdk_1.8.0_openjdk /usr/java/jdk1.8.0_77 ; \
    ln -s /usr/java/jdk1.8.0_77 /usr/java/latest ; \
    yum clean all
#
################## end OpenJDK ################## 

#
# try to make sure we use UTF for the JVM 
#
ENV JAVA_TOOL_OPTIONS "-Dfile.encoding=UTF-8 " 

#
# mysql connector and expect
#
RUN yum -y update &&  \
    yum -y install \
             mysql-connector-java ; \
			 expect ; \
    yum clean all

#
# grouper
#
ADD ./configs /build-configs

RUN useradd grouper
USER grouper
RUN mkdir /home/grouper/2.2.2 ; \
    cd /home/grouper/2.2.2/ ; \
    wget http://software.internet2.edu/grouper/release/2.2.2/grouperInstaller.jar

USER root

RUN export JAVA_HOME=/usr/java/latest ; \
    cd /home/grouper/2.2.2/ ; \
	expect /build-configs/grouper-install-expect.exp

#
# things we need assuming we end up running systemd
#
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

RUN systemctl enable tomcat.service

EXPOSE 8080
CMD ["/usr/sbin/init"]
