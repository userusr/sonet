.DEFAULT_GOAL := all

export TAG ?= latest
export REGISTRY ?= {{ registry_url }}
export PROJECT ?= {{project}}

IMAGES := $(wildcard ./images/*/.)

all: $(IMAGES)

push: GOAL=push
push: $(IMAGES)

$(IMAGES):
	$(MAKE) -C $@ ${GOAL}

.PHONY: all push $(IMAGES)
