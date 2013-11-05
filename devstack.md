# DevStack

DevStack is an all-in-one OpenStack deployment. In this exercise, we'll
deo a DevStack deployment of the Havana release of OpenStack.

## Launch an instance

We'll use an 8GB standard instance on Ubuntu 13.10:

    $ nova boot --flavor 6 --image 868a0966-0553-42fe-b8b3-5cadc0e0b3c5 --key-name lisa devstack

Output should look like:

    +------------------------+--------------------------------------+
    | Property               | Value                                |
    +------------------------+--------------------------------------+
    | status                 | BUILD                                |
    | updated                | 2013-11-04T04:15:56Z                 |
    | OS-EXT-STS:task_state  | scheduling                           |
    | key_name               | lisa                                 |
    | image                  | Ubuntu 13.10 (Saucy Salamander)      |
    | hostId                 |                                      |
    | OS-EXT-STS:vm_state    | building                             |
    | flavor                 | 8GB Standard Instance                |
    | id                     | 7643b6d2-5782-435a-9056-1e82ac51c853 |
    | user_id                | 97f0118696f24dc18031b5f9a0cfd9df     |
    | name                   | devstack                             |
    | adminPass              | Y9FPzmiVbnF9                         |
    | tenant_id              | 869769                               |
    | created                | 2013-11-04T04:15:56Z                 |
    | OS-DCF:diskConfig      | AUTO                                 |
    | accessIPv4             |                                      |
    | accessIPv6             |                                      |
    | progress               | 0                                    |
    | OS-EXT-STS:power_state | 0                                    |
    | config_drive           |                                      |
    | metadata               | {}                                   |
    +------------------------+--------------------------------------+

You can check the status by doing:

    $ nova show devstack

The "progress" field will tell you the % complete. When the status reaches
`ACTIVE`, the server is ready.

## SSH into the instance

If the IP address is 162.209.100.22, ssh by doing:

    $ ssh -i lisa.key root@162.209.100.22

## Install git

Once inside the instance, update the apt cache and install git:

    # apt-get update
    # apt-get install git

## Grab DevStack

Grab DevStack and switch to the stable/havana branch:

    git clone https://github.com/openstack-dev/devstack.git -b stable/havana

## Create a "stack" user

DevStack can't run as root, so create a "stack" user like this:

    # chmod +x /root/devstack/tools/create-stack-user.sh
    # /root/devstack/tools/create-stack-user.sh

Output should be:

    Creating a group called stack
    Creating a user called stack
    Giving stack user passwordless sudo privileges

## Switch to the stack user

    # sudo -u stack -i

## Check out devstack as stack user

    git clone https://github.com/openstack-dev/devstack.git -b stable/havana


## Create /opt/stack/devstack/local.conf

Create `/opt/stack/devstack/local.conf` with the following contents.

Note: You must change `HOST_IP` to match your actual public IP.



    [[local|localrc]]
    # Default passwords
    ADMIN_PASSWORD=password
    MYSQL_PASSWORD=password
    RABBIT_PASSWORD=password
    SERVICE_PASSWORD=password
    SERVICE_TOKEN=password


    SCREEN_LOGDIR=/opt/stack/logs


    HOST_IP=162.209.100.22

    # Enable Neutron
    disable_service n-net
    enable_service q-svc
    enable_service q-agt
    enable_service q-dhcp
    enable_service q-l3
    enable_service q-meta
    enable_service neutron

    # Enable Swift
    enable_service s-proxy
    enable_service s-object
    enable_service s-container
    enable_service s-account

    # Disable security groups entirely
    Q_USE_SECGROUP=False
    LIBVIRT_FIREWALL_DRIVER=nova.virt.firewall.NoopFirewallDriver

    # Disable tempest
    disable_service tempest

## Run stack.sh as stack user

    $ cd ~/devstack
    $ ./stack.sh
    
When it asks for a random swift hash, hit enter.

It will then proceed to install OpenStack on the single node. This will take a while.

