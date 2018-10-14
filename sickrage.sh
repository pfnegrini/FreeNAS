echo '{"pkgs":["ca_root_nss","git"]}' > /tmp/pkg.json
iocage create -n "sickrage" -p /tmp/pkg.json -r 11.1-RELEASE dhcp=on bpf=yes vnet="on" devfs_ruleset=5 interfaces=vnet0:bridge0 host_hostname=sickrage allow_raw_sockets="1" boot="on"
rm /tmp/pkg.json

#mkdir -p /mnt/tank/apps/sickrage
#mkdir -p /mnt/tank/media/downloads
#mkdir -p /mnt/tank/media/series
iocage fstab -a sickrage /mnt/tank/apps/sickrage /config nullfs rw 0 0
iocage fstab -a sickrage /mnt/tank/media/downloads /mnt/downloads nullfs rw 0 0
iocage fstab -a sickrage /mnt/tank/media/series /mnt/series nullfs rw 0 0

iocage exec sickrage "sed -i -e 's/quarterly/release_2/g' /etc/pkg/FreeBSD.conf"
iocage exec sickrage pkg update
iocage exec sickrage pkg upgrade -y
iocage exec sickrage "echo 'OSVERSION = 1101001' >> /usr/local/etc/pkg.conf"
iocage exec sickrage "echo 'IGNORE_OSVERSION = yes' >> /usr/local/etc/pkg.conf"
iocage exec sickrage pkg install -y python27 py27-openssl py27-pip py27-lxml py27-sqlite3
iocage exec sickrage pkg update -f
iocage exec sickrage pkg upgrade -fy

iocage exec sickrage "git clone  https://git.sickrage.ca/sickrage/sickrage.git /usr/local/share/sickrage"
iocage exec sickrage "pip install -r /usr/local/share/sickrage/requirements.txt"
iocage exec sickrage "pw user add sickrage -c sickrage -u 351 -d /nonexistent -s /usr/bin/nologin"
iocage exec sickrage service sickrage onestop
iocage exec sickrage "pw user add media -c media -u 8675309 -d /nonexistent -s /usr/bin/nologin"
iocage exec sickrage "pw groupadd -n media -g 8675309"
iocage exec sickrage "pw groupmod media -m sickrage"
iocage exec sickrage chown -R media:media /usr/local/share/sickrage /config
iocage exec sickrage mkdir /usr/local/etc/rc.d
iocage exec sickrage cp /usr/local/share/sickrage/runscripts/init.freebsd /usr/local/etc/rc.d/sickrage
iocage exec sickrage chmod u+x /usr/local/etc/rc.d/sickrage
iocage exec sickrage sysrc "sickrage_enable=YES"
iocage exec sickrage sysrc "sickrage_user=media"
iocage exec sickrage sysrc "sickrage_dir=/usr/local/share/sickrage"
iocage exec sickrage sysrc "sickrage_datadir=/config"
iocage exec sickrage service sickrage start
