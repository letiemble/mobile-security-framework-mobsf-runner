# Mobile Security Framework (MobSF) Runner

A Docker image to scan a target with the [Mobile Security Framework (MobSF)](https://github.com/MobSF/Mobile-Security-Framework-MobSF) web application.

The runner scripts:
- upload the target file to the MobSF web application
- start the scan
- download the scoreboard
- download the PDF report

## Usage

To use the image, run the following command:

```shell
INPUT_FILE=target.apk docker run --rm -it -e INPUT_FILE=MyApp.apk -v .:/input -v .:/output letiemble/mobile-security-framework-mobsf-runner:latest
```

- The `/input` volume is used as the base mount point for the container and should contain the target file to scan.
- The `/output` volume is used as the base mount point for the container and will contain the scan results.

## Usage with compose

A sample [Docker Compose file](./docker-compose.yml) is provided to demonstrate how to run both the MobSF web application and the runner.
When the runner is done, the container will stop and be removed.

```shell
INPUT_FILE=MyApp.apk docker-compose up --abort-on-container-exit; docker-compose rm -f
```

Both the application package and the results are stored in the current directory.

## Build

To build the image, run the following command:

```shell
docker buildx build -t letiemble/mobile-security-framework-mobsf-runner:latest .
```

To build the multi-architecture image, run the following command:

```shell
docker buildx create --name BUILDER --use
docker buildx build --platform linux/amd64,linux/arm64 -t letiemble/mobile-security-framework-mobsf-runner:latest --push .
docker buildx rm BUILDER
```
