# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2024-11-24

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.8.3`](#leap---v083)

---

#### `leap` - `v0.8.3`

 - **FIX**: slope collision detection is inconsistent ([#73](https://github.com/kurtome/leap/issues/73)). ([ced80749](https://github.com/kurtome/leap/commit/ced8074922b30e19409ee4840391fa135d8f0514))
 - **FIX**: walk speed mixin should be on entity ([#72](https://github.com/kurtome/leap/issues/72)). ([4bdf6188](https://github.com/kurtome/leap/commit/4bdf61887c0bc13100429c8087333301834d346c))
 - **FIX**: direction enums should be shared accross domains ([#71](https://github.com/kurtome/leap/issues/71)). ([2de6bb98](https://github.com/kurtome/leap/commit/2de6bb982a3a086f62b0dc6c869fc7bcdf254a47))
 - **FIX**: entities could phase through collisions ([#70](https://github.com/kurtome/leap/issues/70)). ([64b25bff](https://github.com/kurtome/leap/commit/64b25bfff6e9c4de5ecde87bc48b7f2e63ee0d61))
 - **FIX**: AnchoredAnimationGroup positioning breaks when children change s… ([#68](https://github.com/kurtome/leap/issues/68)). ([514d3138](https://github.com/kurtome/leap/commit/514d3138626b50ffead88b72d7dc563dce79f82c))
 - **FEAT**: adding ignoreTags property to PhysicalEntity ([#77](https://github.com/kurtome/leap/issues/77)). ([0d98a004](https://github.com/kurtome/leap/commit/0d98a00401744895ac1d9f6ad665969350679053))
 - **FEAT**: remove static property from entities ([#76](https://github.com/kurtome/leap/issues/76)). ([3df41be8](https://github.com/kurtome/leap/commit/3df41be89ffad20df5e11ae085fc05fc094e443e))
 - **FEAT**: adding extensions methods for direction enums ([#75](https://github.com/kurtome/leap/issues/75)). ([ebfa2775](https://github.com/kurtome/leap/commit/ebfa27754e18d9b118423290c14cfb33c79f00fc))
 - **FEAT**: removing faceLeft in favor of direction enums ([#74](https://github.com/kurtome/leap/issues/74)). ([cce48df4](https://github.com/kurtome/leap/commit/cce48df4d51aa8e9177f02cec5be0ea54af0839b))
 - **FEAT**: adding behavior support to AnchoredAnimationGroup ([#69](https://github.com/kurtome/leap/issues/69)). ([35345853](https://github.com/kurtome/leap/commit/35345853a34050e9b39f16beff03606069071449))


## 2024-09-02

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.8.2`](#leap---v082)

---

#### `leap` - `v0.8.2`

 - **FEAT**: entities can override the global max gravity Y velocity ([#67](https://github.com/kurtome/leap/issues/67)). ([418b9df3](https://github.com/kurtome/leap/commit/418b9df3629fc451f4731fad440e4efae25db369))
 - **FEAT**: adding spriteOffset to AnchoredAnimationGroup ([#66](https://github.com/kurtome/leap/issues/66)). ([e9770d80](https://github.com/kurtome/leap/commit/e9770d8016ae37873048a09668f69f8d24a7c8dd))


## 2024-09-01

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.8.1+1`](#leap---v0811)

---

#### `leap` - `v0.8.1+1`

 - **REFACTOR**: update dependencies ([#65](https://github.com/kurtome/leap/issues/65)). ([ff42a6d4](https://github.com/kurtome/leap/commit/ff42a6d434dfe4161229a1dfa1b222c9d55ef70a))


## 2024-09-01

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.8.1`](#leap---v081)

---

#### `leap` - `v0.8.1`

 - **FIX**: non-solid collisions no not account for velocity properly ([#64](https://github.com/kurtome/leap/issues/64)). ([c33024e5](https://github.com/kurtome/leap/commit/c33024e5ca2638710d632ea859712f7090a88c22))
 - **FEAT**: adding IgnoresCollisionTags status ([#63](https://github.com/kurtome/leap/issues/63)). ([de882d63](https://github.com/kurtome/leap/commit/de882d63d5fc95f7639ea94f5abcd5123f1ce954))
 - **FEAT**: improving StatusComponent including rename to EntityStatus ([#62](https://github.com/kurtome/leap/issues/62)). ([4a53ceaa](https://github.com/kurtome/leap/commit/4a53ceaa774b4c098e2dbe8ac6ed89f8488ae548))


## 2024-08-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.8.0+1`](#leap---v0801)

---

#### `leap` - `v0.8.0+1`

 - **FIX**: fixing prevPosition updating ([#55](https://github.com/kurtome/leap/issues/55)). ([64170f29](https://github.com/kurtome/leap/commit/64170f29324b92304dbc5208d5f55b048c39f8dc))
 - **DOCS**(readme): update player implementation ([#56](https://github.com/kurtome/leap/issues/56)). ([869fbd7c](https://github.com/kurtome/leap/commit/869fbd7c3c3ecd5c3ae6e959c1eac7cf7d09978a))


## 2024-08-24

### Changes

---

Packages with breaking changes:

 - [`leap` - `v0.8.0`](#leap---v080)

Packages with other changes:

 - There are no other changes in this release.

---

#### `leap` - `v0.8.0`

 - **FIX**: world loading order bug ([#53](https://github.com/kurtome/leap/issues/53)). ([2711d39d](https://github.com/kurtome/leap/commit/2711d39d0a071de72449a89923cdda8ec3676656))
 - **FEAT**: adding more options to has_animation_group ([#54](https://github.com/kurtome/leap/issues/54)). ([6be5eba4](https://github.com/kurtome/leap/commit/6be5eba4e76a7d1f1f58aacbb2b27d2c69e4c0a6))
 - **FEAT**: adding constructor params to PhysicalBehavior ([#51](https://github.com/kurtome/leap/issues/51)). ([87157005](https://github.com/kurtome/leap/commit/87157005003123a9aaead5b87fbeb4fc082f8bfc))
 - **BREAKING** **FEAT**: Refactor everything to use behaviors, and simplify base classes ([#52](https://github.com/kurtome/leap/issues/52)). ([b5eef12d](https://github.com/kurtome/leap/commit/b5eef12d17c9a483ee955707af3f8d710a0f694f))


## 2024-08-11

### Changes

---

Packages with breaking changes:

 - [`leap` - `v0.7.0`](#leap---v070)

Packages with other changes:

 - There are no other changes in this release.

---

#### `leap` - `v0.7.0`

 - **FIX**: wasAlive now happens after children update ([#49](https://github.com/kurtome/leap/issues/49)). ([85180b11](https://github.com/kurtome/leap/commit/85180b117b25e6a6844e3e0e1bfefb62d69df12c))
 - **FEAT**: adding prevPosition to physical entity ([#48](https://github.com/kurtome/leap/issues/48)). ([14077a41](https://github.com/kurtome/leap/commit/14077a4105d89ccefc57df243a0a4444d3dce806))
 - **BREAKING** **FIX**: moving some entity logic to updateAfter ([#50](https://github.com/kurtome/leap/issues/50)). ([bd3aa33c](https://github.com/kurtome/leap/commit/bd3aa33cad022d8edce951abb994da82351fd58c))


## 2024-08-10

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.6.2`](#leap---v062)

---

#### `leap` - `v0.6.2`

 - **FEAT**: LeapWorld clean-up and other fixes ([#47](https://github.com/kurtome/leap/issues/47)). ([a1a9979f](https://github.com/kurtome/leap/commit/a1a9979fc1026fdf1a724e8eb9f0331ac6c0ce88))


## 2024-07-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.6.1`](#leap---v061)

---

#### `leap` - `v0.6.1`

 - **FEAT**: adding support for pitched tiles (sloped ceilings) ([#46](https://github.com/kurtome/leap/issues/46)). ([12e90080](https://github.com/kurtome/leap/commit/12e90080af865af5e416c6c6afa52e7644beae80))


## 2024-07-17

### Changes

---

Packages with breaking changes:

 - [`leap` - `v0.6.0`](#leap---v060)

Packages with other changes:

 - There are no other changes in this release.

---

#### `leap` - `v0.6.0`

 - **BREAKING** **FIX**: pubspec flutter version must a minimum ([#45](https://github.com/kurtome/leap/issues/45)). ([a5cc357d](https://github.com/kurtome/leap/commit/a5cc357d9c2a6aa9b583e22c66c731bef88ffa61))


## 2024-07-16

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.5.4`](#leap---v054)

---

#### `leap` - `v0.5.4`

 - **FEAT**: upgrading flame to 1.18 ([#44](https://github.com/kurtome/leap/issues/44)). ([dd0b81ab](https://github.com/kurtome/leap/commit/dd0b81ab7249d73153810fd20ecc0828ff6434aa))


## 2023-12-25

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.5.3`](#leap---v053)

---

#### `leap` - `v0.5.3`

 - misc bug fixes


## 2023-12-25

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.5.2+1`](#leap---v0521)

---

#### `leap` - `v0.5.2+1`

 - **FIX**: misc clean-up ([#40](https://github.com/kurtome/leap/issues/40)). ([800529ac](https://github.com/kurtome/leap/commit/800529acee9ad8798a68337c95f6536635fca94b))


## 2023-12-05

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.5.2`](#leap---v052)

---

#### `leap` - `v0.5.2`

 - Bump "leap" to `0.5.2`.


## 2023-12-05

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.5.1`](#leap---v051)

---

#### `leap` - `v0.5.1`

 - **FEAT**: Adding atlas packing spacing option to TiledOptions ([#31](https://github.com/kurtome/leap/issues/31)). ([8bc04b2c](https://github.com/kurtome/leap/commit/8bc04b2cac209ea5d9d2fad78d411a8f653fa2cb))


## 2023-12-04

### Changes

---

Packages with breaking changes:

 - [`leap` - `v0.5.0`](#leap---v050)

Packages with other changes:

 - There are no other changes in this release.

---

#### `leap` - `v0.5.0`

 - **FEAT**: adding character base class ([#35](https://github.com/kurtome/leap/issues/35)). ([802a735a](https://github.com/kurtome/leap/commit/802a735af6d4e274640c8fd9e3ccc695b5e44bd7))
 - **BREAKING** **FEAT**: refactoring collision info (again) and adding character animations ([#36](https://github.com/kurtome/leap/issues/36)). ([0fbefd66](https://github.com/kurtome/leap/commit/0fbefd660916a8ed8ba3e5a9d4a85784383a4a2c))


## 2023-11-27

### Changes

---

Packages with breaking changes:

 - [`leap` - `v0.4.0`](#leap---v040)

Packages with other changes:

 - There are no other changes in this release.

---

#### `leap` - `v0.4.0`

 - **FEAT**: allow useAtlas and layerPaintFactory to be configured through TiledOptions ([#27](https://github.com/kurtome/leap/issues/27)). ([02f2be0c](https://github.com/kurtome/leap/commit/02f2be0c9d47cf2ce51ee2109fbe21a42dcd7457))
 - **BREAKING** **FEAT**: ground tiles clean-up and custom handling ([#34](https://github.com/kurtome/leap/issues/34)). ([225b830a](https://github.com/kurtome/leap/commit/225b830a554988bc55ad3f3dcd10fa44139fc0b0))
 - **BREAKING** **FEAT**: Refactoring collision detection for simplified API and improved performance ([#32](https://github.com/kurtome/leap/issues/32)). ([4b767231](https://github.com/kurtome/leap/commit/4b767231e6ce0df68b52757adca08e7519ef01c2))
 - **BREAKING** **FEAT**: StatusComponent system, ladders, and more inputs ([#28](https://github.com/kurtome/leap/issues/28)). ([eafe653f](https://github.com/kurtome/leap/commit/eafe653f60ad123241b810717caff4fdef8ef363))


## 2023-11-14

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.3.1`](#leap---v031)

---

#### `leap` - `v0.3.1`

 - **FIX**: walking down slopes not working properly ([#24](https://github.com/kurtome/leap/issues/24)). ([b88b13be](https://github.com/kurtome/leap/commit/b88b13be2d36a07955014e897236b30ebd37f6d9))
 - **FEAT**: adding ability to change map in runtime ([#23](https://github.com/kurtome/leap/issues/23)). ([05c615e0](https://github.com/kurtome/leap/commit/05c615e08943de8ed41c7e6949dc70ddecef4e56))
 - **FEAT**: adding tsx packing filter to TiledOptions ([#26](https://github.com/kurtome/leap/issues/26)). ([3accb89f](https://github.com/kurtome/leap/commit/3accb89f098cf0432211550e2ee80ce967958ffd))


## 2023-11-01

### Changes

---

Packages with breaking changes:

 - [`leap` - `v0.3.0`](#leap---v030)

Packages with other changes:

 - There are no other changes in this release.

---

#### `leap` - `v0.3.0`

 - **FEAT**: allow game to specify max atlas sizes ([#20](https://github.com/kurtome/leap/issues/20)). ([fce72722](https://github.com/kurtome/leap/commit/fce72722fc86be38be38b3d735890189f60ec366))
 - **BREAKING** **FEAT**: Adding support for Moving Platorms ([#21](https://github.com/kurtome/leap/issues/21)). ([9583948f](https://github.com/kurtome/leap/commit/9583948f37a15a47231263c927247bb65ceaedd0))


## 2023-10-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.2.2`](#leap---v022)

---

#### `leap` - `v0.2.2`


## 2023-10-27

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.2.1`](#leap---v021)

---

#### `leap` - `v0.2.1`

 - **FIX**: left tap input broken, cannot turn left ([#15](https://github.com/kurtome/leap/issues/15)). ([9eab90b0](https://github.com/kurtome/leap/commit/9eab90b0bba5fb1270863362351b9e529544e2a4))
 - **FEAT**: add Tiled object factories to automatically build Components ([#16](https://github.com/kurtome/leap/issues/16)). ([2d801212](https://github.com/kurtome/leap/commit/2d8012126770263dabc72c016274adcb86e8f050))
 - **FEAT**: allow keyboard keys to be customizable in simple keyboard input  ([#17](https://github.com/kurtome/leap/issues/17)). ([dbd0ae74](https://github.com/kurtome/leap/commit/dbd0ae74c9188ffeb68f41db9a847a6f4476727f))
 - **FEAT**: adding custom classes and types ([#14](https://github.com/kurtome/leap/issues/14)). ([6e1e016e](https://github.com/kurtome/leap/commit/6e1e016e7d56409a1fe0d98351fbe2aa58c957e2))


## 2023-10-19

### Changes

---

Packages with breaking changes:

 - [`leap` - `v0.2.0`](#leap---v020)

Packages with other changes:

 - There are no other changes in this release.

---

#### `leap` - `v0.2.0`

 - **FEAT**: allowing bundle and images loading customization ([#12](https://github.com/kurtome/leap/issues/12)). ([f412f38b](https://github.com/kurtome/leap/commit/f412f38b96f96e8c7308657a874183bc5c432275))
 - **BREAKING** **FEAT**: upgrade to flame 1.9.1 ([#7](https://github.com/kurtome/leap/issues/7)). ([7b59cdcd](https://github.com/kurtome/leap/commit/7b59cdcdf0066760132f6c9bf78d4658f08d21a3))


## 2022-12-19

### Changes

---

Packages with breaking changes:

 - [`leap` - `v0.1.0`](#leap---v010)

Packages with other changes:

 - There are no other changes in this release.

---

#### `leap` - `v0.1.0`

 - **BREAKING** **FEAT**: updating to flame 1.5 ([#6](https://github.com/kurtome/leap/issues/6)). ([a1c345c8](https://github.com/kurtome/leap/commit/a1c345c89709ebed5adc4eaec722a8a9abcea8c3))


## 2022-09-24

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.0.3`](#leap---v003)

---

#### `leap` - `v0.0.3`

 - **FEAT**: uncoupling input implementation ([#5](https://github.com/kurtome/leap/issues/5)). ([bb2fdd26](https://github.com/kurtome/leap/commit/bb2fdd2679de13efa394fe8270ba68f395e350ab))


## 2022-09-11

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.0.2`](#leap---v002)

---

#### `leap` - `v0.0.2`

 - **FEAT**: add CollisionDetectionBehavior docs ([#3](https://github.com/kurtome/leap/issues/3)). ([21e0ffd0](https://github.com/kurtome/leap/commit/21e0ffd06ec696e8abbfa9d08ce7ae2b74cf5927))


## 2022-09-11

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`leap` - `v0.0.1+1`](#leap---v0011)

---

#### `leap` - `v0.0.1+1`

 - **DOCS**: bootstrapping the docs for initial release ([#1](https://github.com/kurtome/leap/issues/1)). ([7ecdedc9](https://github.com/kurtome/leap/commit/7ecdedc92b1f3401af1c1c67993d47d45049551b))

