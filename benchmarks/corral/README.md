# Corral Benchmark

This benchmark uses the [Corral MapReduce framework](https://github.com/bcongdon/corral):

Corral is a MapReduce framework designed to be deployed to serverless platforms, like 
[AWS Lambda](https://aws.amazon.com/lambda/). It presents a lightweight alternative to Hadoop 
MapReduce. Much of the design philosophy was inspired by Yelp's mrjob -- corral retains mrjob's ease-of-use while gaining the 
type safety and speed of Go.

## Parameters

### Environment Variables

- `TRANSFER_TYPE` - The transfer type to use. Can be `INLINE` (default), `S3`, or `XDT`. Not
all benchmarks support all transfer types.
- `AWS_ACCESS_KEY`, `AWS_SECRET_KEY`, `AWS_REGION` - Standard s3 keys, only needed if the s3
transfer type is used
- `ENABLE_TRACING` - Toggles tracing - Not supported by this benchmark
- `PORT` - Specifies the port which the driver listens to.
- `CORRAL_DRIVER` - Used to toggle between driver and worker functionality during function setup.

## Benchmark Results

| Benchmark      | Job Execution Time |
|----------------|--------------------|
| test_wc_local  | 170ms              |
| test_wc_s3     | 3.79sec            |
| test_wc_lambda | 3.92sec            |