# stargo-task

# Music App Kubernetes Deployment

## Overview

This project deploys a Go-based app server and Redis database in a Minikube Kubernetes environment.

## Project Files

1. data.rdb - A Redis database dump file
2. music_app.tar - A Go-based server application archive file contains 3 files: main.go, go.mod, go.sum
3. setup.sh - Deployment script
4. music-app-deployment.yaml - Kubernetes deployment configuration
5. redis-deployment.yaml - Redis deployment configuration
6. redis-secret.yaml - Kubernetes secret for Redis password
7. server - built Go Server
8. README.md - Documentation

## Prerequisites

- WSL 2 with Ubuntu 22.04
- Docker Desktop
- Minikube
- kubectl (installed automatically by Minikube)
- Go 1.24

## Installation

1. Ensure all prerequisites are installed

2. Copy the provided `data.rdb` file to `/lib/var/redis/data.rdb` (required sudo)

3. Copy the `music_app.tar` file to the working directory

4. Copy following configuration files to the working directory

- setup.sh
- music-app-deployment.yaml
- redis-deployment.yaml
- redis-secret.yaml

5. Make the setup script executable:

- chmod +x setup.sh

6. Run the Setup script setup.sh

- ./setup.sh

Note: If you would like to use built and committed Go Server file 'server' just copy it to the working directory and comment-out 'tar -xf music_app.tar' and 'go build' commands in setup.sh

## Access API Endpoint

- http://localhost:9090/api/v1/music-albums?key=<INT>

E.g.: 'curl http://localhost:9090/api/v1/music-albums?key=1'

## Notes

- The Redis instance is passsword protected with "secret"
- The data.rdb file relocated into minikube volume using 'minikube cp' command and mounted into Redis container
- The Go Server is compiled and committed into the project as requested
- Port forwarding implemented in the setup script

