.DEFAULT_GOAL := build

TAG ?= latest
REGISTRY ?= {{ registry_url }}
PROJECT ?= {{project}}

ifndef PROJECT
$(error PROJECT is not defined)
endif

NAME ?= $(PROJECT)-{{ service_name }}

build:
	docker build . --tag $(REGISTRY)$(NAME):$(TAG)

push: build
	@[ "$(REGISTRY)" ] \
		&& docker push $(REGISTRY)$(NAME):$(TAG) \
		|| ( echo "registry for "$(NAME)" is not set"; exit 0 )
