# Usage

First navigate to the directory you cloned to, then build:
```docker build .```

The code checkout happens at build time, this is intentional. Optionally tag the build for better referencing.
```docker tag [image] foo/bar:baz```

Spin it up, binding local port 8080 to container port 80:
```docker run --rm -it -p 8080:80 [image]```

Navigate to http://localhost:8080/ and finish the setup. Note: it doesn't always properly redirect back to the main index.
