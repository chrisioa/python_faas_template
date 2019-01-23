# HOW TO DEPLOY YOUR FUNCTION IN A MULTI-ARCH DOCKERFILE (Raspbi/arm32v6 as example)

# Step 0: 

- Have a dockerhub account
- Know IP of your runnning OpenFaas instance
- ...

# Step 1: Write Function & Build Dockerfile for all Architectures you want to support (choose from arm32v6, amd64, arm64v8)

- Write your function in handler.py
- Enter info in python_function.yml (IP address of OpenFaas, your dockerhub repo, etc. )
- The image name can specify the architecture or not: 
    - chrisioa/faas-python:0.0.1 or
    - chrisioa/faas-python:linux-arm32v6-0.0.1 should work (because of the manifest)
- make ARCHITECTURES=arm32v6
- make ARCHITECTURES=amd64
- make ARCHITECTURES=arm64v8

# Step 2: Push each to dockerhub

- Login to your dockerhub account
- make ARCHITECTURES=arm32v6 push
- make ARCHITECTURES=amd64 push
- make ARCHITECTURES=arm64v8 push

# Step 3: Manifest
- make manifest

# Step 4: Register Function
- make deploy

# Step 4: Test your function!
- http://<GATEWAY>:8080/ui/
