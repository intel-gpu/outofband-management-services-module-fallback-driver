Intel® Out-of-Band Management Services Module Fallback Driver
-------------------------------------------------------------

Copyright (c) 2022, Intel Corporation.
All Rights Reserved.

Provides an empty implementation of basic driver functionality,
such as error handling for the function0 and function2 parts of OOBMSM devices.

In case function0 and function2 parts of the OOBM Services Module device are unused,
and the system uses mechanisms which require all parts of a device to have a loaded driver,
you may find this driver suitable.
One such a scenario is DPC for PCI device error containment.


Building (DKMS package)
_______________________

You can build a DKMS package in either .rpm or .deb archives.
Note that they require appropriate packaging tools for your distribution installed.

rpm:

	make dkmsrpm-pkg

Requires ``rpmbuild``
Result will be located in ``./noarch/``


deb:

	make dkmsdeb-pkg

Requires ``dpkg-deb``

Note:
The module will not be started automatically at this time.
Use `modprobe intel-oobmsm-dummy` or configure your system to load it automatically.

Building (manual installation)
------------------------------

In order to build the driver, do

   make

The resulting module will be located in the ``bin/`` folder.
The module can be installed using ``insmod``.

The module by default is built against kernel headers located in:
``/lib/modules/`uname -r`/build``
It can be overridden by passing a new path via ``KDIR=<path>``.

