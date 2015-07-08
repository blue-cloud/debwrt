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

# Strip quotes
qstrip=$(strip $(subst ",,$(1)))

# Get the SVN revision of something (always returns a number, 0 if absent)
get_svn_revision=$(shell if [ -d $(1) ]; then svnversion $(1) | sed -e's/^\([0-9]*\).*$$/\1/g' -e's/^$$/0/g' ; fi)

lower=$(shell echo -n $(1) | tr '[:upper:]' '[:lower:]')
upper=$(shell echo -n $(1) | tr '[:lower:]' '[:upper:]')

