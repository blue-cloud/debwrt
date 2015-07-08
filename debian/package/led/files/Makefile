#
#
all:
	@echo Nothing to compile, bye!

install:
	# this is tuned towards debwrt package 'led', not intended for elsewhere
	mkdir -p debian/led/etc
	mkdir -p debian/led/etc/rc0.d
	mkdir -p debian/led/etc/rc2.d
	mkdir -p debian/led/etc/rc6.d
	mkdir -p debian/led/etc/rcS.d
	cp etc/rc0.d/* debian/led/etc/rc0.d
	cp etc/rc2.d/* debian/led/etc/rc2.d
	cp etc/rc6.d/* debian/led/etc/rc6.d
	cp etc/rcS.d/* debian/led/etc/rcS.d

clean:
	@echo AFAIK nothing to clean
