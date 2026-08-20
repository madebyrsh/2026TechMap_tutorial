# Object Tracking

@Metadata {
    @TechnologyRoot
}

Vision Pro가 현실의 물체를 알아보고, 그 물체의 움직임에 맞춰 가상 콘텐츠를 보여 주는 공간 경험을 만들어 봅니다.

## Overview

### Object Tracking이란

Object Tracking은 Vision Pro가 현실 공간에 있는 특정 물체를 알아보고, 그 물체가 움직이거나 회전해도 위치와 방향을 계속 따라가는 기술입니다.

물체를 인식한 뒤에는 그 위치를 기준으로 설명, 효과, 3D model 같은 가상 콘텐츠를 배치할 수 있습니다. 현실의 물체가 움직이면 연결된 가상 콘텐츠도 함께 움직이기 때문에 두 콘텐츠가 하나의 경험처럼 보입니다.

### 이번에 만들 경험

이 Tutorial에서는 실제 TreasureChest를 Vision Pro가 인식하도록 만듭니다. 인식된 보물상자 주변에는 가상 `ToyBiplane`이 나타나 반복해서 원을 그리며 비행합니다.

비행기가 보물상자 앞을 지날 때는 그대로 보입니다. 뒤쪽으로 이동하면 실제 보물상자에 가려진 것처럼 보이도록 Occlusion도 추가합니다. 최종 결과에서는 현실의 물체, 가상 비행기의 Animation, 가림 효과가 하나의 공간 경험으로 연결됩니다.

> Important: Simulator에서는 앱과 자산이 정상적으로 빌드되는지 확인할 수 있지만, 현실 물체를 실제로 인식하고 추적하는 동작은 Apple Vision Pro에서 확인해야 합니다.

### 왜 여러 종류의 자산이 필요한가

Vision Pro는 현실의 보물상자를 파일 이름만으로 알아볼 수 없습니다. 먼저 보물상자의 형태와 크기를 표현한 USDZ 3D model을 준비해야 합니다.

그다음 Create ML이 이 3D model을 바탕으로 보물상자를 인식하는 데 필요한 정보를 학습합니다. 학습 결과는 `.referenceobject` 파일로 저장됩니다. Reality Composer Pro에서는 이 파일을 추적 대상으로 지정하고, 추적되는 물체 아래에 가상 콘텐츠를 배치합니다.

```text
현실의 TreasureChest
        ↓ 같은 형태와 크기를 표현
TreasureChest.usdz
        ↓ Create ML에서 학습
TreasureChest.referenceobject
        ↓ Reality Composer Pro에서 추적 대상으로 설정
TreasureChestAnchor
        ↓ 가상 콘텐츠 연결
ToyBiplane, Animation, Occlusion
        ↓
Apple Vision Pro 공간 경험
```

USDZ와 `.referenceobject`는 서로 다른 역할을 합니다. USDZ는 현실 물체를 표현하는 3D model이고, `.referenceobject`는 Vision Pro가 그 물체를 인식하고 추적하는 데 사용하는 학습 결과입니다.

### 전체 학습 경로

1. **현실 물체와 USDZ 준비**  
   Vision Pro가 추적할 물체를 정하고, 그 물체의 형태와 실제 크기를 충분히 정확하게 표현한 USDZ를 준비합니다.

2. **Create ML로 Reference Object 만들기**  
   준비한 USDZ를 Create ML에서 학습시켜 Object Tracking에 사용할 `.referenceobject`를 만듭니다.

3. **Reality Composer Pro에서 Object Tracking 설정**  
   `.referenceobject`를 Object Anchor의 추적 대상으로 연결합니다.

4. **가상 콘텐츠 연결**  
   현실 물체가 움직일 때 가상 Entity도 함께 움직이도록 Object Anchor를 기준으로 배치합니다.

5. **Animation 추가**  
   Transform-only `Pivot`과 Timeline을 사용해 `ToyBiplane`이 보물상자 주변을 반복해서 돌게 합니다.

6. **Occlusion 추가**  
   비행기가 실제 보물상자 뒤로 이동할 때 자연스럽게 가려지도록 보물상자의 3D 형태와 맞는 geometry를 구성합니다.

7. **Apple Vision Pro에서 확인**  
   실제 물체 인식부터 가상 콘텐츠의 정렬, 반복 Animation, Occlusion까지 최종 결과를 확인합니다.

### 이 모듈에서 다루는 범위

이 모듈은 USDZ를 준비한 다음 Create ML, Reality Composer Pro, SwiftUI, RealityKit을 연결해 하나의 Object Tracking 경험을 완성하는 과정을 다룹니다.

Object Capture는 정확한 USDZ를 준비하는 방법 중 하나로만 소개합니다. 사진 촬영과 3D model 생성 전 과정을 이 모듈에서 다시 가르치지는 않습니다.

기본 학습 경로는 Reality Composer Pro의 Object Anchoring을 사용합니다. `ARKitSession`, `ObjectTrackingProvider`, `SpatialTrackingSession`을 이용해 tracking을 직접 제어하는 방법과 custom RealityKit `System`은 기본 Tutorial에 포함하지 않습니다.

### 개발 환경

완성 예제는 다음 환경을 기준으로 제작하고 Apple Vision Pro에서 동작을 확인했습니다.

- Xcode 26.6
- visionOS 26.5 SDK
- Apple Vision Pro
- Swift와 SwiftUI
- RealityKit
- Reality Composer Pro
- Create ML

Create ML에서 Object Tracking model을 학습하려면 Apple silicon Mac이 필요합니다. 지원 환경은 달라질 수 있으므로 실습을 시작하기 전에 Apple 공식 문서의 최신 요구사항도 확인하세요.

## Topics

### Tutorial

- <doc:ObjectTrackingTutorials>

### 먼저 알아둘 개념

- <doc:ObjectTrackingAssetPipeline>
- <doc:ObjectAnchorHierarchy>
- <doc:RCPSceneRuntimeFlow>
- <doc:TrackedTransformHierarchy>
