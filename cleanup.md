# Clean up

## Instances

Make sure there are no instances running:

    $ nova list

If there are, delete them:

    $ nova delete devstack

## Networks

Make sure the only networks that remain are `public` and `private`:

    $ nova network-list

If there are other networks, delete them:

    $ nova network-delete hackspace

## Volumes

Make sure there are no volumes remainig:

    $ nova volume-list

If there are, delete them:

    $ nova volume-delete 455ec395-cfab-4319-bbf0-1d061c14a7e8

## Images

Make sure there are no images you created remaining:

    $ nova image-list

If there are images you created, delete them:

    $ nova image-delete web-snapshot

## Object storage

Make sure there are no containers remaining:

    $ swift list

If there are, delete them:

    $ swift delete hackspace
