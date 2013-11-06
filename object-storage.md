# Object storage

OpenStack Object Storage allows you to store files. Here we'll use Rackspace Cloud Files, which is built on top of OpenStack Object Storage.

## Upload a file

Here we're going to upload a file into the "hackspace" container. We'll use an OpenStack logo as our file:

![image](http://www.openstack.org/assets/openstack-logo/openstack-cloud-software-vertical-small.png)


Download the file [openstack-cloud-software-vertical-small.png] to your local machine:

	$ wget http://www.openstack.org/assets/openstack-logo/openstack-cloud-software-vertical-small.png

Now, upload this file to object store into a new container called "hackspace":

    $ swift upload hackspace openstack-cloud-software-vertical-small.png

The hackspace container should now appear:

    $ swift list

Output should look like:

    hackspace

The contents of the container should be the file:

	$ swift list hackspace

Output should look like:

	openstack-cloud-software-vertical-small.png

[openstack-cloud-software-vertical-small.png]: http://www.openstack.org/assets/openstack-logo/openstack-cloud-software-vertical-small.png

## Download a file

Download the file from Openstack Object Storage to your local machine, giving it a different name (logo.png):

    $ swift download hackspace openstack-cloud-software-vertical-small.png --output logo.png


Next exercise is [DevStack].

[DevStack]: devstack.md

