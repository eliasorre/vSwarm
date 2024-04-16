#!/bin/bash
/app/pin/pin -t /app/pin/tracer/obj-intel64/champsim_tracer.so -o /app/logs/champsim.trace -p 1 -t 100000000 --sleep 2000 -- /app/python/bin/python3.11 -u ./decode.py -addr=recog:50053 -sp=50052 -frames=3 -zipkin=http://zipkin:9411/api/v2/spans >> /app/logs/tracer_log
