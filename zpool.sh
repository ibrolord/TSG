#!/bin/bash
echo "########################################################################################"
echo "Simple Script To Demo ZPOOL and ZFS"
echo
printf "There are 8 disks (6 HDDs, 2 SDDs) and this script will select based on the tasks. \nBut you can play with it by using any more of the other disks if you want"
echo
echo "The Pools will be destroyed when you exit or when you run some tasks"
echo "########################################################################################"

debugtin(){
	exec 5> debug.txt
	BASH_XTRACEFD="5"
	PS4='${LINENO}:'
	set -x
	echo
}
debugtin

while true; do
        if [[ `zpool list | grep bigpool` ]]; then zpool destroy bigpool -f; fi
        if [[ `zpool list | grep bigpool2` ]]; then zpool destroy bigpool2 -f; fi
	#echo "#################################################################################" 
	echo "Select what ZPOOL/ZFS task you would like to see."
	echo "Current Block Disks" && df -h
        echo
        echo "Current ZPOOL Pools - CMD(zpool list)" && zpool list
	echo
	echo "1) Create a new Pool (simple administration)"
	echo "2) Create a new Dataset"
	echo "3) Setup ZIL"
	echo "4) Setup L2ARC Cache"
	echo "5) Create Snapshots"
	echo "b) bye"
	echo
	read CHOICE

	case $CHOICE in
		1)	echo "Create a New Pool. There are 3 types Mirror, Raidz, Stripe (we will only use mirror and raidz)"
			#echo "Current Block Disks" && lsblk && sleep 2
        		printf "Current ZPOOL Pools - CMD(zpool list)" && zpool list
			echo "Create a Pool"
			zpool create bigpool mirror /dev/xvdf /dev/xvdg && printf "\nA new Pool of 2 HDD called bigpool has been created for Mirror\n" && sleep 3 && zpool list && sleep 3
			printf "\nYou can see the status of zpool with CMD(zpool status -v)\n" && zpool status -v && sleep 3
			printf "\nYou can see that the Blocks have changed \n" && df -h && sleep 3
			zpool create bigpool2 raidz /dev/xvdh /dev/xvdi && printf "\nA new Pool of 2 HDD called bigpool2 has been created for Raidz\n" && sleep 3 && zpool list && sleep 3
			printf "\nYou can see the status of zpool with CMD(zpool status -v)\n" && zpool status -v && sleep 3
			printf "\nYou can see that the Blocks have changed \n" && df -h && sleep 3
		        printf "\nWe can add an extra disk to any of the pools (we will add to mirror) - CMD (zpool add bigpool mirror /dev/xvdj /dev/xvdl\n" && sleep 2 && zpool add bigpool mirror /dev/xvdj /dev/xvdl && sleep 3
			printf "\nWe can notice that the Pool information has changed\n" && sleep 3 && zpool status -v && sleep 3
			printf "\nThere are more things we can do like replace disks, and more but for now we just want to create pools\n" && sleep 3
			printf "\nNow this is over we will delete the pools - CMD (zpool destroy bigpool bigpool2)\n" && sleep 2 && zpool destroy bigpool -f && zpool destroy bigpool2 -f && zpool list
		
			;;

		2)	echo "We will create Datasets which is the 'filesystem' for the Pool"
			#echo "Current Block Disks" && lsblk && sleep 2
        		printf "\nA mirror pool has been created for this tasks. Current ZPOOL Pools - CMD(zpool list)\n" &&zpool create bigpool mirror /dev/xvdf /dev/xvdg && zpool list && sleep 3 && df -h && sleep 3
			printf "\nIn this task we will create 3 Subsets 'devops', 'it', 'acct'\n"
			zfs create bigpool/devops && zfs create bigpool/it && zfs create bigpool/acct && printf "\n3 new Datasets have been created - CMD (zfs create bigpool/devops && zfs create bigpool/it && zfs create bigpool/acct)\n" && sleep 3 && df -h && sleep 3
			 zfs create bigpool/newguy && printf "\nWe can extend Datasets with more Subsets, for example under devops we added a filesystem for 'newguy' CMD(zfs create bigpool/newguy)\n" && df -h && sleep 3
			printf "\nYou can see that the Blocks have changed \n" && df -h && sleep 3
			zfs set quota=200m bigpool/acct && printf "\nWe set a Quota for Acct to use 200MB out of the pool - CMD ( zfs set quota=200m bigpool/acct)\n" && sleep 3 && zpool list && sleep 3 && df -h && sleep 3
			zfs set reservation=5g bigpool/devops && printf "\nWe set a Reservation for Devops to have 10G out of the pool notice the size of other Datasets - CMD ( zfs set reservation=10g bigpool/devops )\n" && sleep 3 && zpool list && sleep 3 && df -h && sleep 3
			printf "\nYou can see that the Blocks have changed \n" && df -h && sleep 3
			printf "\nYou can see all the properties for this pool. There are so many useful things like compression, nfs, etc. Check it out - CMD (zfs get all bigpool)\n" && sleep 3 && zfs get all bigpool && sleep 3 
			printf "\nNow this is over we will delete the pools - CMD (zpool destroy bigpool)\n" && sleep 2 && zpool destroy bigpool -f && zpool list
			;;

		3)	echo "We will create ZIL (ZFS Write Caching)"
        		printf "\nA mirror pool has been created for this tasks. Current ZPOOL Pools - CMD(zpool list)\n" && zpool create bigpool mirror /dev/xvdf /dev/xvdg && zpool list && sleep 3 && df -h && sleep 3
			printf "\nIn this task we will create a ZIL (ZFS Intent Log); This is useful for Synchronous Writes; This is useful for Synchronous Writes. I will add 1 of our SSD drives to serve as the SLOG for our Write Cache\n"
			zpool add bigpool log /dev/xvdk && printf "\nAdding a Flash storage to our Magnetic Mirror - CMD (zpool add bigpool log /dev/xvdk)\n" && sleep 3 && zpool status -v && sleep 3
			 printf "\nWe can view the iostat performance, we may not see anything because there is not alot of readwrite action going on here. CMD(zpool iostat -v bigpool)\n" && sleep 3 && zpool iostat -v bigpool && sleep 3 
			printf "\nNow this is over we will delete the pools - CMD (zpool destroy bigpool)\n" && sleep 2 && zpool destroy bigpool -f && zpool list
			;;

		4)	echo "We will create ARC (Adaptive Replacement Caching) Level 2"
        		printf "\nA mirror pool has been created for this tasks. Current ZPOOL Pools - CMD(zpool list)\n" &&zpool create bigpool mirror /dev/xvdf /dev/xvdg && zpool list && sleep 3 && zpool status -v && sleep 3
			printf "\nIn this task we will create a ZFS L2ARC; This is useful for Read Caching. I will add 1 of our SSD drives to serve as the Flash buffer for our Read Cache\n"
			zpool add bigpool cache /dev/xvdl && printf "\nAdding a Flash storage to our Magnetic Mirror - CMD (zpool add bigpool log /dev/xvdk)\n" && sleep 3 && zpool status -v && sleep 3
			printf "\nWe can view the iostat performance, we may not see anything because there is not alot of readwrite action going on here. CMD(zpool iostat -v bigpool)\n" && sleep 3 && zpool iostat -v bigpool && sleep 3 
			printf "\nNow this is over we will delete the pools - CMD (zpool destroy bigpool)\n" && sleep 2 && zpool destroy bigpool -f && zpool list 
			;;

		5)	echo "We will create Snapshot Scenarios"
        		printf "\nA mirror pool has been created for this tasks. Current ZPOOL Pools - CMD(zpool list)\n" && zpool create bigpool mirror /dev/xvdf /dev/xvdg && zpool list && sleep 3 && df -h && sleep 3
			printf "\nIn this task we will create a Dataset, make some data in there, create a snapshot, and show how the Snapshots are stores - CMD (zfs create bigpool/devops && zfs create bigpool/devops/newguy && head -c 5MB /dev/urandom > /bigpool/devops/newguy/NewGuyWritingThing.file)\n" && zfs create bigpool/devops && zfs create bigpool/devops/newguy && head -c 5MB /dev/urandom > /bigpool/devops/newguy/NewGuyWritingThing.file && sleep 3 && ls -al /bigpool/devops/newguy/NewGuyWritingThing.file && sleep 3  
			zfs snapshot bigpool/devops/newguy@backingup && printf "\nWe will create a point in time snapshot of the newguy filesystem - CMD ( zfs snapshot bigpool/devops/newguy@backingup )\n" && sleep 3 && df -h && sleep 3
			 printf "\nWe can view the snapshot create for newguy with - CMD(ls -al /bigpool/devops/newguy/.zfs/snapshot/\n" && ls -al /bigpool/devops/newguy/.zfs/snapshot/ && sleep 3
			printf "\nNow we will delete the NewGuyWritingThing.file and attempt to restore it from Snapshot - CMD(rm -rf /bigpool/devops/newguy/NewGuyWritingThing.file && ls -al /bigpool/devops/newguy/NewGuyWritingThing.file && zfs rollback bigpool/devops/newguy@backingup)\n" && sleep 3 && printf "\nRemoving the file rm -rf /bigpool/devops/newguy/NewGuyWritingThing.file\n" && sleep 3 && rm -rf /bigpool/devops/newguy/NewGuyWritingThing.file && sleep 3 && printf "\n Does the  /bigpool/devops/newguy/NewGuyWritingThing.file exist\n" && ls -al /bigpool/devops/newguy/ && sleep 3 

			printf "\nNow we will restore the Dataset)\n" && sleep 2 && zfs rollback bigpool/devops/newguy@backingup && sleep 3 && df -h && printf "\nHas the file been restored now?\n " && sleep 3 && ls -al /bigpool/devops/newguy/ && sleep 4
			printf "\nNow this is over we will delete the pools - CMD (zpool destroy bigpool)\n" && sleep 2 && zpool destroy bigpool -f && zpool list
			;;
               b)
			echo "Thanks for testing this ZPOOLs and ZFS with me"
			break
			;;
        esac
done
