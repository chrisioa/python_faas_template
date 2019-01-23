#Default Values, can/should be overwritten
ARCHITECTURES= arm32v6 arm64v8 amd64
HANDLER_FILE=handler.py
OPEN_FAAS_VERSION=0.9.10
VERSION = $(shell cat VERSION)
IMAGE_TARGET=python:3-alpine
SRC_FOLDER=src
INDEX_FILE=index.py
FUNCTION_YML=python_function.yml
### Quemu specific args:
MULTIARCH = multiarch/qemu-user-static:register
QEMU_VERSION = v2.11.0

ifeq ($(REPO),)
  REPO = chrisioa/faas-python
endif


$(ARCHITECTURES):
	@docker run --rm --privileged $(MULTIARCH) --reset
	@docker build -f Dockerfile \
			--build-arg IMAGE_TARGET=$@/$(IMAGE_TARGET) \
			--build-arg INDEX_FILE=$(INDEX_FILE) \
			--build-arg WATCHDOG_ARCH=$(strip $(call watchdogarch,$@)) \
			--build-arg SRC_FOLDER=$(SRC_FOLDER) \
			--build-arg QEMU=$(strip $(call qemuarch,$@)) \
			--build-arg QEMU_VERSION=$(QEMU_VERSION) \
			--build-arg ARCHITECTURE=$@ \
			--build-arg OPEN_FAAS_VERSION=${OPEN_FAAS_VERSION} \
			--build-arg ARCHITECTURE=$@ \
			-t $(REPO):linux-$@-$(VERSION) .
			
push: 
	@$(foreach arch,$(ARCHITECTURES), docker push $(REPO):linux-$(arch)-$(VERSION);)
	
	
manifest:
	@wget -O dockermanifest https://6582-88013053-gh.circle-artifacts.com/1/work/build/docker-linux-amd64
	@chmod +x dockermanifest
	@./dockermanifest manifest create $(REPO):$(VERSION) \
			$(foreach arch,$(ARCHITECTURES), $(REPO):linux-$(arch)-$(VERSION)) --amend
	@$(foreach arch,$(ARCHITECTURES), ./dockermanifest manifest annotate \
			$(REPO):$(VERSION) $(REPO):linux-$(arch)-$(VERSION) \
			--os linux $(strip $(call convert_variants,$(arch)));)
	@./dockermanifest manifest push $(REPO):$(VERSION)
	@rm -f dockermanifest


deploy: 
	@faas-cli deploy -f $(FUNCTION_YML)


#Watchdog files are either fwatchdog-armhf, fwatchdog-arm64 or fwatchdog for amd64 which needs interpretation:
define watchdogarch
	$(shell echo $(1) | sed -e "s|arm32.*|-armhf|g" -e "s|arm64.*|-arm64|g" -e "s|amd64||g")
endef
	
# Needed convertions for different architecture naming schemes
# Convert qemu archs to naming scheme of https://github.com/multiarch/qemu-user-static/releases
define qemuarch
	$(shell echo $(1) | sed -e "s|arm32.*|arm|g" -e "s|arm64.*|aarch64|g" -e "s|amd64|x86_64|g")
endef
# Convert GOARCH to naming scheme of https://gist.github.com/asukakenji/f15ba7e588ac42795f421b48b8aede63
define prometheusarch
	$(shell echo $(1) | sed -e "s|arm32v5|armv5|g" -e "s|arm32v6|armv6|g" -e "s|arm32v7|armv7|g" -e "s|arm64.*|arm64|g" -e "s|i386|386|g")
endef
# Convert Docker manifest entries according to https://docs.docker.com/registry/spec/manifest-v2-2/#manifest-list-field-descriptions
define convert_variants
	$(shell echo $(1) | sed -e "s|amd64|--arch amd64|g" -e "s|i386|--arch 386|g" -e "s|arm32v5|--arch arm --variant v5|g" -e "s|arm32v6|--arch arm --variant v6|g" -e "s|arm32v7|--arch arm --variant v7|g" -e "s|arm64v8|--arch arm64 --variant v8|g" -e "s|ppc64le|--arch ppc64le|g" -e "s|s390x|--arch s390x|g")
endef
