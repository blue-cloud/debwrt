#
#  rules/users.mk
#  make  include file
#
#  constains (personal) modifications for developers and other power user
#
amain: .config 
	sed -i 's!CONFIG_DEBIAN_BUILDENV_REPOSITORY.*!CONFIG_DEBIAN_BUILDENV_REPOSITORY="http://10.0.2.10:3142/ftp.debian.nl/debian"!' $(TOPDIR)/.config 
	sed -i 's!CONFIG_EMDEBIAN_BUILDENV_REPOSITORY.*!CONFIG_EMDEBIAN_BUILDENV_REPOSITORY="http://10.0.2.10:3142/www.emdebian.org/debian"!' $(TOPDIR)/.config 
	sed -i 's!CONFIG_OPENWRT_DOWNLOAD_DIR.*!CONFIG_OPENWRT_DOWNLOAD_DIR="../../../dl"!' $(TOPDIR)/.config 

bitten: .config 
	sed -i 's!CONFIG_DEBIAN_BUILDENV_REPOSITORY.*!CONFIG_DEBIAN_BUILDENV_REPOSITORY="http://10.0.2.10:3142/ftp.debian.nl/debian"!' $(TOPDIR)/.config 
	sed -i 's!CONFIG_EMDEBIAN_BUILDENV_REPOSITORY.*!CONFIG_EMDEBIAN_BUILDENV_REPOSITORY="http://10.0.2.10:3142/www.emdebian.org/debian"!' $(TOPDIR)/.config 
	sed -i 's!CONFIG_OPENWRT_DOWNLOAD_DIR.*!CONFIG_OPENWRT_DOWNLOAD_DIR="~/dl"!' $(TOPDIR)/.config 
