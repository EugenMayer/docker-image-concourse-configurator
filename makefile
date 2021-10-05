build:
	docker build . -t ghcr.io/eugenmayer/concourse-configurator:7.x

push:
	docker push ghcr.io/eugenmayer/concourse-configurator:7.x
