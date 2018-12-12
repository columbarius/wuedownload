all: build-sourcedir clean

build-sourcedir: 
	+$(MAKE) -C src
	cp src/wuedownload.sh .

clean:
	+$(MAKE) -C src clean
