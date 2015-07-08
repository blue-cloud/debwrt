# DebWrt - Debian on Embedded devices
#
# Copyright (C) 2010 Johan van Zoomeren <amain@debwrt.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

SCRIPT_DIR:=$(TOPDIR)/rules
SCRIPT_CLEAN_EXEC:=$(SCRIPT_DIR)/clean_exec.sh
SCRIPT_GET_SVN_REVISION:=$(SCRIPT_DIR)/get_svn_revision.sh
SCRIPT_KCONFIG:=$(SCRIPT_DIR)/kconfig.pl
SCRIPT_EXTRACT_KMODPKG:=$(SCRIPT_DIR)/extract_kmodpkg.sh
SCRIPT_FLASH:=$(SCRIPT_DIR)/flash.sh
SCRIPT_GET_BOARD:=$(SCRIPT_DIR)/get_sub_board.sh
