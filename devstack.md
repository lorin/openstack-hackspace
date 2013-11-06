# DevStack

DevStack is a single-node OpenStack deployment intended for development use.
In this exercise, we'll do a DevStack deployment of the Havana release of
OpenStack.

We'll be using this DevStack deployment for the additional exercises as well.

## Launch an instance on Rackspace

We'll use an 8GB standard instance on Ubuntu 12.04:

    $ nova boot --flavor 6 --image c3153cde-2d23-4186-b7da-159adbe2858b --key-name lisa devstack

Output should look like:

    +------------------------+--------------------------------------+
    | Property               | Value                                |
    +------------------------+--------------------------------------+
    | status                 | BUILD                                |
    | updated                | 2013-11-04T04:15:56Z                 |
    | OS-EXT-STS:task_state  | scheduling                           |
    | key_name               | lisa                                 |
    | image                  | Ubuntu 12.04 LTS (Precise Pangolin)  |
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

If the IP address is 162.209.96.154, ssh by doing:

    $ ssh -i lisa.key root@162.209.96.154

## Install git

Once inside the instance, install git:

    # apt-get install -y git

## Grab DevStack

Grab DevStack and switch to the stable/havana branch:

    # git clone https://github.com/openstack-dev/devstack.git -b stable/havana

## Create a "stack" user

DevStack can't run as root, so create a "stack" user using the script that
comes with DevStack:

    # chmod +x /root/devstack/tools/create-stack-user.sh
    # /root/devstack/tools/create-stack-user.sh

Output should be:

    Creating a group called stack
    Creating a user called stack
    Giving stack user passwordless sudo privileges

## Switch to the stack user

    # sudo -u stack -i

## Check out devstack as stack user

    $ git clone https://github.com/openstack-dev/devstack.git -b stable/havana


## Create /opt/stack/devstack/local.conf

Create `/opt/stack/devstack/local.conf` with the following contents:


```
[[local|localrc]]
SCREEN_LOGDIR=/opt/stack/logs

# Enable Neutron
disable_service n-net
enable_service q-svc
enable_service q-agt
enable_service q-dhcp
enable_service q-l3
enable_service q-meta
enable_service neutron

# Use Neutron for security groups
LIBVIRT_FIREWALL_DRIVER=nova.virt.firewall.NoopFirewallDriver
Q_USE_SECGROUP=True

# Enable Swift
enable_service s-proxy
enable_service s-object
enable_service s-container
enable_service s-account

# Disable tempest
disable_service tempest
```


## Run stack.sh as stack user

    $ cd ~/devstack
    $ ./stack.sh

Hit enter each time it asks you a question about specifying a password to
tell DevStack to just generate passwords randomly.

It will then proceed to install OpenStack on the single node. This will take
about twelve minutes. The output should look like this, with a different
IP address.

    Horizon is now available at http://162.209.96.154/
    Keystone is serving at http://162.209.96.154:5000/v2.0/
    Examples on using novaclient command line is in exercise.sh
    The default users are: admin and demo
    The password: 08a85950ecd4cff5e631
    This is your host ip: 162.209.96.154
    stack.sh completed in 743 seconds.

The password is also set as `ADMIN_PASSWORD` in the localrc file.

Next exercise is the [Dashboard].

 [Dashboard]: dashboard.md
