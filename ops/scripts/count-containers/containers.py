#!/usr/bin/env python3

import subprocess

docker_command = "docker ps --filter 'status=running' --format '{{.ID}}' | wc -l"
running_containers = int(subprocess.check_output(docker_command, shell=True).strip())

# Write the metric to the text file
write_success = False

subprocess.run(['mkdir', '-p', '/tmp/textfile'], check=True)
with open('/tmp/textfile/containers.prom.$$', 'w') as f:
    f.write('# HELP docker_containers_total Number of currently running docker containers\n')
    f.write('# TYPE docker_containers_total gauge\n')
    f.write(f'docker_containers_total {running_containers}\n')
    write_success = True

if write_success:
    # move file to correct prom file
    subprocess.run(['mv', '/tmp/textfile/containers.prom.$$', '/tmp/textfile/containers.prom'], check=True)

