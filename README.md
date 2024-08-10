# Arm bare metal example

## Build the project with cmake

CMake is the build system for the project and from the top level directory the
following can be done to create the output build directory:

```bash
cmake -S . -B build
```

To build the project once the build directory is created:

```bash
cmake --build build
```

## Launch the executable with qemu

```bash
cmake --build build --target run
```

## References

Taken from: [book](https://umanovskis.se/files/arm-baremetal-ebook.pdf)

