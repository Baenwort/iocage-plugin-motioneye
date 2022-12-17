#!/bin/sh

# Install  py39-pip (should already be installed but doesn't seem to be on FreeBSD)
curl -sSfO 'https://bootstrap.pypa.io/get-pip.py'
python3 get-pip.py

# Create symlinks for pip 
ln -s /usr/local/bin/pip3.9 /usr/local/bin/pip-3.9

# Create symlink for sha1sum to allow file uploading to function
ln -s /usr/local/bin/shasum /usr/local/bin/sha1sum

# Install motioneye (dev branch for Python3 support. Switch when 0.43 released)
python3 -m pip install 'https://github.com/motioneye-project/motioneye/archive/dev.tar.gz'

# Enable motioneye
sysrc -f /etc/rc.conf motioneye_enable="YES"

# Create folders
#mkdir /usr/local/etc/motioneye /var/{run,log,db}/motioneye 2>/dev/null
mkdir -p /usr/local/etc/motioneye /var/lib/motioneye

# Get initial configuration
cp /usr/local/lib/python3.9/site-packages/motioneye/extra/motioneye.conf.sample /usr/local/etc/motioneye/motioneye.conf
sed -i.old 's|^conf_path .*|conf_path /usr/local/etc/motioneye|' /usr/local/etc/motioneye/motioneye.conf
sed -i.old 's|^log_path .*|log_path /var/log/motioneye|' /usr/local/etc/motioneye/motioneye.conf
sed -i.old 's|^run_path |#run_path |' /usr/local/etc/motioneye/motioneye.conf
rm -f /usr/local/etc/motioneye/motioneye.conf.old

# Create motioneye user and group
pw useradd -q -n motioneye -u 8765 -d /nonexistent -m
rm -rf /nonexistent
chown -R motioneye:motioneye /usr/local/etc/motioneye /var/lib/motioneye
# Failed new method
#pw useradd -q -n motioneye -c "The motioneye user" -u 8765 -d /nonexistent -s /sbin/nologin
#chown -R motioneye:motioneye /usr/local/etc/motioneye /var/{run,log,db}/motioneye

# Start the service
service motioneye start

exit 0
