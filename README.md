# docker-nginx-rtmp
Docker image with nginx + rtmp  module

*RTMP `live` application is the only app created by default*

# Pulling docker image from docker hub
1. Ensure you have [docker](https://www.docker.com) installed
2. Type: `docker pull jcenzano/nginx-rtmp`

# Creating the docker image locally (optional)
1. Ensure you have docker [docker](https://www.docker.com) and make installed
2. Type `make`

# Testing the image
You can test the rtmp server included in this image doing the following:
1. Run the docker as a daemon: `docker run --rm -itd -p 1935:1935 jcenzano/nginx-rtmp`
2. Create a RTMP stream against the container, you can use ffmpeg for that:
```
#Streams 30s of live test stream to rtmp://localhost:1935/live/test

ffmpeg -f lavfi -re \
-i testsrc=duration=30:size=1280x720:rate=30 \
-f lavfi -re -i sine=frequency=1000:duration=30:sample_rate=44100 \
-pix_fmt yuv420p -c:v libx264 -b:v 3000k -g 30 -keyint_min 240 -profile:v baseline -preset veryfast -c:a libfdk_aac -b:a 96k \
-f flv rtmp://localhost:1935/live/test

```
3. Connect to the server and play/save that stream using RTMP, you can use VLC or again ffmpeg:
```
ffmpeg -i rtmp://localhost:1935/live/test -codec copy -f flv test.flv
```

Note: If you have problems installing ffmpeg locally you can use this ffmpeg containerized: [jcenzano/ffmpeg](https://github.com/jordicenzano/docker-ffmpeg)