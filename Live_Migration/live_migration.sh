#!/bin/bash

shopt -s nocasematch

VMNAME=$(echo $1)
DestinationHost=$(echo $2)

echo " "
while true; do
read -p "Please silent monitors for $VMNAME migration, if created already then type "y" to continue:" yn
	case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer Y or N.";;
    esac
done

echo "
Checking if you are running screen session or not to avoid interruption 
"
if [ `echo $TERM` == screen ]
	then
	echo "Awesome! You are running screen session `echo $STY`"
else
	echo "Please run screen session first to continue migration of $VMNAME"
	exit 1
fi

#Check 1st argument
checkIfVMExist=$(virsh list | grep $VMNAME)
if [[ $? = 0 ]]; then

echo "
$VMNAME is present, migrating off to $DestinationHost
"

sudo virsh dumpxml $VMNAME > $VMNAME.xml

VM_DISK=$(cat $VMNAME.xml| grep "source file" |cut -d\' -f2)

echo "Getting $VMNAME disk size"

du -ksh $VM_DISK

echo "
Getting $VMNAME allocated vcpu's"

grep vcpu $VMNAME.xml


## Verify VM image File Location
grep "source file" $VMNAME.xml | grep "/vm_imgs/" > /dev/null 2>&1

if [ $? -ne 0 ];
  then
    echo "A non-standard location for this VMs image was found.";
    echo;
    grep "source file" $VMNAME.xml;
    echo;
    echo "Do you wish to continue?";
    echo "Please press Y to continue or N to stop the migration";

    flag=false;
    while [ $flag = false ];
      do
        read answer;
        case $answer in
          "Y")
            flag=true;
          ;;
          "N")
            exit 1;
          ;;
          "*")
            echo "Please type Y or N";
          ;;
        esac
      done
fi

for diskfile in $(cat $VMNAME.xml  | awk ' /'source\ file'/' | awk ' /'qcow2\|\|vm_imgs\|\|qcow'/' | cut -d "'" -f2)
do
   diskSize=$(sudo qemu-img info --force-share $diskfile | grep virtual | cut -d ":" -f2 | cut -d " " -f2)
   mkdircommand=$(echo "mkdir -p /$(echo $diskfile | cut -d "\"" -f2 | cut -d "/" -f2)/$(echo $diskfile | cut -d "\"" -f2 | cut -d "/" -f3) && chown root:users /$(echo $diskfile | cut -d "\"" -f2 | cut -d "/" -f2)/$(echo $diskfile | cut -d "\"" -f2 | cut -d "/" -f3)")

   echo "
   
############################################################################################################
creating storage-pool for $VMNAME & $diskfile Please enter root password for $DestinationHost -
############################################################################################################
   
   "
   ssh root@$DestinationHost <<EOF
   sudo mkdir -p /vm_imgs/$VMNAME
   sudo virsh pool-define-as --name $VMNAME --type dir --target /vm_imgs/$VMNAME
   sudo virsh pool-autostart $VMNAME
   sudo virsh pool-start $VMNAME
   sudo $mkdircommand && sudo qemu-img create -f qcow2 -o preallocation=off $diskfile $diskSize > /dev/null 2>&1
EOF

done

rm -rf $VMNAME.xml

echo "

#################################################################
Moving host.. Please enter root password for $DestinationHost - 
#################################################################

"
sudo virsh migrate --live --persistent --copy-storage-all --verbose --undefinesource  --desturi qemu+ssh://"$DestinationHost"/system $VMNAME

echo " 

List of all available VMs : 

"
virsh list
fi
