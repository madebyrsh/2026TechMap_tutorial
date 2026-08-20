# 추적 좌표계와 Transform 계층 이해하기

추적된 현실 물체의 Transform이 `Pivot`, `ToyBiplane`, Occlusion geometry에 어떻게 전달되는지 알아봅니다.

## Overview

### TreasureChestAnchor가 추적 좌표계를 제공한다

`TreasureChestAnchor`의 Anchoring Component는 `TreasureChest.referenceobject`를 Object target으로 사용합니다. Apple Vision Pro가 실제 TreasureChest를 인식하면 RealityKit은 현실 공간에서 측정한 위치와 방향을 `TreasureChestAnchor`의 tracked Transform으로 반영합니다.

Anchor 아래의 Entity는 이 Transform을 다시 계산하지 않습니다. 각 Entity는 TreasureChest를 원점으로 삼는 local Transform만 가지며, RealityKit이 Anchor의 tracked Transform과 local Transform을 합성해 현실 공간의 최종 위치를 정합니다.

```text
현실 TreasureChest의 tracked Transform
                 ↓
        TreasureChestAnchor
                 ↓ local Transform 합성
      Pivot · ToyBiplane · Occlusion
```

### 세 Entity를 Anchor 아래에 두는 이유

현재 Scene의 핵심 hierarchy는 다음과 같습니다.

```text
Root
└─ TreasureChestAnchor
   ├─ Pivot
   ├─ ToyBiplane
   └─ Occlusion
      └─ OcclusionTreasureChest
```

`Pivot`, `ToyBiplane`, `Occlusion`은 모두 `TreasureChestAnchor`의 자식입니다. 따라서 보물상자가 움직이거나 회전하면 세 Entity가 같은 추적 좌표계를 따라갑니다.

이 Entity들을 `Root` 바로 아래에 두면 TreasureChest의 tracked Transform이 자동으로 전달되지 않습니다. 반대로 `ToyBiplane`을 `Pivot`의 자식으로 만들 필요도 없습니다. 현재 Orbit action은 hierarchy가 아니라 `target`과 `pivot` 참조를 이용해 두 Entity의 역할을 연결합니다.

### Pivot은 회전 중심을 제공한다

`Pivot`은 mesh나 별도의 Anchoring Component가 없는 Transform-only Entity입니다. 현재 완성 Scene에서는 TreasureChest의 local 원점보다 4cm 높은 `(0, 0.04, 0)`에 있습니다.

Orbit action은 다음 두 참조를 가집니다.

```text
Orbit action
├─ target: TreasureChestAnchor/ToyBiplane
└─ pivot:  TreasureChestAnchor/Pivot
```

`Pivot`은 궤도의 중심이고 `ToyBiplane`은 실제로 움직이는 target입니다. 두 Entity는 `TreasureChestAnchor` 아래의 형제입니다. `ToyBiplane`이 `Pivot`의 자식이라서 도는 것이 아니라, Orbit action이 `Pivot`의 위치를 회전 중심으로 사용하기 때문에 돕니다.

현재 `ToyBiplane`은 Anchor 원점에서 `(-0.1, 0.03, 0)`에 있습니다. Pivot과 비행기의 초기 위치 차이가 궤도의 반지름과 높이 관계를 만듭니다. 자신의 model에서는 model 크기와 원하는 경로에 맞게 두 local Transform을 직접 조정해야 합니다.

### Animation도 tracked Transform 안에서 실행된다

Orbit Timeline은 `ToyBiplane`의 local 움직임을 갱신합니다. 최종 위치는 먼저 Anchor의 tracked Transform을 따르고, 그 안에서 Orbit Animation이 적용되는 구조입니다.

```text
TreasureChestAnchor tracked Transform
        × Pivot local Transform
        × Orbit action이 계산한 움직임
        → ToyBiplane의 현실 공간 위치
```

따라서 실제 TreasureChest가 이동해도 궤도 중심과 비행 경로가 보물상자에서 분리되지 않습니다. Swift가 매 frame `ToyBiplane`의 Transform을 Anchor에 복사할 필요도 없습니다.

### Occlusion geometry도 같은 좌표계를 따른다

`Occlusion` container와 그 아래의 `OcclusionTreasureChest` 역시 `TreasureChestAnchor`의 좌표계를 따릅니다. Occlusion geometry가 실제 TreasureChest와 같은 위치, 방향, 크기로 정렬돼야 비행기가 보물상자 뒤로 이동할 때 올바른 부분이 가려집니다.

Occlusion geometry가 Anchor 밖에 있거나 local Transform이 어긋나면, 추적 자체가 정상이어도 가려지는 경계가 실제 물체와 맞지 않습니다. 따라서 Reference Object cue를 기준으로 geometry를 정렬하고, 실기기에서 여러 시점의 경계를 확인해야 합니다.

![TreasureChestAnchor 아래 형제 Entity와 Orbit target, pivot 및 Occlusion 관계](tracked-transform-hierarchy.svg)

이 구조를 직접 만드는 과정은 <doc:AddOrbitAnimation>과 <doc:AddOcclusion>에서 진행합니다.
