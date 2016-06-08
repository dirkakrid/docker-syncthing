#Makefile for Docker container control

# Include additional variables
include /srv/syncthing/a.mk

# Define container repo and runtime name
CONTAINER_REPO = hobbsau/syncthing
CONTAINER_RUN = syncthing-service

# Define the exportable volumes for the container
CONFIG_VOL = /var/lib/syncthing

# This should point to the Docker host directory containing the config. The host directory must be owned by UID:GID 1000:1000. The format is '/host/directory:'
CONFIG_BIND = /srv/syncthing/config:

# URL for triggering a rebuild
TRIGGER_URL = https://registry.hub.docker.com/u/hobbsau/syncthing/trigger/e8dbbdb4-d619-4374-bf5f-10fe077dfed7/

# Trigger a remote initiated rebuild
build:
	echo "Rebuilding repository $(CONTAINER_REPO) ..."; 
	@curl --data build=true -X POST $(TRIGGER_URL) 

# Intantiate service continer and start it
run: 
	@if [ -z "`docker ps -a -q -f name=$(CONTAINER_RUN)`" ]; \
	then \
		echo "Checking for latest container..."; \
		docker pull $(CONTAINER_REPO); \
		echo "Creating and starting container..."; \
		docker run -d \
 		--restart=always \
 		-p 8384:8384 -p 22000:22000 -p 21025:21025/udp \
		-v $(CONFIG_BIND)$(CONFIG_VOL) \
 		-v $(DATA_BIND_1)$(DATA_VOL_1) \
 		--name $(CONTAINER_RUN) \
 		$(CONTAINER_REPO); \
	else \
		echo "$(CONTAINER_RUN) is already running or a stopped container by the same name exists!"; \
		echo "Please try 'make clean' and then 'make run'"; \
	fi

# Start the service container. 
start:
	@if [ -z "`docker ps -q -f name=$(CONTAINER_RUN)`" ] && [ -n "`docker ps -a -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Starting container..."; \
		docker start $(CONTAINER_RUN); \
	else \
		echo "Container $(CONTAINER_RUN) doesn't exist or is already running!"; \
	fi

# Stop the service container. 
stop:
	@if [ -z "`docker ps -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Nothing to stop as container $(CONTAINER_RUN) is not running!"; \
	else \
		echo "Stopping container..."; \
		docker stop $(CONTAINER_RUN); \
	fi

# Service container is ephemeral so clean should be used with impunity.
clean: stop
	@if [ -z "`docker ps -a -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Nothing to remove as container $(CONTAINER_RUN) does not exist!"; \
	else \
		echo "Removing container..."; \
		docker rm $(CONTAINER_RUN); \
	fi

# Upgrade the container - may not work if rebuild takes too long
upgrade: build clean run
