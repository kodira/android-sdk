# android-sdk
Docker image to build Android apps.

Images are automatically built and published to GitHub Container Registry **only** when a git tag is pushed (not on commits to master).

## Usage

```bash
# Use latest version
docker pull ghcr.io/kodira/android-sdk:latest

# Use specific version
docker pull ghcr.io/kodira/android-sdk:36-java21-node24
```

## Creating a New Release

To create a new tagged release, create and push a git tag:

```bash
git tag <unique tag name>
git push <unique tag name>
```

CI will automatically build and publish to `ghcr.io/kodira/android-sdk:<unique tag name>`

## Manual Build

```bash
docker build -t ghcr.io/kodira/android-sdk:36-java21-node24 .
docker push ghcr.io/kodira/android-sdk:36-java21-node24
```
