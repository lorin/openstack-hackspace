# Under the hood: compute

You should have one virtual machine instance running. If you are inside
of the DevStack VM, you can check by doing:

    $ source ~/devstack/openrc
    $ nova list

You should see something like:

    +--------------------------------------+------+--------+------------+-------------+--------------------------------+
    | ID                                   | Name | Status | Task State | Power State | Networks                       |
    +--------------------------------------+------+--------+------------+-------------+--------------------------------+
    | fa1ddbab-417f-4890-abc1-4cdf2bbfa787 | test | ACTIVE | None       | Running     | private=10.0.0.3, 172.24.4.227 |
    +--------------------------------------+------+--------+------------+-------------+--------------------------------+

The default DevStack configuration uses QEMU to implement virtual machines,
managed by libvirt.

## QEMU process

You can see the qemu process that corresponds to the instance by doing:

    $ pgrep qemu | xargs ps ww

The output should look something this:

      PID TTY      STAT   TIME COMMAND
    23142 ?        Sl     0:27 /usr/bin/qemu-system-x86_64 -S -M pc-1.0 -no-kvm -m 512 -smp 1,sockets=1,cores=1,threads=1 -name instance-00000001 -uuid fa1ddbab-417f-4890-abc1-4cdf2bbfa787 -smbios type=1,manufacturer=OpenStack Foundation,product=OpenStack Nova,version=2013.2.1,serial=ed198556-2d49-edcc-edd8-567f9a37549e,uuid=fa1ddbab-417f-4890-abc1-4cdf2bbfa787 -nodefconfig -nodefaults -chardev socket,id=charmonitor,path=/var/lib/libvirt/qemu/instance-00000001.monitor,server,nowait -mon chardev=charmonitor,id=monitor,mode=control -rtc base=utc -no-shutdown -kernel /opt/stack/data/nova/instances/fa1ddbab-417f-4890-abc1-4cdf2bbfa787/kernel -initrd /opt/stack/data/nova/instances/fa1ddbab-417f-4890-abc1-4cdf2bbfa787/ramdisk -append root=/dev/vda console=tty0 console=ttyS0 -drive file=/opt/stack/data/nova/instances/fa1ddbab-417f-4890-abc1-4cdf2bbfa787/disk,if=none,id=drive-virtio-disk0,format=qcow2,cache=none -device virtio-blk-pci,bus=pci.0,addr=0x4,drive=drive-virtio-disk0,id=virtio-disk0 -netdev tap,fd=17,id=hostnet0 -device virtio-net-pci,netdev=hostnet0,id=net0,mac=fa:16:3e:23:87:cf,bus=pci.0,addr=0x3 -chardev file,id=charserial0,path=/opt/stack/data/nova/instances/fa1ddbab-417f-4890-abc1-4cdf2bbfa787/console.log -device isa-serial,chardev=charserial0,id=serial0 -chardev pty,id=charserial1 -device isa-serial,chardev=charserial1,id=serial1 -usb -vnc 127.0.0.1:0 -k en-us -vga cirrus -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x5

## Libvirt

In the qemu process arguments, one of the arguments is `-name instance-00000001`.
This is the domain name of the instance as seen by libvirt. You should be
able to see that instance listed as a running domain by doing:

    $ sudo virsh list



## Virtual machine image files

The files that correspond to the virtual machine are in
`/opt/stack/data/nova/instances/<instance id>`. These include the disk image,
as well as the libvirt xml file.

By default, DevStack uses QCOW2 images, which are copy on write. When
OpenStack launches a new virtual machine, it copies the image file to
`/opt/stack/data/nova/instances/_base`, and then creates a new qcow2 image
in the `/opt/stack/data/nova/instances/<instance id>` directory.


## Database

OpenStack keeps persistent state in a MySQL database. The database corresponding
to the Compute service is called `nova` and has many tables.

Try going a quick query to get the uuid, the VM state, the instance name,
and the name of the compute host which contains the hypervisor that the
instance is running on:


    $ sudo mysql nova
    mysql> select uuid, vm_state, hostname, host from instances;
    +--------------------------------------+----------+----------+----------+
    | uuid                                 | vm_state | hostname | host     |
    +--------------------------------------+----------+----------+----------+
    | fa1ddbab-417f-4890-abc1-4cdf2bbfa787 | active   | test     | devstack |
    +--------------------------------------+----------+----------+----------+


The next exercise is [Under the hood: volumes].

[Under the hood: volumes]: under-the-hood-volumes.md
