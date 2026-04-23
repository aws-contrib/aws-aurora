# Changelog

## [0.2.1](https://github.com/aws-contrib/aws-aurora/compare/v0.2.0...v0.2.1) (2026-04-23)


### Bug Fixes

* add postCreateCommand to restore nix volume permissions ([f0571e3](https://github.com/aws-contrib/aws-aurora/commit/f0571e3b9a9392197f3718bea67a273083b7e720))
* lower coverage threshold to 70% to match actual coverage ([3c6e186](https://github.com/aws-contrib/aws-aurora/commit/3c6e18629631a0268d49b8f8549a830a33def34d))
* use coverage.out consistent with octocov config ([e8943b6](https://github.com/aws-contrib/aws-aurora/commit/e8943b664e875a2504a6c6f7999d2458170fda8c))

## [0.2.0](https://github.com/aws-contrib/aws-aurora/compare/v0.1.0...v0.2.0) (2026-03-11)


### Features

* **dev:** consolidate dependency management via nix ([4055c0d](https://github.com/aws-contrib/aws-aurora/commit/4055c0d5c860512edf7c6b1e5883178e249e7498))


### Bug Fixes

* **ci:** force-add coverage.svg which is listed in .gitignore ([d3bb718](https://github.com/aws-contrib/aws-aurora/commit/d3bb718b710fef7672ad22fdfb68d599abae15b6))
* **ci:** remove redundant checkout that wiped coverage file before octocov ([36de923](https://github.com/aws-contrib/aws-aurora/commit/36de9238701dab67403bcbc0470d000165fc91d5))
* **docker:** bump builder image to golang:1.25 to match go.mod requirement ([46cdff2](https://github.com/aws-contrib/aws-aurora/commit/46cdff26b30f666ec254f221b5a59111a0dd5109))

## [0.1.0](https://github.com/aws-contrib/aws-aurora/compare/v0.0.1...v0.1.0) (2026-03-07)


### Features

* **cmd:** add wait functionality to migration status command ([c976480](https://github.com/aws-contrib/aws-aurora/commit/c9764804f17b3d367a0afd4bed64b6515327ce0a))
* initial version of Aurora CLI ([a4aebc6](https://github.com/aws-contrib/aws-aurora/commit/a4aebc65f76f6479abddfd93c070b6329082909c))


### Bug Fixes

* correct async index creation syntax in SQL migrations ([7e98d76](https://github.com/aws-contrib/aws-aurora/commit/7e98d761033c4894030c10548e98d4dc727bec19))
