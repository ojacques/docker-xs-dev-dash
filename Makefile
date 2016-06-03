IMG_NAME=ring3-dash
DATA_CON=$(IMG_NAME)-data
DASH_CON=$(IMG_NAME)
PORTS+=-p 80:80
VOLUMES+=--volumes-from $(DATA_CON) -v /etc/localtime:/etc/localtime:ro
DEV_VOL=-v $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))):/host

build: .
	sudo docker build \
             --build-arg https_proxy=$(HTTP_PROXY) --build-arg http_proxy=$(HTTP_PROXY) \
             --build-arg HTTP_PROXY=$(HTTP_PROXY) --build-arg HTTPS_PROXY=$(HTTP_PROXY) \
             --build-arg NO_PROXY=$(NO_PROXY) -t $(IMG_NAME) .

clean:
	sudo docker rmi $(IMG_NAME)

stop:
	sudo docker rm -f $(DASH_CON) 2>/dev/null || true

run: build data stop
	sudo docker run --name=$(DASH_CON) -d -ti $(VOLUMES) $(PORTS) $(IMG_NAME)

shell: build data stop
	sudo docker run --name=$(DASH_CON) --rm -ti $(VOLUMES) $(PORTS) $(DEV_VOL) $(IMG_NAME) /bin/bash

data: build
	sudo docker run --name=$(DATA_CON) -ti $(IMG_NAME) true 2>/dev/null || true

purge: stop
	@read -n1 -r -p "This will remove all persistent data. Are you sure? " ;\
	echo ;\
	if [ "$$REPLY" == "y" ]; then \
		docker rm -f $(DATA_CON) 2>/dev/null || true; \
	fi

.PHONY: build clean run shell data purge
