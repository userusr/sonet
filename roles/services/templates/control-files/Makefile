{%- if docker_registry_url is defined -%}
  {%- set registry_url = docker_registry_url + '/' -%}
{%- else -%}
  {%- set registry_url = '' -%}
{%- endif -%}
.DEFAULT_GOAL := all

export TAG ?= latest
export REGISTRY ?= {{ registry_url }}
export PROJECT ?= {{project}}

IMAGES := $(wildcard ./images/*/.)

all: $(IMAGES)

$(IMAGES):
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: all $(IMAGES)
