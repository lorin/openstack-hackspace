# Booting an instance

Here we're going to boot an instance and attach a volume. We'll be using Rackspace Cloud Servers, which is implemented on top of OpenStack.

## Add a keypair

First thing we need to do is create a new ssh keypair so that we can ssh to our instances. In these examples, we'll create a new keypair, although you can also upload an existing public key.

We'll call our key "lisa":

    $ nova keypair-add lisa > lisa.key

We also need to set permissions on it otherwise ssh won't let us use it.

    $ chmod 0600 lisa.key



## Networking

You should have a private and public network visible in your account:


	$ nova network-list
	+--------------------------------------+---------+------+
	| ID                                   | Label   | CIDR |
	+--------------------------------------+---------+------+
	| 00000000-0000-0000-0000-000000000000 | public  |      |
	| 11111111-1111-1111-1111-111111111111 | private |      |
	+--------------------------------------+---------+------+

We're going to create a new 10.30.0.0/24 network, which we'll call `hackspace`.


	$ nova network-create hackspace 10.30.0.0/24
	+----------+--------------------------------------+
	| Property | Value                                |
	+----------+--------------------------------------+
	| cidr     | 10.30.0.0/24                         |
	| id       | 5593dd67-feb4-4382-be86-1b9169ecde65 |
	| label    | hackspace                            |
	+----------+--------------------------------------+

It should now show up in a list of networks:

	$ nova network-list
	+--------------------------------------+-----------+--------------+
	| ID                                   | Label     | CIDR         |
	+--------------------------------------+-----------+--------------+
	| 5593dd67-feb4-4382-be86-1b9169ecde65 | hackspace | 10.30.0.0/24 |
	| 00000000-0000-0000-0000-000000000000 | public    |              |
	| 11111111-1111-1111-1111-111111111111 | private   |              |
	+--------------------------------------+-----------+--------------+

## Booting a new instance

Now we're going to boot an Ubuntu 12.04 instance into this network. List the available instance sizes, which OpenStack calls flavors:

	$ nova flavor-list
	+----+-------------------------+-----------+------+-----------+------+-------+-------------+-----------+
	| ID | Name                    | Memory_MB | Disk | Ephemeral | Swap | VCPUs | RXTX_Factor | Is_Public |
	+----+-------------------------+-----------+------+-----------+------+-------+-------------+-----------+
	| 2  | 512MB Standard Instance | 512       | 20   | 0         | 512  | 1     | 80.0        | N/A       |
	| 3  | 1GB Standard Instance   | 1024      | 40   | 0         | 1024 | 1     | 120.0       | N/A       |
	| 4  | 2GB Standard Instance   | 2048      | 80   | 0         | 2048 | 2     | 240.0       | N/A       |
	| 5  | 4GB Standard Instance   | 4096      | 160  | 0         | 2048 | 2     | 400.0       | N/A       |
	| 6  | 8GB Standard Instance   | 8192      | 320  | 0         | 2048 | 4     | 600.0       | N/A       |
	| 7  | 15GB Standard Instance  | 15360     | 620  | 0         | 2048 | 6     | 800.0       | N/A       |
	| 8  | 30GB Standard Instance  | 30720     | 1200 | 0         | 2048 | 8     | 1200.0      | N/A       |
	+----+-------------------------+-----------+------+-----------+------+-------+-------------+-----------+

