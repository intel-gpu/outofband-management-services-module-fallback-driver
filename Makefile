MODULE_NAME := intel-oobmsm-dummy
VERSION := 0.1.0
RELEASE := 1

ifdef BUILD_NUMBER
	RELEASE := $(BUILD_NUMBER)
endif

MODULE := $(MODULE_NAME)-$(VERSION)-$(RELEASE)

RPM_SPEC := intel_oobmsm_dummy.spec
DKMS_CONFIG := dkms.conf
DEB_CONTROL := control
DEB_POSTINST := postinst
DEB_PRERM := prerm
DEB_COPYRIGHT := copyright
RPM_LICENSE := LICENSE
TARBALL := $(MODULE)-src.tar.gz
TAR_CONTENT := $(RPM_SPEC) $(DKMS_CONFIG) src/drivers/platform/x86/*.c README.rst Makefile LICENSES $(RPM_LICENSE)
DEB_CONTENT := $(DKMS_CONFIG) src/ README.rst Makefile LICENSES
DEB_SRC := $(MODULE)/usr/src/$(MODULE)
DEB_DOC := $(MODULE)/usr/share/doc/$(MODULE_NAME)

ifneq ($(KERNELRELEASE),)
obj-m := src/drivers/platform/x86/intel_oobmsm_dummy.o

else
KDIR ?= /lib/modules/`uname -r`/build

.PHONY: default clean modules_install help dkmsconf pkginfo-rpm pkginfo-deb tarball-rpm prep-deb dkmsrpm-pkg dkmsdeb-pkg

default:
	$(MAKE) -C $(KDIR) M=$$PWD
	mkdir -p bin
	cp src/drivers/platform/x86/*.ko bin/

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean
	rm -rf bin/ $(RPM_SPEC) $(DKMS_CONFIG) $(TARBALL) $(MODULE) $(MODULE).deb

modules_install:
	$(MAKE) -C $(KDIR) M=$$PWD modules_install

help:
	$(MAKE) -C $(KDIR) M=$$PWD help

dkmsconf:
	sed -e "s/_MODULE_NAME_/${MODULE_NAME}/;s/_VERSION_/${VERSION}-${RELEASE}/" templates/$(DKMS_CONFIG) > $(DKMS_CONFIG)

pkginfo-rpm: dkmsconf
	sed -e "s/_MODULE_NAME_/${MODULE_NAME}/;s/_VERSION_/${VERSION}/;s/_RELEASE_/${RELEASE}/" templates/rpm/$(RPM_SPEC) > $(RPM_SPEC)
	cp templates/rpm/$(RPM_LICENSE) $(RPM_LICENSE)

pkginfo-deb: dkmsconf
	mkdir -p $(MODULE)/DEBIAN
	sed -e "s/_MODULE_NAME_/${MODULE_NAME}/;s/_VERSION_/${VERSION}/;s/_RELEASE_/${RELEASE}/" templates/deb/$(DEB_CONTROL) > $(MODULE)/DEBIAN/$(DEB_CONTROL)
	sed -e "s/_MODULE_NAME_/${MODULE_NAME}/;s/_VERSION_/${VERSION}/;s/_RELEASE_/${RELEASE}/" templates/deb/$(DEB_POSTINST) > $(MODULE)/DEBIAN/$(DEB_POSTINST)
	sed -e "s/_MODULE_NAME_/${MODULE_NAME}/;s/_VERSION_/${VERSION}/;s/_RELEASE_/${RELEASE}/" templates/deb/$(DEB_PRERM) > $(MODULE)/DEBIAN/$(DEB_PRERM)
	cp templates/deb/$(DEB_COPYRIGHT) $(MODULE)/DEBIAN/$(DEB_COPYRIGHT)
	chmod a+x $(MODULE)/DEBIAN/$(DEB_POSTINST) $(MODULE)/DEBIAN/$(DEB_PRERM)

tarball-rpm: pkginfo-rpm
	tar -czf $(TARBALL) $(TAR_CONTENT)

prep-deb: pkginfo-deb
	mkdir -p $(DEB_SRC)
	cp -r $(DEB_CONTENT) $(DEB_SRC)
	mkdir -p $(DEB_DOC)
	cp -r templates/deb/$(DEB_COPYRIGHT) $(DEB_DOC)

dkmsrpm-pkg: tarball-rpm
	+rpmbuild -ta $(TARBALL)

dkmsdeb-pkg: prep-deb
	+dpkg-deb --build $(MODULE)

endif
