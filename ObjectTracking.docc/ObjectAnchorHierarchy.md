# Object Anchor와 자식 Entity 이해하기

Reality Composer Pro에서 Reference Object를 추적 대상으로 연결하고, 현실 물체의 움직임을 가상 콘텐츠에 전달하는 구조를 알아봅니다.

## Overview

### Reference Object는 추적 기준을 제공한다

Chapter 1에서 만든 `.referenceobject`는 Vision Pro가 현실에서 어떤 물체를 찾아야 하는지 알려 주는 학습 결과입니다. 그러나 이 파일을 Reality Composer Pro 프로젝트에 넣는 것만으로 Object Tracking이 시작되지는 않습니다.

Reality Composer Pro에서 Reference Object를 사용할 Entity를 만들고 Anchoring Component를 추가해야 합니다. Target을 `Object`로 설정한 뒤 `.referenceobject`를 Anchor Object로 선택합니다. 이 Entity가 현실 물체를 따라가는 Object Anchor가 됩니다.

### 현재 프로젝트의 Object Anchor

현재 `ObjectTrackingScene.usda`에서는 `TreasureChestAnchor`가 Object Anchor 역할을 합니다.

```text
TreasureChestAnchor
└─ Anchoring Component
   ├─ Target: Object
   └─ Anchor Object: TreasureChest.referenceobject
```

Vision Pro가 실제 TreasureChest를 인식하면 RealityKit은 `TreasureChestAnchor`를 해당 물체의 위치와 방향에 맞춥니다.

### 반투명 모델은 배치 가이드다

Anchor Object를 선택하면 Reality Composer Pro의 3D View에 Reference Object의 반투명 모델이 나타납니다. 이 모델은 앱에서 보여 줄 가상 TreasureChest가 아닙니다.

반투명 모델은 현실 물체가 어느 위치와 방향으로 추적될지 보여 주는 배치 가이드입니다. 가상 콘텐츠를 이 가이드에 맞추면 실기기에서 현실 물체와 자연스럽게 정렬할 수 있습니다.

### 자식 Entity가 Object Anchor를 따라간다

Object Anchor 아래에 배치한 Entity는 Anchor의 좌표계를 기준으로 위치와 회전을 계산합니다.

```text
Root
└─ TreasureChestAnchor
   ├─ Anchoring Component
   └─ ToyBiplane
```

`ToyBiplane`의 Transform은 전체 현실 공간을 기준으로 한 값이 아닙니다. 추적된 TreasureChest를 원점으로 삼는 로컬 Transform입니다. 보물상자가 움직이거나 회전하면 Anchor가 갱신되고 비행기도 같은 기준을 따라 움직입니다.

가상 콘텐츠를 `Root` 아래에서 Object Anchor와 형제 관계로 두면 이 연결이 만들어지지 않습니다. 현실 물체와 함께 움직여야 하는 콘텐츠는 Object Anchor의 자식으로 배치해야 합니다.

### 현재 완성 Scene과 학습 순서

현재 프로젝트의 완성 Scene에는 이후 Chapter에서 사용할 Entity도 들어 있습니다.

```text
Root
└─ TreasureChestAnchor
   ├─ ToyBiplane
   ├─ Pivot
   └─ Occlusion
```

`ToyBiplane`, `Pivot`, `Occlusion`은 모두 `TreasureChestAnchor`의 좌표계 안에 있습니다. Chapter 2에서는 Object Anchor와 기본 가상 콘텐츠를 연결합니다. `Pivot`을 이용한 Orbit Animation과 `Occlusion` geometry는 Chapter 3에서 다룹니다.

### Swift가 Anchor Transform을 복사하지 않는 이유

현재 프로젝트는 가상 콘텐츠를 Object Anchor의 자식으로 배치합니다. 따라서 Swift에서 매 프레임 Anchor Transform을 읽어 `ToyBiplane`에 복사할 필요가 없습니다. RealityKit이 부모-자식 구조를 이용해 정렬을 관리합니다.

앱이 현실 공간의 Anchor Transform을 직접 읽어 좌표 계산이나 별도의 상호작용에 사용하려면 `SpatialTrackingSession` 같은 추가 구성이 필요할 수 있습니다. 이 기능은 현재 기본 Tutorial의 범위에 포함하지 않습니다.

![TreasureChestAnchor 아래에 Anchoring Component와 ToyBiplane이 배치된 부모-자식 구조](object-anchor-hierarchy.svg)

이 구조를 직접 만드는 과정은 <doc:ConfigureObjectTrackingInRealityComposerPro>에서 진행합니다. RCP Scene이 Swift 코드와 연결되는 과정은 <doc:RCPSceneRuntimeFlow>에서 이어서 확인할 수 있습니다.
