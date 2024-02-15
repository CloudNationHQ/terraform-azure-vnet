# Changelog

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
