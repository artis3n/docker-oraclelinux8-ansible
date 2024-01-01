FROM oraclelinux:8
ENV container=docker

ENV pip_packages "ansible"

# Install systemd -- See https://hub.docker.com/_/centos/
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ "$i" == \
systemd-tmpfiles-setup.service ] || rm -f "$i"; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*; \
rm -f /etc/systemd/system/*.wants/*; \
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*; \
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install requirements.
RUN yum -y install rpm oracle-release-el8 dnf-plugins-core \
 && yum -y update \
 && yum -y install \
      oracle-epel-release-el8 \
      initscripts \
      sudo \
      which \
      hostname \
      libyaml \
      python3 \
      python3-pip \
      python3-pyyaml \
 && yum clean all \
 && rm -rf /var/cache

# Disable requiretty
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers \
&& mkdir -p /etc/ansible \
&& echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

# Upgrade pip to latest version.
RUN python3 -m pip install --no-cache-dir --upgrade pip \
&& python3 -m pip install --no-cache-dir $pip_packages

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
