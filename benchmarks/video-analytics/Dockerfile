# MIT License
#
# Copyright (c) 2021 Michal Baczun and EASE lab
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM vhiveease/python-slim:latest as recogBuilder
WORKDIR /py
RUN apt update && \
    apt install git curl -y 
COPY ./utils/tracing/python/tracing.py ./
COPY ./utils/storage/python/storage.py ./
COPY ./benchmarks/video-analytics/object_recognition/* ./
COPY ./benchmarks/video-analytics/proto/videoservice_pb2_grpc.py ./
COPY ./benchmarks/video-analytics/proto/videoservice_pb2.py ./

FROM ubuntu:24.04 as recog
COPY --from=recogBuilder /py /app
WORKDIR /app
RUN apt-get -y update
RUN apt-get -y install libb2-1
RUN apt-get -y install ca-certificates
COPY ./tools/pin/pin /pin
RUN chmod +x -R /pin
COPY ./tools/pythonNotModifed ./python
RUN  ./python/bin/python3.11 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu 
COPY ./benchmarks/video-analytics/requirements.txt ./
RUN ./python/bin/python3.11 -m pip install -r requirements.txt
RUN mkfifo /tmp/pinToolPipe

ENV PATH=/root/.local/bin:$PATH
ENTRYPOINT ["/pin/pin", "-t", "/pin/obj-intel64/champsim_tracer.so", "-o", "trace.champsim", "-t", "100000000", "-p", "1", "--" "/app/python/bin/python3.11", "-u", "./recog.py"]


FROM vhiveease/python-slim:latest as decodeBuilder
WORKDIR /py
COPY ./benchmarks/video-analytics/requirements.txt ./
RUN apt update && \
    apt-get install ffmpeg libsm6 libxext6 git curl -y && \
    pip3 install --no-cache-dir --user ffmpeg-python && \
    pip3 install --no-cache-dir --user opencv-python && \
    pip3 install --no-cache-dir --user -r requirements.txt
COPY ./utils/tracing/python/tracing.py ./
COPY ./utils/storage/python/storage.py ./
COPY ./benchmarks/video-analytics/decoder/decode.py ./
RUN mkdir frames
COPY ./benchmarks/video-analytics/proto/videoservice_pb2_grpc.py ./
COPY ./benchmarks/video-analytics/proto/videoservice_pb2.py ./

FROM vhiveease/python-slim:latest as decode
RUN apt update && apt-get install ffmpeg libsm6 libxext6  -y
COPY --from=decodeBuilder /root/.local /root/.local
COPY --from=decodeBuilder /py /app
WORKDIR /app
ENV PATH=/root/.local/bin:$PATH
ENTRYPOINT ["python3", "-u", "./decode.py"]



FROM vhiveease/golang:latest as streamingBuilder
WORKDIR /app/app/
RUN apk add --no-cache make git
RUN apk add -U --no-cache ca-certificates
COPY ./benchmarks/video-analytics/video_streaming/video-streaming.go ./video_streaming/
COPY ./benchmarks/video-analytics/video_streaming/reference ./reference
COPY ./benchmarks/video-analytics/go.mod ./
COPY ./benchmarks/video-analytics/go.sum ./
COPY ./benchmarks/video-analytics/proto ./proto
COPY ./utils/storage/go ../../utils/storage/go
COPY ./utils/tracing/go ../../utils/tracing/go
COPY ./utils/protobuf ../../utils/protobuf
RUN go mod download && \
   CGO_ENABLED=0 GOOS=linux go build -v -o ./video_streaming/streaming-bin ./video_streaming

FROM scratch as streaming
WORKDIR /app
COPY --from=streamingBuilder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=streamingBuilder /app/app/video_streaming/streaming-bin /app/gen/exe
COPY --from=streamingBuilder /app/app/reference /app/reference

ENTRYPOINT [ "/app/gen/exe" ]