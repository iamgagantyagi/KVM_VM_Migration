# KVM_VM_Migration
This Repository Contains scripts and playbook that can be used to migrate VM's from one KVM to another KVM.

```
We have two methods to migrate VM's from one KVM server to another.
1 Live Migration - This Process is used to migrate the vm without any downtime.
2 Cold Migration - This is used to migrate critcal hosts which required downtime.
```

#### Live Migration : [Live_Migration_Script](https://github.com/iamgagantyagi/KVM_VM_Migration/blob/main/Live_Migration/live_migration.sh)

#### Cold Migration : [Cold_Migration_Script](https://github.com/iamgagantyagi/KVM_VM_Migration/blob/main/Cold_Migration/cold_migration.sh)

---
<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

Clone this repository to source KVM.
  ```sh
  https://github.com/iamgagantyagi/KVM_VM_Migration.git
  ```

### Steps to Perform Migration

_Below is an example of how you can perform migration vm from one server to another. 

1. Clone the repo to source kvm.
   ```sh
   git clone https://github.com/iamgagantyagi/KVM_VM_Migration.git
   ```
2. Open the screen session named migration.
   ```sh
   screen -S migration
   ```
4. Choose the migration type [live/cold] and run the script.
   ```sh
   sudo bash live_migration.sh/cold_migration.sh <VM_NAME> <DESTINATION_KVM_HOST>
   ```

#### _Note: Enter the root password of destination host. Thats it Now wait for the migration to be finish !!!   
---
## Authors

Contributors names and contact info

ex. Gagan Tyagi
ex. [@Gagan Tyagi](https://twitter.com/gtyagi017)

---
## License

This project is licensed under the [NAME HERE] License - see the LICENSE file for details

---
## Contributions

If you're interested in contributing to any of this project, feel free to open issues or submit pull requests. Your contributions are highly appreciated!

Feel free to explore, learn, and adapt this project to your needs!
