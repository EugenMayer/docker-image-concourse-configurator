build:
	docker build . -t eugenmayer/concourse-configurator:5.x

push:
	docker push eugenmayer/concourse-configurator:5.x
