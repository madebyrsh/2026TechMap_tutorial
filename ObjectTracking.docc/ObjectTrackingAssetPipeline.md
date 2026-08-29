# Object Tracking 자산의 흐름 이해하기

Vision Pro가 현실의 특정 물체를 알아본 뒤 그 위치에 가상 콘텐츠를 붙이기까지, 어떤 자산이 왜 필요한지 알아봅니다.

## Overview

### 현실 물체를 바로 추적할 수 없는 이유

앱에 “보물상자를 추적해 줘”라고 이름만 알려 주어서는 Vision Pro가 어떤 보물상자를 찾아야 하는지 알 수 없습니다. 같은 종류의 물체라도 형태, 크기, 색과 표면이 서로 다를 수 있기 때문입니다.

먼저 추적하려는 실제 물체를 충분히 정확하게 표현한 3D 모델이 필요합니다. Object Tracking에서는 이 모델을 USDZ 파일로 준비합니다. Create ML은 USDZ를 바탕으로 물체를 인식하는 데 필요한 정보를 학습하고 결과를 `.referenceobject` 파일로 만듭니다.

```text
현실 물체
    ↓ 형태와 크기를 3D로 표현
USDZ
    ↓ Create ML에서 Object Tracking용으로 학습
.referenceobject
    ↓ Reality Composer Pro에서 추적 대상으로 선택
Object Anchor
```

이 흐름에서 USDZ, `.referenceobject`, Object Anchor는 모두 필요하지만 서로 하는 일이 다릅니다.

### 현실에서 추적할 물체

Physical Object는 Vision Pro가 실제 공간에서 찾아야 하는 대상입니다. 이 Tutorial의 완성 사례에서는 실제 TreasureChest가 그 대상입니다.

Object Tracking에는 사용하는 동안 형태가 크게 바뀌지 않는 물체가 적합합니다. 접히거나 휘어져 외형이 계속 달라지면 미리 준비한 3D 모델과 현실의 모습이 일치하지 않습니다.

### 현실 물체를 표현하는 USDZ

USDZ는 현실 물체의 모습을 3D 공간에 표현하는 파일입니다. 3D 형태를 이루는 geometry뿐 아니라 실제 크기와 방향도 담을 수 있습니다. 재질과 텍스처를 이용해 표면의 색과 무늬도 표현합니다.

Object Tracking용 USDZ는 실제 물체와 충분히 잘 맞아야 합니다.

- **전체 형태**: 튀어나온 부분이나 빈 공간처럼 물체를 구분하는 구조가 반영되어야 합니다.
- **실제 크기**: 3D 모델의 가로, 높이, 깊이가 현실 물체와 맞아야 합니다.
- **방향과 원점**: 모델의 앞·뒤와 위·아래가 분명해야 하며, 이후 가상 콘텐츠를 배치할 기준을 이해할 수 있어야 합니다.
- **눈에 띄는 특징**: 손잡이, 모서리, 무늬처럼 물체를 구분하기 쉬운 특징이 빠지지 않아야 합니다.
- **재질과 표면**: 색, 무늬, 반사와 같은 외형이 현실 물체를 충분히 나타내야 합니다.

3D 모델이 현실 물체를 잘 표현할수록 추적 품질을 높이는 데 도움이 됩니다. 모든 모델이 반드시 사진처럼 보여야 하는 것은 아닙니다. 추적 대상의 형태, 크기, 방향, 주요 외형이 실제 물체와 잘 맞는지가 중요합니다.

### Create ML이 만드는 Reference Object

Create ML은 앞에서 준비한 USDZ를 분석하고 Object Tracking 모델을 학습합니다. Vision Pro는 이 모델을 이용해 현실에서 해당 물체의 위치와 방향을 찾습니다.

학습이 끝나면 Create ML은 결과를 `.referenceobject` 파일로 내보냅니다. 이 파일이 Reference Object입니다.

```text
MyObject.usdz
└─ 현실 물체를 3D로 표현한 입력 자산

MyObject.referenceobject
└─ 현실에서 그 물체를 인식하고 추적하기 위한 학습 결과
```

Reference Object 안에는 입력 3D 모델이 함께 포함될 수 있습니다. Reality Composer Pro는 이를 반투명 배치 가이드로 보여 줍니다. `.referenceobject`의 주된 역할은 화면에 보일 모델을 제공하는 것이 아니라 현실 물체를 인식하고 추적하는 것입니다.

### Reality Composer Pro에서 추적 대상 정하기

Reality Composer Pro에서는 Anchoring Component의 Target을 Object로 설정하고, Create ML이 만든 `.referenceobject`를 Anchor Object로 선택합니다.

이 설정을 가진 Entity가 Object Anchor 역할을 합니다. Vision Pro가 현실 물체를 찾으면 Object Anchor가 그 물체의 위치와 방향을 기준으로 놓입니다.

Object Anchor 아래에 가상 Entity를 배치하면 현실 물체가 움직일 때 가상 콘텐츠도 같은 기준을 따라갑니다. Swift에서 매 프레임 Transform을 복사할 필요는 없습니다. RealityKit이 Reality Composer Pro에서 구성한 부모-자식 구조를 이용해 콘텐츠를 정렬합니다.

### 가상 콘텐츠와 Animation

Object Anchor는 현실 물체를 따라가는 기준점입니다. 화면에 보여 줄 가상 모델은 그 아래에 별도의 Entity로 배치합니다.

완성 사례에서는 `ToyBiplane`과 `Pivot`이 `TreasureChestAnchor` 아래에 있습니다. `Pivot`은 Transform만 가진 Entity이며 추적된 좌표계 안에서 비행기의 회전 중심을 제공합니다. Timeline은 이 중심을 이용해 비행기가 보물상자 주변을 돌게 합니다.

### Occlusion geometry가 따로 필요한 이유

Reference Object가 물체를 추적한다고 해서 가상 콘텐츠가 실제 물체 뒤에서 자동으로 가려지는 것은 아닙니다. RealityKit이 어느 부분을 가려야 하는지 알 수 있도록 실제 물체의 깊이와 형태를 대신하는 geometry가 필요합니다.

```text
.referenceobject
└─ 현실 물체가 어디에 있는지 인식하고 추적

Occlusion geometry
└─ 가상 콘텐츠의 어느 부분을 가려야 하는지 깊이로 표현
```

같은 원본 USDZ의 geometry를 Occlusion에 활용할 수 있지만 두 결과의 역할은 다릅니다. Tracking은 `.referenceobject`가 담당하고, 가림 표현은 Occlusion Material을 적용한 geometry가 담당합니다.

### TreasureChest 완성 사례

현재 프로젝트의 자산은 다음과 같이 연결됩니다.

```text
실제 TreasureChest
      ↓ 같은 형태와 크기로 준비
CreateML/TreasureChest.usdz
      ↓ Create ML에서 학습
CreateML/TreasureChest.referenceobject
      ↓ Reality Composer Pro에서 추적 대상으로 선택
TreasureChestAnchor
      ├─ ToyBiplane
      ├─ Pivot
      └─ TreasureChest Occlusion geometry
```

이제 각 자산의 역할을 구분할 수 있습니다. <doc:CreateAReferenceObject>에서는 학습자가 추적하려는 실제 물체와 그 물체를 표현하는 USDZ를 준비하고, 새로운 Create ML 프로젝트에서 자신만의 `.referenceobject`를 만듭니다.
