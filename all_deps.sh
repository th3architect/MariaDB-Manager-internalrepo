release_info=$(cat /etc/*-release)
echo "Distribution: $release_info"
if [ -z "$release_info" ]; then
	echo "no /etc/*-release file or it is empty, trying to check /etc/debian_version"
	deb_ver=`cat /etc/debian_version`
	if [ -n "$deb_ver" ]; then
		release_info="Debian"
	fi
fi
if [[ $(echo "$release_info" | grep 'Red Hat') != "" || $(echo "$release_info" | grep 'CentOS') ]]; then
	echo "building for RPM"
	packages='MariaDB-Manager-GREX MariaDB-Galera-server MariaDB-client rsync iproute net-tools grep findutils gawk'

	cd /home/ec2-user
	#rm -rf /home/ec2-user/packages
	rm -rf /home/ec2-user/repo
	#mkdir /home/ec2-user/packages
	mkdir /home/ec2-user/repo

	for i in $packages
	do
	        list=`rpmdep $i 2> /dev/null | grep "depends upon" | sed "s/depends upon//" | sed "s/,/ /g"`
        	echo  $list
	        yum -y --downloadonly --downloaddir=/home/ec2-user/packages1/ reinstall $list
        	cp /home/ec2-user/packages1/* /home/ec2-user/packages/
	        yum -y --downloadonly --downloaddir=/home/ec2-user/packages1/ reinstall $i
        	cp /home/ec2-user/packages1/* /home/ec2-user/packages/
	done

elif [[ $(echo "$release_info" | grep 'Ubuntu') != "" || $(echo "$release_info" | grep 'Debian') ]]; then
	echo "buildng for DEB"
	apt-get update
	packages='mariadb-manager-grex mariadb-galera-server mariadb-client rsync iproute net-tools grep findutils gawk'
	list_all_packages=`apt-rdepends $packages | sed "s/PreDepends://" | sed "s/Depends://" |  sed "s/ (//g" | sed "s/)//g" | sed "s/< /</g" | sed "s/> />/g" | sed "s/= /=/g"`
	list_all_packages=`echo $list_all_packages | sed "s/ awk/ gawk /g" | sed "s/debconf-2.0 /debconf /g" | sed "s/libstorable-perl /perl /g" | sed "s/perlapi-5.14.2 /perl-base /g" | sed "s/perl-dbdabi-94 /libdbi-perl /g" | sed "s/upstart-job/upstart/g"`
	mkdir -p  /home/ec2-user/packages/; cd  /home/ec2-user/packages/
	rm y.sh
        if [ "$deb_ver" != "6.0.7" ]; then
		for i in $list_all_packages
		do
			  echo  apt-get download "$i" >> y.sh
		done
#                apt-get download $list_all_packages
		chmod a+x y.sh
		./y.sh
		rm y.sh
        else
                rm -rf /var/cache/apt/archives/*
                list_all_packages=`echo $list_all_packages | sed "s/debconf-english//g" | sed "s/sysv-rc//g" `
                for i in $list_all_packages
                do
                          echo  "apt-get --download-only --reinstall -y --force-yes install  $i" >> y.sh
                done
                chmod a+x y.sh
                ./y.sh
		rm y.sh
#                apt-get --download-only --reinstall -y --force-yes install  $list_all_packages
                cp /var/cache/apt/archives/* .
        fi
fi
/home/ec2-user/create_repo.sh /home/ec2-user/repo /home/ec2-user/packages

