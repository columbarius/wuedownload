all: build-sourcedir clean

build-sourcedir: 
	+$(MAKE) -C src
	cp src/wuedownload.sh .
	chmod u+x wuedownload.sh

clean:
	+$(MAKE) -C src clean
