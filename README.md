# android-sdk
Docker image to build Android apps.

Images are automatically built and published to GitHub Container Registry when a git tag is pushed.

## Usage

```bash
# Use latest version
docker pull ghcr.io/kodira/android-sdk:latest

# Use specific version
docker pull ghcr.io/kodira/android-sdk:36-java21
```

## Creating a New Release

To create a new tagged release, create and push a git tag:

```
git tag 36-java21
git push origin 36-java21
```

CI will automatically build and publish to `ghcr.io/kodira/android-sdk:36-java21`

## Manual Build

```
docker build -t ghcr.io/kodira/android-sdk:36-java21 .
docker push ghcr.io/kodira/android-sdk:36-java21
```
