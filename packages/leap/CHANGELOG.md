## 0.7.0

> Note: This release has breaking changes.

 - **FIX**: wasAlive now happens after children update ([#49](https://github.com/kurtome/leap/issues/49)). ([85180b11](https://github.com/kurtome/leap/commit/85180b117b25e6a6844e3e0e1bfefb62d69df12c))
 - **FEAT**: adding prevPosition to physical entity ([#48](https://github.com/kurtome/leap/issues/48)). ([14077a41](https://github.com/kurtome/leap/commit/14077a4105d89ccefc57df243a0a4444d3dce806))
 - **BREAKING** **FIX**: moving some entity logic to updateAfter ([#50](https://github.com/kurtome/leap/issues/50)). ([bd3aa33c](https://github.com/kurtome/leap/commit/bd3aa33cad022d8edce951abb994da82351fd58c))

## 0.6.2

 - **FEAT**: LeapWorld clean-up and other fixes ([#47](https://github.com/kurtome/leap/issues/47)). ([a1a9979f](https://github.com/kurtome/leap/commit/a1a9979fc1026fdf1a724e8eb9f0331ac6c0ce88))

## 0.6.1

 - **FEAT**: adding support for pitched tiles (sloped ceilings) ([#46](https://github.com/kurtome/leap/issues/46)). ([12e90080](https://github.com/kurtome/leap/commit/12e90080af865af5e416c6c6afa52e7644beae80))

## 0.6.0

> Note: This release has breaking changes.

 - **BREAKING** **FIX**: pubspec flutter version must a minimum ([#45](https://github.com/kurtome/leap/issues/45)). ([a5cc357d](https://github.com/kurtome/leap/commit/a5cc357d9c2a6aa9b583e22c66c731bef88ffa61))

## 0.5.4

 - **FEAT**: upgrading flame to 1.18 ([#44](https://github.com/kurtome/leap/issues/44)). ([dd0b81ab](https://github.com/kurtome/leap/commit/dd0b81ab7249d73153810fd20ecc0828ff6434aa))

## 0.5.3

 - misc bug fixes

## 0.5.2+1

 - **FIX**: misc clean-up ([#40](https://github.com/kurtome/leap/issues/40)). ([800529ac](https://github.com/kurtome/leap/commit/800529acee9ad8798a68337c95f6536635fca94b))

## 0.5.2

 - Bump "leap" to `0.5.2`.

## 0.5.1

 - **FEAT**: Adding atlas packing spacing option to TiledOptions ([#31](https://github.com/kurtome/leap/issues/31)). ([8bc04b2c](https://github.com/kurtome/leap/commit/8bc04b2cac209ea5d9d2fad78d411a8f653fa2cb))

## 0.5.0

> Note: This release has breaking changes.

 - **FEAT**: adding character base class ([#35](https://github.com/kurtome/leap/issues/35)). ([802a735a](https://github.com/kurtome/leap/commit/802a735af6d4e274640c8fd9e3ccc695b5e44bd7))
 - **BREAKING** **FEAT**: refactoring collision info (again) and adding character animations ([#36](https://github.com/kurtome/leap/issues/36)). ([0fbefd66](https://github.com/kurtome/leap/commit/0fbefd660916a8ed8ba3e5a9d4a85784383a4a2c))

## 0.4.0

> Note: This release has breaking changes.

 - **FEAT**: allow useAtlas and layerPaintFactory to be configured through TiledOptions ([#27](https://github.com/kurtome/leap/issues/27)). ([02f2be0c](https://github.com/kurtome/leap/commit/02f2be0c9d47cf2ce51ee2109fbe21a42dcd7457))
 - **BREAKING** **FEAT**: ground tiles clean-up and custom handling ([#34](https://github.com/kurtome/leap/issues/34)). ([225b830a](https://github.com/kurtome/leap/commit/225b830a554988bc55ad3f3dcd10fa44139fc0b0))
 - **BREAKING** **FEAT**: Refactoring collision detection for simplified API and improved performance ([#32](https://github.com/kurtome/leap/issues/32)). ([4b767231](https://github.com/kurtome/leap/commit/4b767231e6ce0df68b52757adca08e7519ef01c2))
 - **BREAKING** **FEAT**: StatusComponent system, ladders, and more inputs ([#28](https://github.com/kurtome/leap/issues/28)). ([eafe653f](https://github.com/kurtome/leap/commit/eafe653f60ad123241b810717caff4fdef8ef363))

## 0.3.1

 - **FIX**: walking down slopes not working properly ([#24](https://github.com/kurtome/leap/issues/24)). ([b88b13be](https://github.com/kurtome/leap/commit/b88b13be2d36a07955014e897236b30ebd37f6d9))
 - **FEAT**: adding ability to change map in runtime ([#23](https://github.com/kurtome/leap/issues/23)). ([05c615e0](https://github.com/kurtome/leap/commit/05c615e08943de8ed41c7e6949dc70ddecef4e56))
 - **FEAT**: adding tsx packing filter to TiledOptions ([#26](https://github.com/kurtome/leap/issues/26)). ([3accb89f](https://github.com/kurtome/leap/commit/3accb89f098cf0432211550e2ee80ce967958ffd))

## 0.3.0

> Note: This release has breaking changes.

 - **FEAT**: allow game to specify max atlas sizes ([#20](https://github.com/kurtome/leap/issues/20)). ([fce72722](https://github.com/kurtome/leap/commit/fce72722fc86be38be38b3d735890189f60ec366))
 - **BREAKING** **FEAT**: Adding support for Moving Platorms ([#21](https://github.com/kurtome/leap/issues/21)). ([9583948f](https://github.com/kurtome/leap/commit/9583948f37a15a47231263c927247bb65ceaedd0))

## 0.2.2

## 0.2.1

 - **FIX**: left tap input broken, cannot turn left ([#15](https://github.com/kurtome/leap/issues/15)). ([9eab90b0](https://github.com/kurtome/leap/commit/9eab90b0bba5fb1270863362351b9e529544e2a4))
 - **FEAT**: add Tiled object factories to automatically build Components ([#16](https://github.com/kurtome/leap/issues/16)). ([2d801212](https://github.com/kurtome/leap/commit/2d8012126770263dabc72c016274adcb86e8f050))
 - **FEAT**: allow keyboard keys to be customizable in simple keyboard input  ([#17](https://github.com/kurtome/leap/issues/17)). ([dbd0ae74](https://github.com/kurtome/leap/commit/dbd0ae74c9188ffeb68f41db9a847a6f4476727f))
 - **FEAT**: adding custom classes and types ([#14](https://github.com/kurtome/leap/issues/14)). ([6e1e016e](https://github.com/kurtome/leap/commit/6e1e016e7d56409a1fe0d98351fbe2aa58c957e2))

## 0.2.0

> Note: This release has breaking changes.

 - **FEAT**: allowing bundle and images loading customization ([#12](https://github.com/kurtome/leap/issues/12)). ([f412f38b](https://github.com/kurtome/leap/commit/f412f38b96f96e8c7308657a874183bc5c432275))
 - **BREAKING** **FEAT**: upgrade to flame 1.9.1 ([#7](https://github.com/kurtome/leap/issues/7)). ([7b59cdcd](https://github.com/kurtome/leap/commit/7b59cdcdf0066760132f6c9bf78d4658f08d21a3))

## 0.1.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: updating to flame 1.5 ([#6](https://github.com/kurtome/leap/issues/6)). ([a1c345c8](https://github.com/kurtome/leap/commit/a1c345c89709ebed5adc4eaec722a8a9abcea8c3))

## 0.0.3

 - **FEAT**: uncoupling input implementation ([#5](https://github.com/kurtome/leap/issues/5)). ([bb2fdd26](https://github.com/kurtome/leap/commit/bb2fdd2679de13efa394fe8270ba68f395e350ab))

## 0.0.2

 - **FEAT**: add CollisionDetectionBehavior docs ([#3](https://github.com/kurtome/leap/issues/3)). ([21e0ffd0](https://github.com/kurtome/leap/commit/21e0ffd06ec696e8abbfa9d08ce7ae2b74cf5927))

## 0.0.1+1

 - **DOCS**: bootstrapping the docs for initial release ([#1](https://github.com/kurtome/leap/issues/1)). ([7ecdedc9](https://github.com/kurtome/leap/commit/7ecdedc92b1f3401af1c1c67993d47d45049551b))

## 0.0.1

* TODO: Describe initial release.
