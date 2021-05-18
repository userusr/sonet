{%- if docker_registry_url is defined -%}
  {%- set registry_url = docker_registry_url + '/' -%}
{%- else -%}
  {%- set registry_url = '' -%}
{%- endif -%}
.DEFAULT_GOAL := build

TAG ?= latest
REGISTRY ?= {{ registry_url }}
NAME ?= {{project}}-{{ service_name }}

build:
	docker build . --tag $(REGISTRY)$(NAME):$(TAG)

push:
	@[ "$(REGISTRY)" ] \
		&& docker push $(REGISTRY)$(NAME):$(TAG) \
		|| ( echo "registry for "$(NAME)" is not set"; exit 0 )
