HOST := $(shell hostname)
ADDR := $(shell avahi-resolve-host-name -4 ${HOST}.local | cut -f 2)

.PHONY: build
build:
	docker build -t colmap-gpu:1.0 -f ./Dockerfile .

.PHONY: run
run:
	xhost + local:root
	sudo docker run -it \
	--network="host" --ipc="host" \
	--add-host=${HOST}:${ADDR} \
	--env=DISPLAY=$(DISPLAY) \
	--env=QT_X11_NO_MITSHM=1 \
	--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	--privileged \
	--device=/dev/dri:/dev/dri \
	--gpus all \
	--mount type=bind,src=/dev,dst=/dev,readonly \
	--mount type=bind,src=images,dst=/root/images,readonly \
	--mount type=bind,src=scene,dst=/root/scene\
	--env ROS_MASTER_URI=http://${HOST}:11311 \
	colmap-gpu:1.0 /bin/bash -c "source /opt/ros/noetic/setup.bash && /opt/ros/noetic/bin/colmap -d /setting/setting.colmap"

.PHONY: run_debug
run_debug:
	xhost + local:root
	sudo docker run -it \
	--network="host" --ipc="host" \
	--add-host=${HOST}:${ADDR} \
	--env=DISPLAY=$(DISPLAY) \
	--env=QT_X11_NO_MITSHM=1 \
	--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	--privileged \
	--device=/dev/dri:/dev/dri \
	--gpus all \
	--mount type=bind,src=/dev,dst=/dev,readonly \
	--env ROS_MASTER_URI=http://${HOST}:11311 \
	colmap-gpu:1.0 /bin/bash