 
 make ARCHITECTURES=arm32v6
 make ARCHITECTURES=arm64v8
 make ARCHITECTURES=amd64
 
 make ARCHITECTURES=arm32v6 push
make ARCHITECTURES=arm64v8 push
make ARCHITECTURES=amd64 push

make manifest
