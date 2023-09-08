APIGen for PyFX Dispatch
========================

## Development Dependencies

- GNU Make
- Python 3

For the project Makefile, the `PYTHON` Makefile variable should be set
to the relative or absolute pathname of the Python interpreter, if not
available as `python3` e.g.

```sh
make env PYTHON=python
```

For the API Generator, the following dependencies should also be
installed

- JRE or JDK for Java 11 or newer
- Maven 3
- jq

On Microsoft Windows platforms, the development dependencies can be
installed with [Chocolatey][choco], using the PowerShell command
line or with the optional [Chocolatey GUI][choco-gui].

OpenJDK releases are available in the Chocolatey Community package
repository, such as provided by the [Eclipse Temurin][temurin]
project, e.g [Temurin17][temurin17]

### Post-Installation

The system `PATH` environment variable should be configured, such as
to ensure that each of these dependencies can be accessed with a
relative pathname from within the API Generator scripting.

For example, if using a BASH shell installed from MSYS2, with
dependencies of some specific version installed via
[Chocolatey][choco]:

```sh
PATH=${JAVA_HOME}/bin:/c/ProgramData/chocolatey/bin:/c/Python311:/c/ProgramData/chocolatey/lib/maven/apache-maven-3.9.4/bin:${PATH}
```

`JAVA_HOME` should also be set for the JRE or JDK installation.


[choco]: https://community.chocolatey.org/
[choco-gui]: https://community.chocolatey.org/packages/ChocolateyGUI
[temurin]: https://projects.eclipse.org/projects/adoptium.temurin
[temurin17]: https://community.chocolatey.org/packages/Temurin17
