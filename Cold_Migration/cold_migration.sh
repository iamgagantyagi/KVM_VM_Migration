#!/bin/bash

shopt -s nocasematch

VMNAME=$(echo $1)
DestinationHost=$(echo $2)

echo "
Checking if you are running screen session or not to avoid interruption
"
if [ `echo $TERM` == screen ]
	then
	echo "Awesome! You are running screen session `echo $STY`"
else
	echo "Please run screen session first to continue cold migration of $VMNAME"
	exit 1
fi


echo "
Checking if given VM is present on this KVM host or not?
"
#Check VM is exists 
checkIfVMExist=$(virsh list --all | grep $VMNAME)
if [[ $? = 0 ]];
 then
	echo "$VMNAME is present"
	else
	echo "Please type in correct VMNAME"
	exit 1
fi
echo "
Dumping the current xml config file for $VMNAME to /tmp
"
virsh dumpxml $VMNAME > /tmp/$VMNAME.xml

VM_DIR=$(cat /tmp/$VMNAME.xml | grep "source file" | cut -d "\"" -f2 | cut -d "/" -f2 | head -n 1)
VM_DISK=$(cat /tmp/$VMNAME.xml| grep "source file" |cut -d\' -f2)


echo "Getting $VMNAME disk size"

du -ksh $VM_DISK

echo "
Getting $VMNAME allocated vcpu's"

grep vcpu /tmp/$VMNAME.xml

echo " "
while true; do
read -p "Please silence the monitors $VMNAME migration, if created already then type "y" to continue:" yn
	case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer Y or N.";;
    esac
done

echo "
Backing up existing $VMNAME xml config file, if present"
sudo mv /$VM_DIR/$VMNAME/$VMNAME.xml /$VM_DIR/$VMNAME/$VMNAME.xml.org

echo "
Ensuring standard path "/vm_imgs" is set in $VMNAME xml config file"
sed -i.bak "s/$VM_DIR/vm_imgs/g" "/tmp/$VMNAME.xml"

echo "
Copying updated $VMNAME xml config file"
sudo cp -v /tmp/$VMNAME.xml /$VM_DIR/$VMNAME/

echo "
Shutting down the $VMNAME for cold migration"
virsh shutdown $VMNAME
sleep 30
if [[ $(virsh list --all| grep $VMNAME) != "" ]]
   then
      echo "$VMNAME is not running"	  
   else
      echo "$VMNAME is still running, shutting down gracefully"
	  virsh destroy --graceful $VMNAME
fi

echo "
Disabling autostart for $VMNAME"
virsh autostart --disable $VMNAME

echo "Copying $VMNAME VM files to $DestinationHost at standard path "/vm_imgs"
"
echo "Please enter root password for $DestinationHost 
"
sudo scp -pr /$VM_DIR/$VMNAME root@$DestinationHost:/vm_imgs/ 
#sudo rsync -arvhP /$VM_DIR/$VMNAME root@$DestinationHost:/vm_imgs/
echo "
Setting up $VMNAME on destination KVM host
"
ssh root@$DestinationHost <<EOF
chown -R root:users /vm_imgs/$VMNAME
virsh define /vm_imgs/$VMNAME/$VMNAME.xml
virsh autostart $VMNAME
virsh start $VMNAME
sleep 5
virsh list | grep $VMNAME
EOF

sleep 5
echo "
Undefining $VMNAME from source KVM host
"
virsh undefine $VMNAME
