ARG DOCKER_IMAGE
FROM ${DOCKER_IMAGE}-stage1
ENV DOCKER_IMAGE=${DOCKER_IMAGE}
RUN for i in DOCKER_IMAGE;do\
    eval ': ${'$i':?Please provide --build-arg=$i}' >&2;done
WORKDIR /provision_dir
ADD . .
RUN $_caa -e "{only_steps: true, \
  cops_django_lifecycle_app_push_code: true, \
  cops_django_s_layout: true, \
  cops_django_s_first_fixperms: true, \
  cops_django_s_prerequisites: true, \
  cops_django_s_setup: true, \
  cops_django_s_reverse_proxy: true, \
  cops_django_s_workers: true, \
  cops_django_s_workers_checks: false}"

# Default to launch systemd, and you ll have have to mount:
#  -v /sys/fs/cgroup:/sys/fs/cgroup:ro
STOPSIGNAL SIGRTMIN+3
CMD ["/entry_point"]
