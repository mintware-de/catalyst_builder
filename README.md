![GitHub issues](https://img.shields.io/github/issues/mintware-de/catalyst_builder)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/mintware-de/catalyst_builder/dart.yml?branch=main)

# Catalyst Builder

A dependency injection provider builder for dart.

This is the workspace root, select a specific package for more details.

| Package                                                               | Description                                                                                                                           | Badges                                                                                                                                                                                                                                                                                                                                                                                         |
|-----------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`catalyst_builder`](./packages/catalyst_builder)                     | The builder package. Use this in your root package or plugin package to generate the ServiceContainerPlugin.                          | [![Pub](https://img.shields.io/pub/v/catalyst_builder.svg)](https://pub.dartlang.org/packages/catalyst_builder)<br> ![Pub Points](https://img.shields.io/pub/points/catalyst_builder)<br> ![Pub Likes](https://img.shields.io/pub/likes/catalyst_builder)<br> ![Pub Monthly Downloads](https://img.shields.io/pub/dm/catalyst_builder)                                                         |
| [`catalyst_builder_contracts`](./packages/catalyst_builder_contracts) | The contracts package. Use this in packages that don't need to generate a service provider but provide services that can be resolved. | [![Pub](https://img.shields.io/pub/v/catalyst_builder_contracts.svg)](https://pub.dartlang.org/packages/catalyst_builder_contracts)  <br> ![Pub Points](https://img.shields.io/pub/points/catalyst_builder_contracts)  <br> ![Pub Likes](https://img.shields.io/pub/likes/catalyst_builder_contracts) <br>  ![Pub Monthly Downloads](https://img.shields.io/pub/dm/catalyst_builder_contracts) |

## Roadmap

# v5 (Current)

| Description                                                               | Status |
|---------------------------------------------------------------------------|--------|
| Remove the annotations inside the catalyst_builder_package                | ☑️     |
| Remove the service provider subclasses                                    | ☑️     |
| Stop generating the ServiceProvider and create a default ServiceContainer | ☑️     |
| Add scope support                                                         | 🔲     |
