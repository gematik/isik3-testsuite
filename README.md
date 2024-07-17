<img align="right" width="250" height="47" src="imgs/gematik_logo.png"/> <br/> 

# ISiK Stufe 3 Test Suite

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
       <ul>
        <li><a href="#release-notes">Release Notes</a></li>
      </ul>
	</li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

## About The Project
This is a test suite for conformance tests of the ISiK Stufe 3 specification modules:

- [Basis](https://simplifier.net/guide/isik-basis-v3?version=current)
- [Medikation](https://simplifier.net/guide/isik-medikation-v3?version=current)
- [Terminplanung](https://simplifier.net/guide/isik-terminplanung-v3?version=current)
- [Dokumentenaustausch](https://simplifier.net/guide/isik-dokumentenaustausch-v3?version=current)
- [Vitalparameter und Körpermaße](https://simplifier.net/guide/isik-vitalparamater-v3?version=current)

> **Warning**
> The test suite consists of the same test cases as the [Titus platform](https://fachportal.gematik.de/toolkit/titus-ps-testmodule) but is currently under evaluation. You can not pass the [conformity assessment](https://fachportal.gematik.de/gematik-onlineshop/bestaetigungsverfahren-isik-isip) with this test suite yet. Please follow the instruction on the above page to get access to the Titus platform. 

### Release Notes
See [ReleaseNotes.md](./ReleaseNotes.md) for all information regarding the (newest) releases.

## Getting Started

### Prerequisites

To run the test suite you need the following components:

1. This test suite, which you can get either by cloning this repository or downloading the latest release.
2. An ISiK resource server (System under Test, SUT) that is compliant with one of the ISiK Stufe 3 specification modules.

Operating system requirements: cf. [Tiger Framework OS requirements](https://gematik.github.io/app-Tiger/Tiger-User-Manual.html#_requirements)

### Installation

#### Test environment
Configure the endpoint of the SUT using the configuration element `servers.fhirserver.source` in the `tiger.yaml` configuration file. Example:

```yaml
servers:
  fhirserver:
    type: externalUrl
    source:
      - http://localhost:9032
```

#### Test resources

Each test case requires specific test resources to be present in the SUT. Create the following test resources in the SUT and put their corresponding IDs into the `testdata/MODULENAME.yaml` configuration file. 

Example:

The `@Patient-Read` test case requires a patient resource to be created in the SUT by the user before the test case can be run. As the SUT would usually assign a new unique ID to each created resource, e.g. `244b0d72-fe47-4294-be48-7763895287c5`, this newly assigned ID should be put into the `testdata/basis.yaml` configuration file. The precondition of the test case declares which configuration variable should be used - `patient-read-id` in this example:  

```yaml
...
patient-read-id: Patient-Read-Example
...
```

## Usage

### Starting all test cases from one or multiple modules

To start all test cases from a module, run `mvn verify -P MODULENAME`, e.g. `mvn verify -P basis`. To start only mandatory or optional test cases, use the corresponding profiles `mandatory` or `optional`.

Examples:

```shell
`mvn -P basis,mandatory`
`mvn -P basis,optional`
```

Available module names:
- `basis`
- `dokumentenaustausch`
- `medikation`
- `terminplanung`
- `vitalparameter`

Test cases of several modules can be executed in one run by providing a comma-separated list of module names, e.g. `mvn verify -P basis,medikation`.

### Starting single test cases

To start one or several particular test cases run `mvn verify -Dcucumber.filter.tags="@TEST_NAME1 or @TEST_NAME2"`, e.g. `mvn verify -Dcucumber.filter.tags="@Patient-Read or @Patient-Search"`. To start the complete test suite run `mvn verify`.

### Inspecting test results

Right after starting a test suite a browser window will open, which provides an overview of the testing progress. See [Tiger Workflow UI](https://gematik.github.io/app-Tiger/Tiger-User-Manual.html#_tiger_user_interfaces) for further information about the user interface. To run the test suite without the GUI, e.g. within a CI/CD pipeline, set the configuration element `lib.activateWorkflowUi` to `false` in the `tiger.yaml` configuration file.

The test suite produces a report, which can be found in `target/site/serenity/index.html` or as a compressed artifact in `target/tiger-integration-isik-stufe-3-VERSION-SNAPSHOT-report.zip`. 

> **Warning**
> Please always attach the ZIP test report to the issue in the [Anfrageportal ISiK](#contact) when reporting a bug.
 

> **Warning** 
> The `mvn` command deletes the `target` folder. Backup the created reports if you need them in the future.

### Proxy settings

To access an endpoint behind a proxy, you can set the proxy settings in the Maven command line. 

Example:

```shell
mvn -Dhttps.proxyHost=....... -Dhttps.proxyPort=..... -P basis
```

## Contributing
If you want to contribute, please check our [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

Copyright 2024 gematik GmbH

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.

Unless required by applicable law the software is provided "as is" without warranty of any kind, either express or implied, including, but not limited to, the warranties of fitness for a particular purpose, merchantability, and/or non-infringement. The authors or copyright holders shall not be liable in any manner whatsoever for any damages or other claims arising from, out of or in connection with the software or the use or other dealings with the software, whether in an action of contract, tort, or otherwise.

The software is the result of research and development activities, therefore not necessarily quality assured and without the character of a liable product. For this reason, gematik does not provide any support or other user assistance (unless otherwise stated in individual cases and without justification of a legal obligation). Furthermore, there is no claim to further development and adaptation of the results to a more current state of the art.

Gematik may remove published results temporarily or permanently from the place of publication at any time without prior notice or justification.

## Contact

Please open a GitHub issue or a ticket within [Anfrageportal ISiK](https://service.gematik.de/servicedesk/customer/portal/16) for any questions or feedback.
