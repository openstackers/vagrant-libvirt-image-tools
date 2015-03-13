vagrant-libvirt-image-tools
===========================

Build vagrant-libvirt boxes from manifests or take existing images and
turn them into vagrant-libvirt boxes.


build.sh
--------

Creates a vagrant box from a manifest. E.g.:

```bash
./build.sh manifests/centos-7.0.sh
```

See the `manifests` directory for example manifests.


vagrantize.sh
-------------

Creates a vagrant box from an existing qcow2 image. E.g.:

```bash
BOX_NAME=my_box IMAGE_SIZE=30 ./vagrantize.sh my_box.qcow2
```


-------------

Thanks to James Shubin (purpleidea) for creating his
[vagrant-builder](https://github.com/purpleidea/vagrant-builder),
which is a similar tool and many ideas and approaches are taken from
there.
