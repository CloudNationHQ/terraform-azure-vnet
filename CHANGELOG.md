# Changelog

## [9.1.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v9.0.0...v9.1.0) (2025-05-27)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#147](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/147)) ([3617092](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/36170923ee91c07d0e2555fcb4118a217a8c32c6))

## [9.0.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v8.5.0...v9.0.0) (2025-05-27)


### ⚠ BREAKING CHANGES

* The data structure changed, causing a recreate on existing resources.

### Features

* small refactor ([#148](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/148)) ([f41cfee](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/f41cfee39502a094f2d598979555a9b482c8e5f7))
* type definitions are added
* documentation is updated
* some logic is simplified regarding existing virtual network

### Upgrade from v8.5.0 to v9.0.0:

- Update module reference to: `version = "~> 9.0"`
- The property and variable resource_group is renamed to resource_group_name
- The fallback peering names are changed in the submodule peering

## [8.5.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v8.4.1...v8.5.0) (2025-03-13)


### Features

* add support for use remote gateways in peering and removed the random provider ([#141](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/141)) ([23a2121](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/23a21217ae4266ddb6b944c2247bb87b8c4cb0db))
* **deps:** bump golang.org/x/net from 0.33.0 to 0.36.0 in /tests ([#140](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/140)) ([55a832f](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/55a832ff765f45ab175efbb9883f089a6e57a1d6))

## [8.4.1](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v8.4.0...v8.4.1) (2025-01-30)


### Bug Fixes

* vnet peering name override ([#132](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/132)) ([db01bd6](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/db01bd61a1bc3bcb3ff7ea1bb7cf7adb2b726b05))

## [8.4.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v8.3.0...v8.4.0) (2025-01-15)


### Features

* added private endpoint vnet policies support and remove temporary files when deployment tests fails ([#129](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/129)) ([2311a32](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/2311a32d8f36d8cb1401a8d4e2a83a3e3bfa432f))

## [8.3.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v8.2.0...v8.3.0) (2025-01-09)


### Features

* add ddos plan support and added the ability to use application security groups ids in rules ([#126](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/126)) ([629aed8](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/629aed8f6cafc9eb7c48c0c67ebebbca63f17fa3))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#125](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/125)) ([a2db640](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/a2db64028b7c0cd8f8cd2f72ae0f2eba02f11c8e))
* **deps:** bump golang.org/x/net from 0.31.0 to 0.33.0 in /tests ([#128](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/128)) ([a857df3](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/a857df3a8f88bfafd66c0e9888f996c1d58de14e))

## [8.2.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v8.1.2...v8.2.0) (2024-12-17)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#122](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/122)) ([0d242eb](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/0d242eb0d59d3b72dfaca6a5d5c247237d1a46cd))
* **deps:** bump golang.org/x/crypto from 0.21.0 to 0.31.0 in /tests ([#120](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/120)) ([0a776fe](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/0a776fefdae2445d320f0488ba366dd46ad21492))


### Bug Fixes

* unsupported attribute on location and resourcegroup ([#123](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/123)) ([45116dc](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/45116dc824a353e46e836b276b08e3ca1c052b2e))

## [8.1.2](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v8.1.1...v8.1.2) (2024-12-06)


### Bug Fixes

* resolve type mismatches in network security groups ([#118](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/118)) ([5b43ed1](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/5b43ed15932e428913b1f935cf1bf6b840807cb5))

## [8.1.1](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v8.1.0...v8.1.1) (2024-11-29)


### Bug Fixes

* resolved race condition in network security group association ([#116](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/116)) ([9dac66f](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/9dac66f30866097f932590b640beb3ccae806f79))

## [8.1.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v8.0.3...v8.1.0) (2024-11-25)


### Features

* ignore inline rules in network security groups and take current subscription as alias in peering usage ([#114](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/114)) ([3a4b634](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/3a4b6345190a0a15cfe5ea87c102cb16d4bfedd6))

## [8.0.3](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v8.0.2...v8.0.3) (2024-11-20)


### Bug Fixes

* fix inconsistent conditional result types in route tables ([#112](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/112)) ([768701f](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/768701fe4a6eff3494624662bdd12c6ebaa0d890))

## [8.0.2](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v8.0.1...v8.0.2) (2024-11-13)


### Bug Fixes

* remove time provider ([#109](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/109)) ([2c87fcd](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/2c87fcd4e837ce3c09d6e0fd0d8e6c0e4fce6013))

## [8.0.1](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v8.0.0...v8.0.1) (2024-11-13)


### Bug Fixes

* revert several symbolic names and fixed the documentation generation of submodules ([#106](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/106)) ([e77c10e](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/e77c10e65bfeed416cc1f15f3574b79984fa6f0e))

## [8.0.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v7.1.0...v8.0.0) (2024-11-13)


### ⚠ BREAKING CHANGES

* remove submodule vhub-connection, added submodule vnet-peering, updated cidr properties to address_space (vnet) and address_prefixes (subnet) ([#104](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/104))

### Features

* remove submodule vhub-connection, added submodule vnet-peering, updated cidr properties to address_space (vnet) and address_prefixes (subnet) ([#104](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/104)) ([2e843e0](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/2e843e0846b004d3f1cbfce1beefd21b73d3bad0))

## [7.1.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v7.0.2...v7.1.0) (2024-11-11)


### Features

* enhance testing with sequential, parallel modes and flags for exceptions and skip-destroy ([#102](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/102)) ([29c7b52](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/29c7b5241414b82962585a907c500c8fc689b3c3))

## [7.0.2](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v7.0.1...v7.0.2) (2024-10-31)


### Bug Fixes

* resolve type mismatch in nsg name coalesce ([#100](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/100)) ([808a2ce](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/808a2cefe972e467d815dd71c6b2e0a2e72a3c41))

## [7.0.1](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v7.0.0...v7.0.1) (2024-10-28)


### Bug Fixes

* remove parallelism limitation from tests ([#98](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/98)) ([c969d29](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/c969d29baeab7c90c7a294c7fbc5870a1d4bc072))

## [7.0.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v6.1.0...v7.0.0) (2024-10-25)


### ⚠ BREAKING CHANGES

* corrected vnet output and made several improvements ([#96](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/96))

### Features

* corrected vnet output and made several improvements ([#96](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/96)) ([a369dfc](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/a369dfce51a730f7d33cdc9a3ba841131d181d10))

### Upgrade from v6.1.0 to v7.0.0:

- Update module reference to: `version = "~> 7.0"`
- Several keys are changed in the data structure :
  - vnet name is removed as key in the vnet resource and data source
  - several keys are changed in subresources
  - made improvements in individual and shared network security groups
  - made improvements in individual and shared route tables

## [6.1.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v6.0.0...v6.1.0) (2024-10-11)


### Features

* auto generated docs and refine makefile ([#94](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/94)) ([151ed89](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/151ed89560f69a74527a6f814f653d6de874b139))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#88](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/88)) ([89aeb8a](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/89aeb8ab7e2c9894c6f20848fecf24e0198e9f7f))

## [6.0.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v5.0.1...v6.0.0) (2024-10-10)


### ⚠ BREAKING CHANGES

* data structure has changed due to renaming of properties.

### Features

* aligned route table properties ([#92](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/92)) ([5a61ce4](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/5a61ce4b244b32dfc06474a192be38a36f487d3b))

### Upgrade from v5.0.1 to v6.0.0:

- Update module reference to: `version = "~> 6.0"`
- Rename properties in vnet object:
  - within subnets the shared route_table property has been renamed to route_table_shared
  - within subnets the individual route property has been renamed to route_table

## [5.0.1](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v5.0.0...v5.0.1) (2024-10-10)


### Bug Fixes

* fix vnet dependency order for proper destruction ([#90](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/90)) ([e07d0df](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/e07d0df24e573ec6971bc5d1aeefa54c1973aab6))

## [5.0.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v4.0.1...v5.0.0) (2024-10-02)


### ⚠ BREAKING CHANGES

* Make use of an already existing vnet ([#86](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/86))

### Features

* Make use of an already existing vnet ([#86](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/86)) ([3e001ff](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/3e001ff44081accbbde466842cbe9239d1c991c4))

## [4.0.1](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v4.0.0...v4.0.1) (2024-09-26)


### Bug Fixes

* fix defaults private endpoint network policies ([#84](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/84)) ([f0258d5](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/f0258d57cd58c726b98829c4f5b5ddd61cd94536))

## [4.0.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v3.1.0...v4.0.0) (2024-09-24)


### ⚠ BREAKING CHANGES

* Version 4 of the azurerm provider includes breaking changes.

### Features

* upgrade azurerm provider to v4 ([#82](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/82)) ([88dfbce](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/88dfbcebedb6c0812ae66bda15e172c156b76c13))

### Upgrade from v3.1.0 to v4.0.0:

- Update module reference to: `version = "~> 4.0"`
- Rename properties in vnet object:
  - disable_bgp_route_propagation -> bgp_route_propagation_enabled

## [3.1.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v3.0.0...v3.1.0) (2024-09-24)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#80](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/80)) ([fc58d91](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/fc58d9154ca249ef8ff04d94020f396763b956ec))

## [3.0.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v2.9.0...v3.0.0) (2024-08-15)


### ⚠ BREAKING CHANGES

* data structure has changed due to renaming of properties and output variables.

### Features

* aligned several properties ([#78](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/78)) ([d28b39a](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/d28b39aa54fed5d2c8a8ffddda4eeeeb3e8bdc53))

### Upgrade from v2.9.0 to v3.0.0:

- Update module reference to: `version = "~> 3.0"`
- Rename properties in vnet object:
  - resourcegroup -> resource_group
  - private_endpoint_network_policies_enabled -> private_endpoint_network_policies
- Rename variable (optional):
  - resourcegroup -> resource_group
- Rename output variable:
  - subscriptionId -> subscription_id'
  - nsg -> network_security_group

## [2.9.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v2.8.0...v2.9.0) (2024-08-15)


### Features

* added code of conduct and security documentation ([#76](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/76)) ([185f44f](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/185f44fb3b43fc8ce6b1d19314bebfd9ef3f3c30))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#73](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/73)) ([41649a8](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/41649a8b73a4fe3127f164d8e5df252e996e6f54))

## [2.8.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v2.7.0...v2.8.0) (2024-08-02)


### Features

* add network security group output ([#74](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/74)) ([0bfa16f](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/0bfa16f172eb2d743eb5ba8ad064d46c591e7b9a))
* update contribution docs ([#71](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/71)) ([9150a00](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/9150a00dc030149cf3e695b67b1b2660bc116500))

## [2.7.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v2.6.0...v2.7.0) (2024-07-03)


### Features

* update terraform random module version to 3.6 ([#69](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/69)) ([88694d6](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/88694d68184a31af4f6e99506a34ea850dba5eb8))

## [2.6.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v2.5.0...v2.6.0) (2024-07-02)


### Features

* add issue template ([#66](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/66)) ([2c09fb2](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/2c09fb20e919440c2c418d56c0f2a12939f7bcac))
* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/azidentity ([#62](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/62)) ([d35737a](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/d35737ab65400e16780e0a19935892593c081bf7))
* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/azidentity ([#63](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/63)) ([6cad8df](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/6cad8dfea64266d7b305c108dfdec87d4c9f145b))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#65](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/65)) ([c5d10b5](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/c5d10b5c378ae1d954ab6e6813b5187b159df485))
* **deps:** bump github.com/hashicorp/go-getter in /tests ([#64](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/64)) ([1282b52](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/1282b52890aed97a028addbbe92d62ab6e7d5fdb))

## [2.5.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v2.4.1...v2.5.0) (2024-06-07)


### Features

* create pull request template ([#60](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/60)) ([ccd2146](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/ccd214627cc73f5ad153826c9dc9f01f55a28c2b))
* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/azidentity ([#55](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/55)) ([028b357](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/028b357b88125370388e379b7a4796ad2472d377))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#59](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/59)) ([c0b1a88](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/c0b1a881c526287a7dcb96405f62cf7e441ad3eb))
* **deps:** bump github.com/hashicorp/go-getter in /tests ([#57](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/57)) ([929717b](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/929717b1c9750c752ef4e6cdad5de41403048b6e))
* **deps:** bump golang.org/x/net from 0.19.0 to 0.23.0 in /tests ([#56](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/56)) ([9bd9abc](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/9bd9abc4981b21a1d7faa532d5226f0e565ad88f))
* **deps:** bump google.golang.org/protobuf in /tests ([#53](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/53)) ([da2a415](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/da2a415ad6a1d46983f6eda25c067b7ecd6835be))

## [2.4.1](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v2.4.0...v2.4.1) (2024-03-12)


### Bug Fixes

* refactor delegation key to actual key provided instead of a numbered index ([#51](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/51)) ([fe45101](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/fe4510161eb931f6779af11ecc3f1216005d4dbe))

## [2.4.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v2.3.0...v2.4.0) (2024-03-06)


### Features

* **deps:** bump github.com/stretchr/testify in /tests ([#48](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/48)) ([47e674a](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/47e674acbe60c97bfda45c03c33a1a8656aef532))
* update documentation ([#49](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/49)) ([6398a09](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/6398a099a54016f83a36f03cb6e90fd2979f8a5d))

## [2.3.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v2.2.1...v2.3.0) (2024-02-27)


### Features

* add conditional expressions to allow some global properties ([#46](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/46)) ([7e9143d](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/7e9143d761a4d06b21b484334badb3b65b24036f))

## [2.2.1](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v2.2.0...v2.2.1) (2024-02-24)


### Bug Fixes

* fix refined subnet routing to ensure correct creation and association ([#44](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/44)) ([43762f7](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/43762f76344d00976c8f180d50ddf9efa27ca0b3))

## [2.2.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v2.1.0...v2.2.0) (2024-02-21)


### Features

* add support to disable bgp route propagation ([#39](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/39)) ([6b349f7](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/6b349f70ff25189d96f215eba577ea8d009ab135))

## [2.1.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v2.0.0...v2.1.0) (2024-02-16)


### Features

* better allignment property names ([#36](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/36)) ([7c6966b](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/7c6966bafa4f282bfa43945131d079e600282536))

## [2.0.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v1.3.0...v2.0.0) (2024-02-15)


### ⚠ BREAKING CHANGES

* network security groups can be optional now and small refactor data structure ([#34](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/34))

### Features

* network security groups can be optional now and small refactor data structure ([#34](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/34)) ([2d563de](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/2d563de72cce76b519bd4626d5ac8d1f1e3a8861))

## [1.3.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v1.2.0...v1.3.0) (2024-02-14)


### Features

* naming variable is optional now ([#32](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/32)) ([5793043](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/57930433fc901d89bb14325ab06e58ad9b15f844))

## [1.2.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v1.1.1...v1.2.0) (2024-02-02)


### Features

* added a small delay in cases the subnets are not fully initialized in some azure regions before attaching network security groups ([#28](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/28)) ([8eafea5](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/8eafea5a8540ccc7a8b45ff78c35d9a35a20a9fc))
* **deps:** bump github.com/Azure/azure-sdk-for-go/sdk/azidentity ([#22](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/22)) ([e4b9220](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/e4b92206b241a10523b0d58cccd1b8bebc52e09d))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#18](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/18)) ([e63f9a6](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/e63f9a6b83df1ec77d14ec725b79f7fc0165a9a5))
* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#23](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/23)) ([ed4f936](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/ed4f9360f37fb30d199671f94d9455893215359d))
* small refactor workflows ([#19](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/19)) ([ad7e879](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/ad7e879dff55f9c4c208cbd703fdd93ab7b326de))

## [1.1.1](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v1.1.0...v1.1.1) (2023-12-20)


### Bug Fixes

* make subnet delegation actions fully optional ([#15](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/15)) ([d25d1c6](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/d25d1c698b32385556f9b7105b2e52366de1c68a))

## [1.1.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v1.0.0...v1.1.0) (2023-12-19)


### Features

* update documentation ([#13](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/13)) ([931dc57](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/931dc57b1d860a0e877342fb9fd2190ffea861b4))

## [1.0.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v0.3.0...v1.0.0) (2023-12-19)


### ⚠ BREAKING CHANGES

* This changes the data structure of nsg rules from a list to a map.

### Bug Fixes

* refactor nsg rules, resolves [#9](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/9) ([#11](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/11)) ([1cf016e](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/1cf016e6636d3043ba03c033114003b27126c6af))

## [0.3.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v0.2.0...v0.3.0) (2023-12-19)


### Features

* **deps:** bump github.com/gruntwork-io/terratest in /tests ([#5](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/5)) ([2c7eb23](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/2c7eb23b5b5be58809e99c21aeb41adf584d5a4d))
* **deps:** bump golang.org/x/crypto from 0.14.0 to 0.17.0 in /tests ([#10](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/10)) ([fc83598](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/fc83598a9d1e2a95bada295f0bb762f08458fcad))
* **deps:** Bumps terratest from 0.46.7 to 0.46.8 ([#8](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/8)) ([69f2f11](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/69f2f11654fd12de6e98b8fbb66cd79ce36fe37f))

## [0.2.0](https://github.com/CloudNationHQ/terraform-azure-vnet/compare/v0.1.0...v0.2.0) (2023-11-03)


### Features

* fix module source references in examples ([#3](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/3)) ([6925010](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/69250108860a71052e6623188e19334498140ea2))

## 0.1.0 (2023-11-02)


### Features

* add initial resources ([#1](https://github.com/CloudNationHQ/terraform-azure-vnet/issues/1)) ([f3b3235](https://github.com/CloudNationHQ/terraform-azure-vnet/commit/f3b3235352be8a9bf7675aa4aed78ebb2f726e04))