List the available images:

	$ nova image-list
	+--------------------------------------+----------------------------------------------------------------------------------------------+--------+--------+
	| ID                                   | Name                                                                                         | Status | Server |
	+--------------------------------------+----------------------------------------------------------------------------------------------+--------+--------+
	| ba293687-4af0-4ccb-99e5-097d83f72dfe | Arch 2013.9                                                                                  | ACTIVE |        |
	| 9522c27d-51d9-44ee-8eb3-fb7b14fd4042 | CentOS 5.10                                                                                  | ACTIVE |        |
	| 59c037c1-70ec-41e4-aa17-73a9b0cb6b16 | CentOS 5.9                                                                                   | ACTIVE |        |
	| f70ed7c7-b42e-4d77-83d8-40fa29825b85 | CentOS 6.4                                                                                   | ACTIVE |        |
	| 695ca76e-fc0d-4e36-82e0-8ed66480a999 | Debian 6.06 (Squeeze)                                                                        | ACTIVE |        |
	| 857d7d36-34f3-409f-8435-693e8797be8b | Debian 7 (Wheezy)                                                                            | ACTIVE |        |
	| 896caae3-82f1-4b03-beaa-75fbdde27969 | Fedora 18 (Spherical Cow)                                                                    | ACTIVE |        |
	| 8500226f-b193-4471-9eff-9cba8440bfc8 | Fedora 19 (Schrodinger's Cat)                                                                | ACTIVE |        |
	| fb624ffd-81c2-4217-8cd5-da32d32e85c4 | FreeBSD 9.2                                                                                  | ACTIVE |        |
	| 73764eb8-3c1c-42a9-8fff-71f6beefc6a7 | Gentoo 13.3                                                                                  | ACTIVE |        |
	| 8955d327-9a69-468f-be5c-60f571267406 | OpenSUSE 12.3                                                                                | ACTIVE |        |
	| 56ad2db2-d9cd-462e-a2a4-7f3a4fc91ee8 | Red Hat Enterprise Linux 5.10                                                                | ACTIVE |        |
	| 9d661e79-e473-4e2c-8a60-06b33b0add67 | Red Hat Enterprise Linux 5.9                                                                 | ACTIVE |        |
	| c6e2fed0-75bf-420d-a744-7cfc75a1889e | Red Hat Enterprise Linux 6.4                                                                 | ACTIVE |        |
	| bced783b-31d2-4637-b820-fa02522c518b | Scientific Linux 6.4                                                                         | ACTIVE |        |
	| aab63bcf-89aa-440f-b0c7-c7a1c611914b | Ubuntu 10.04 LTS (Lucid Lynx)                                                                | ACTIVE |        |
	| c3153cde-2d23-4186-b7da-159adbe2858b | Ubuntu 12.04 LTS (Precise Pangolin)                                                          | ACTIVE |        |
	| ead43b0d-f84f-4bc1-8682-5b6046e69552 | Ubuntu 12.10 (Quantal Quetzal)                                                               | ACTIVE |        |
	| 9e1a83cf-ba21-44b6-8808-5837e291cfe2 | Ubuntu 13.04 (Raring Ringtail)                                                               | ACTIVE |        |
	| 868a0966-0553-42fe-b8b3-5cadc0e0b3c5 | Ubuntu 13.10 (Saucy Salamander)                                                              | ACTIVE |        |
	| 59b394f6-b2e0-4f11-b7d1-7fea4abc60a0 | Vyatta Network OS 6.5R2                                                                      | ACTIVE |        |
	| d7530109-edcf-400f-813c-9e11334a92c1 | Windows Server 2008 R2 SP1                                                                   | ACTIVE |        |
	| 7462c004-59cb-403c-9a8d-823ce978a00c | Windows Server 2008 R2 SP1 (base install without updates)                                    | ACTIVE |        |
	| d1f37a43-724c-4fd4-b2c2-6f6ed822d5d2 | Windows Server 2008 R2 SP1 + SQL Server 2008 R2 SP2 Standard                                 | ACTIVE |        |
	| 29950004-52cf-4ef7-8a84-7e9f63b6e06f | Windows Server 2008 R2 SP1 + SQL Server 2008 R2 SP2 Web                                      | ACTIVE |        |
	| 693f7e97-e723-4e42-bee6-ff4160106fa0 | Windows Server 2008 R2 SP1 + SQL Server 2012 SP1 Standard                                    | ACTIVE |        |
	| 4f01c063-993a-43ff-b476-3aaf995d969a | Windows Server 2008 R2 SP1 + SQL Server 2012 SP1 Web                                         | ACTIVE |        |
	| c2f7f30d-6b0f-4d08-af20-cefcc836ecd5 | Windows Server 2008 R2 SP1 + SharePoint 2010 Foundation with SQL Server 2008 R2 Express      | ACTIVE |        |
	| 72b86dd1-6fe5-4890-8f05-f61d30f65246 | Windows Server 2008 R2 SP1 + SharePoint 2010 Foundation with SQL Server 2008 R2 SP1 Standard | ACTIVE |        |
	| d4f4fc02-299c-4dad-9b85-0576a0336472 | Windows Server 2012                                                                          | ACTIVE |        |
	| 68c3112f-bbef-4a17-9b4c-fb7f7444376f | Windows Server 2012 (base install without updates)                                           | ACTIVE |        |
	| 41af66f7-6122-48de-b79c-13c98a5febbe | Windows Server 2012 + SQL Server 2012 SP1 Standard                                           | ACTIVE |        |
	| a68198b3-5bef-4779-a564-3c96f64b8df3 | Windows Server 2012 + SQL Server 2012 SP1 Web                                                | ACTIVE |        |
	| 639ec81b-35ac-4346-a275-4f31f7bb9504 | Windows Server 2012 + SharePoint 2013 with SQL Server 2012 SP1 Standard                      | ACTIVE |        |
	+--------------------------------------+----------------------------------------------------------------------------------------------+--------+--------+


We're going to use flavor `2` (512 MB Standard Instance), and image `25de7af5-1668-46fb-bd08-9974b63a4806` (Ubuntu 12.04).


We'll call this instance `web`, and specify that it should be on the `hackspace` network we created, with IP address 10.30.0.5.

We will use the `--no-service-net` argument so that our instance does not get connected to the private network.


	$ nova boot --flavor 2 --image 25de7af5-1668-46fb-bd08-9974b63a4806 --key-name lisa --nic net-id=5593dd67-feb4-4382-be86-1b9169ecde65,v4-fixed-ip=10.30.0.5 web  --no-service-net

Initial output should look like this:

	+------------------------+--------------------------------------+
	| Property               | Value                                |
	+------------------------+--------------------------------------+
	| status                 | BUILD                                |
	| updated                | 2013-11-02T02:07:05Z                 |
	| OS-EXT-STS:task_state  | scheduling                           |
	| key_name               | lisa                                 |
	| image                  | Ubuntu 12.04 LTS (Precise Pangolin)  |
	| hostId                 |                                      |
	| OS-EXT-STS:vm_state    | building                             |
	| flavor                 | 512MB Standard Instance              |
	| id                     | 659fe85d-a59d-4e04-9785-e2942eea1f1b |
	| user_id                | 97f0118696f24dc18031b5f9a0cfd9df     |
	| name                   | web                                  |
	| adminPass              | 76rGPb8a76ua                         |
	| tenant_id              | 869769                               |
	| created                | 2013-11-02T02:07:05Z                 |
	| OS-DCF:diskConfig      | AUTO                                 |
	| accessIPv4             |                                      |
	| accessIPv6             |                                      |
	| progress               | 0                                    |
	| OS-EXT-STS:power_state | 0                                    |
	| config_drive           |                                      |
	| metadata               | {}                                   |
	+------------------------+--------------------------------------+

The `nova list` command will give you information about the status.

	+--------------------------------------+------+--------+------------+-------------+-------------------------------------------------------------------------------------+
	| ID                                   | Name | Status | Task State | Power State | Networks                                                                            |
	+--------------------------------------+------+--------+------------+-------------+-------------------------------------------------------------------------------------+
	| 659fe85d-a59d-4e04-9785-e2942eea1f1b | web  | BUILD  | spawning   | NOSTATE     | hackspace=10.30.0.2; public=162.209.109.95, 2001:4802:7800:0002:1b1e:746f:ff20:0b7a |
	+--------------------------------------+------+--------+------------+-------------+-------------------------------------------------------------------------------------+

Eventually, the stauts will become `ACTIVE`:

	+--------------------------------------+------+--------+------------+-------------+-------------------------------------------------------------------------------------+
	| ID                                   | Name | Status | Task State | Power State | Networks                                                                            |
	+--------------------------------------+------+--------+------------+-------------+-------------------------------------------------------------------------------------+
	| 659fe85d-a59d-4e04-9785-e2942eea1f1b | web  | ACTIVE | None       | Running     | hackspace=10.30.0.2; public=162.209.109.95, 2001:4802:7800:0002:1b1e:746f:ff20:0b7a |
	+--------------------------------------+------+--------+------------+-------------+-------------------------------------------------------------------------------------+


Once active, you will be able to ssh as root using the lisa.key private key file you created. In the example above, the public IP address is `162.209.109.95`, in your specific case it will be different:

	$ ssh -i lisa.key root@162.209.109.95
	Warning: Permanently added '162.209.109.95' (RSA) to the list of known hosts.
	Welcome to Ubuntu 12.04.3 LTS (GNU/Linux 3.2.0-53-virtual x86_64)

	 * Documentation:  https://help.ubuntu.com/

	  System information as of Sat Nov  2 02:08:45 UTC 2013

	  System load:  0.08              Processes:           64
	  Usage of /:   4.9% of 19.68GB   Users logged in:     0
	  Memory usage: 10%               IP address for eth0: 162.209.109.95
	  Swap usage:   0%                IP address for eth1: 10.30.0.2

	  Graph this data and manage this system at https://landscape.canonical.com/


	The programs included with the Ubuntu system are free software;
	the exact distribution terms for each program are described in the
	individual files in /usr/share/doc/*/copyright.

	Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
	applicable law.

	root@web:~#

Note that there are two interfaces, eth0 has IP address 162.209.109.95 and is on the `public` network and eth1 has IP address 10.30.0.2 and is on the `hackspace` network.

Don't forget to log out of the instance:


	root@web:~# exit
	logout
	Connection to 162.209.109.95 closed.

## Attaching a volume
We're going to attach a 100 GB volume (block device) to our instance.

First, we create the 100GB volume:

	$ nova volume-create 100
	+---------------------+--------------------------------------+
	| Property            | Value                                |
	+---------------------+--------------------------------------+
	| status              | available                            |
	| display_name        | None                                 |
	| attachments         | []                                   |
	| availability_zone   | nova                                 |
	| bootable            | false                                |
	| created_at          | 2013-11-02T02:14:09.000000           |
	| display_description | None                                 |
	| volume_type         | SATA                                 |
	| snapshot_id         | None                                 |
	| source_volid        | None                                 |
	| size                | 100                                  |
	| id                  | 455ec395-cfab-4319-bbf0-1d061c14a7e8 |
	| metadata            | {}                                   |
	+---------------------+--------------------------------------+
We should now be able to see it using `nova volume-list`

	$ nova volume-list
	+--------------------------------------+-----------+--------------+------+-------------+-------------+
	| ID                                   | Status    | Display Name | Size | Volume Type | Attached to |
	+--------------------------------------+-----------+--------------+------+-------------+-------------+
	| 455ec395-cfab-4319-bbf0-1d061c14a7e8 | available | None         | 100  | SATA        |             |
	+--------------------------------------+-----------+--------------+------+-------------+-------------+

We're going to attach this to our `web` instance. We'll use the "auto"  argument to let OpenStack select the device file that is associated with the instance.

	$ nova volume-attach web 455ec395-cfab-4319-bbf0-1d061c14a7e8 auto
	+----------+--------------------------------------+
	| Property | Value                                |
	+----------+--------------------------------------+
	| device   | /dev/xvdb                            |
	| serverId | 659fe85d-a59d-4e04-9785-e2942eea1f1b |
	| id       | 455ec395-cfab-4319-bbf0-1d061c14a7e8 |
	| volumeId | 455ec395-cfab-4319-bbf0-1d061c14a7e8 |
	+----------+--------------------------------------+

Here we format that volume as an ext4 file system and then mount it as /mnt/vol:

	root@web:~# mkfs.ext4 /dev/xvdb
	mke2fs 1.42 (29-Nov-2011)
	Filesystem label=
	OS type: Linux
	Block size=4096 (log=2)
	Fragment size=4096 (log=2)
	Stride=0 blocks, Stripe width=0 blocks
	6553600 inodes, 26214400 blocks
	1310720 blocks (5.00%) reserved for the super user
	First data block=0
	Maximum filesystem blocks=4294967296
	800 block groups
	32768 blocks per group, 32768 fragments per group
	8192 inodes per group
	Superblock backups stored on blocks:
		32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
		4096000, 7962624, 11239424, 20480000, 23887872

	Allocating group tables: done
	Writing inode tables: done
	Creating journal (32768 blocks): done
	Writing superblocks and filesystem accounting information: done

	root@web:~# mkdir /mnt/vol
	root@web:~# mount /dev/xvdb /mnt/vol

We can confirm the size using df:

	root@web:~# df -h /mnt/vol
	Filesystem      Size  Used Avail Use% Mounted on
	/dev/xvdb        99G  188M   94G   1% /mnt/vol

We can also unmount it and then detach it from the instance:

	root@web:~# umount /mnt/vol
	root@web:~# exit
	logout
	Connection to 162.209.109.95 closed.
	$ nova volume-detach web 455ec395-cfab-4319-bbf0-1d061c14a7e8

The volume still exists, and if we had stored any files on it, those files would persist until we deleted the volume:

	$ nova volume-delete 455ec395-cfab-4319-bbf0-1d061c14a7e8


# Capture an instance to an image

You can capture a running instance to an image, which you can deploy later.


	$ nova image-create web web-snapshot

It will take a while to snapshot the instance to an image. You can check
the status:


	$ nova image-show web-snapshot
	+------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| Property                                       | Value                                                                                                                                                                                                                                                           |
	+------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| metadata com.rackspace__1__visible_rackconnect | 0                                                                                                                                                                                                                                                               |
	| metadata com.rackspace__1__visible_core        | 0                                                                                                                                                                                                                                                               |
	| metadata instance_uuid                         | 659fe85d-a59d-4e04-9785-e2942eea1f1b                                                                                                                                                                                                                            |
	| metadata com.rackspace__1__options             | 0                                                                                                                                                                                                                                                               |
	| metadata com.rackspace__1__release_id          | 1003                                                                                                                                                                                                                                                            |
	| metadata com.rackspace__1__release_build_date  | 2013-10-03_08-56-47                                                                                                                                                                                                                                             |
	| metadata com.rackspace__1__build_rackconnect   | 1                                                                                                                                                                                                                                                               |
	| metadata instance_type_swap                    | 512                                                                                                                                                                                                                                                             |
	| metadata instance_type_memory_mb               | 512                                                                                                                                                                                                                                                             |
	| id                                             | dfef31c2-d0dc-4644-9c53-d45963115310                                                                                                                                                                                                                            |
	| metadata org.openstack__1__os_distro           | com.ubuntu                                                                                                                                                                                                                                                      |
	| metadata com.rackspace__1__visible_managed     | 0                                                                                                                                                                                                                                                               |
	| metadata instance_type_rxtx_factor             | 80                                                                                                                                                                                                                                                              |
	| metadata os_type                               | linux                                                                                                                                                                                                                                                           |
	| metadata image_type                            | snapshot                                                                                                                                                                                                                                                        |
	| OS-DCF:diskConfig                              | AUTO                                                                                                                                                                                                                                                            |
	| metadata password_0                            | RJZbqpD8bgj4TlyceXQ0WUASFIuFYkHIT30/TlWEgIEwqwfv5PAUJuDWCDbKuSEN7sZSiJfF3LTb+2ibyb3UoIgiA9KWQIbL3TuyxrchSyEZRQI3HZQn/2GQNFgif8Nr7769krmtdTvZDxaV+ZOW7JMZGn2Mcs2NTzvYE/7jQEvRA4k7LmUVfqBVbBNk5EXhgWfY3Guc7YulJ+bGsyBvroVY7RVTztFsFnaVq0XXnnROPt+bbmJBepgm+U1f7UI |
	| metadata password_1                            | pkPyw++QUOr09k9YLj9PrsgF3IvXb33UgWUw/FRtbjyAKqskGcTH5gsxX9SnLUhsE3V1sVUVr97jBDfvgsA5wNw==                                                                                                                                                                       |
	| minRam                                         | 512                                                                                                                                                                                                                                                             |
	| status                                         | SAVING                                                                                                                                                                                                                                                          |
	| metadata os_distro                             | ubuntu                                                                                                                                                                                                                                                          |
	| updated                                        | 2013-11-02T04:27:28Z                                                                                                                                                                                                                                            |
	| metadata instance_type_id                      | 2                                                                                                                                                                                                                                                               |
	| metadata instance_type_vcpu_weight             | 10                                                                                                                                                                                                                                                              |
	| metadata org.openstack__1__architecture        | x64                                                                                                                                                                                                                                                             |
	| metadata com.rackspace__1__build_core          | 1                                                                                                                                                                                                                                                               |
	| metadata base_image_ref                        | 25de7af5-1668-46fb-bd08-9974b63a4806                                                                                                                                                                                                                            |
	| metadata com.rackspace__1__build_managed       | 1                                                                                                                                                                                                                                                               |
	| metadata com.rackspace__1__release_version     | 7                                                                                                                                                                                                                                                               |
	| metadata org.openstack__1__os_version          | 12.04                                                                                                                                                                                                                                                           |
	| metadata instance_type_name                    | 512MB Standard Instance                                                                                                                                                                                                                                         |
	| progress                                       | 50                                                                                                                                                                                                                                                              |
	| metadata instance_type_flavorid                | 2                                                                                                                                                                                                                                                               |
	| name                                           | web-snapshot                                                                                                                                                                                                                                                    |
	| metadata instance_type_vcpus                   | 1                                                                                                                                                                                                                                                               |
	| metadata user_id                               | 97f0118696f24dc18031b5f9a0cfd9df                                                                                                                                                                                                                                |
	| OS-EXT-IMG-SIZE:size                           | 0                                                                                                                                                                                                                                                               |
	| created                                        | 2013-11-02T04:27:21Z                                                                                                                                                                                                                                            |
	| minDisk                                        | 20                                                                                                                                                                                                                                                              |
	| server                                         | 659fe85d-a59d-4e04-9785-e2942eea1f1b                                                                                                                                                                                                                            |
	| metadata instance_type_root_gb                 | 20                                                                                                                                                                                                                                                              |
	| metadata auto_disk_config                      | True                                                                                                                                                                                                                                                            |
	| metadata com.rackspace__1__source              | kickstart                                                                                                                                                                                                                                                       |
	| metadata instance_type_ephemeral_gb            | 0                                                                                                                                                                                                                                                               |
	+------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

Next exercise is [object storage].

[object storage]: object-storage.md

