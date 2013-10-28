# Deploying a web app

We're going to deploy Mezzanine, a content-management system, inside of an OpenStack virtual machine instance.

We're going to put our instance on a private network, and then make it reachable by attaching a floating IP to it.

## Add a keypair

First thing we need to do is create a new ssh keypair so that we can ssh to our instances. In these examples, we'll create a new keypair, although you can also upload an existing public key.

We'll call our key "lisa":

    nova keypair-add lisa > lisa.key
    
We also need to set permissions on it otherwise ssh won't let us use it.
    
    chmod 0600 lisa.key
   


## Networking

You should have a private and public network already created in your account:


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
	| id       | b05b9e83-3c4e-45af-9a73-9eb058d3ee7d |
	| label    | hackspace                            |
	+----------+--------------------------------------+
	
It should now show up in a list of networks:

	$ nova network-list
	+--------------------------------------+-----------+--------------+
	| ID                                   | Label     | CIDR         |
	+--------------------------------------+-----------+--------------+
	| b05b9e83-3c4e-45af-9a73-9eb058d3ee7d | hackspace | 10.30.0.0/24 |
	| 00000000-0000-0000-0000-000000000000 | public    |              |
	| 11111111-1111-1111-1111-111111111111 | private   |              |
	+--------------------------------------+-----------+--------------+
	
## Booting a new instance
	
Now we're going to boot an Ubuntu 12.04 instance into this network. We'll assign it IP address 10.30.0.5.

We're going to use flavor `2` (512 MB Standard Instance), and image `25de7af5-1668-46fb-bd08-9974b63a4806` (Ubuntu 12.04)

We'll call it `web`:


	nova boot --flavor 2 --image 25de7af5-1668-46fb-bd08-9974b63a4806 --key-name lisa --nic net-id=b05b9e83-3c4e-45af-9a73-9eb058d3ee7d,v4-fixed-ip=10.30.0.5 web
	
Initial output should look like this:

------------------------+--------------------------------------+
| Property               | Value                                |
+------------------------+--------------------------------------+
| status                 | BUILD                                |
| updated                | 2013-10-28T02:47:07Z                 |
| OS-EXT-STS:task_state  | scheduling                           |
| key_name               | lisa                                 |
| image                  | Ubuntu 12.04 LTS (Precise Pangolin)  |
| hostId                 |                                      |
| OS-EXT-STS:vm_state    | building                             |
| flavor                 | 512MB Standard Instance              |
| id                     | 859a8215-989d-4129-bb26-4bfac76e0cd9 |
| user_id                | 10111842                             |
| name                   | web                                  |
| adminPass              | cK5Dgnmcb5Wb                         |
| tenant_id              | 856545                               |
| created                | 2013-10-28T02:47:07Z                 |
| OS-DCF:diskConfig      | AUTO                                 |
| accessIPv4             |                                      |
| accessIPv6             |                                      |
| progress               | 0                                    |
| OS-EXT-STS:power_state | 0                                    |
| config_drive           |                                      |
| metadata               | {}                                   |
+------------------------+--------------------------------------+

The `nova list` command will give you information about the status.