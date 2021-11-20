#!/usr/bin/env make

.PHONY: lint
lint:
	hadolint --ignore DL3031 --ignore DL3033 --ignore DL3013 --ignore DL3003 --ignore SC2039 Dockerfile

.PHONY: size
size: build
	dive artis3n/docker-oraclelinux8-ansible:$${TAG:-test}

.PHONY: test
test: build
	dgoss run -it --rm --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro artis3n/docker-oraclelinux8-ansible:$${TAG:-test}
	CI=true make size

.PHONY: test-edit
test-edit: build
	dgoss edit -it --rm --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro artis3n/docker-oraclelinux8-ansible:$${TAG:-test}

.PHONY: build
build:
	docker build . -t artis3n/docker-oraclelinux8-ansible:$${TAG:-test}

.PHONY: run
run: build
	docker run -id --rm --name runner --privileged --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro artis3n/docker-oraclelinux8-ansible:$${TAG:-test}
	-docker exec -it runner /bin/sh
	docker stop runner
