# Under the hood: volumes

You should have one volume attached to your instance:

    $ nova volume-list
    +--------------------------------------+--------+--------------+------+-------------+----------+--------------------------------------+
    |                  ID                  | Status | Display Name | Size | Volume Type | Bootable |             Attached to              |
    +--------------------------------------+--------+--------------+------+-------------+----------+--------------------------------------+
    | 16150e7c-92b1-4bfd-a425-450bf4de6f36 | in-use |   myvolume   |  1   |     None    |  false   | 291574d9-7445-4231-b248-bafbf3b116ec |
    +--------------------------------------+--------+--------------+------+-------------+----------+--------------------------------------+

## LVM

The default DevStack configuration uses LVM to implement volumes. DevStack
uses an LVM volume group caled `stack-volumes`, which you can list using the
`vgs` command:

    $ sudo vgs
      VG            #PV #LV #SN Attr   VSize  VFree
      stack-volumes   1   1   0 wz--n- 10.01g 9.01g

We can get a detailed display of all of the logical volumes:

    $ sudo lvdisplay
      --- Logical volume ---
      LV Name                /dev/stack-volumes/volume-16150e7c-92b1-4bfd-a425-450bf4de6f36
      VG Name                stack-volumes
      LV UUID                UgFMV0-3uBM-r4p8-LCla-Kuk2-0Fvj-YFxCyB
      LV Write Access        read/write
      LV Status              available
      # open                 1
      LV Size                1.00 GiB
      Current LE             256
      Segments               1
      Allocation             inherit
      Read ahead sectors     auto
      - currently set to     256
      Block device           252:0

Note how the the volume name `volume-16150e7c-92b1-4bfd-a425-450bf4de6f36`
matches the OpenStack volume ID `16150e7c-92b1-4bfd-a425-450bf4de6f36`.


In a DevStack deployment, the physical volumes are backed by a file `/opt/stack/data/stack-volumes-backing-file`
that is exposed as a loop device. Try running the following commands:

    $ file /opt/stack/data/stack-volumes-backing-file
    $ sudo losetup -a


In a production OpenStack production that used LVM, the physical volumes
would be actually disk partitions instead of files mounted as loopback devices.


# iscsi

OpenStack uses iSCSI to allow virtual machines to connect to LVM volumes on
remote systems.

In a DevStack deployment, the same system is both the iSCSI server and iSCSI
client. In a production environment the LVM volumes would be located on a
different physical machine than the one running the hypervisor.

Try running the following command to view information about volumes that
are being exported over iSCSI.

    $ sudo tgtadm --lld iscsi --op show --mode target



The next exercise is [Under the hood: networking].

[Under the hood: networking]: under-the-hood-network.md
