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

/home/ec2-user/create_repo.sh /home/ec2-user/repo /home/ec2-user/packages
