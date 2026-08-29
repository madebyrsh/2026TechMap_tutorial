# Reality Composer Pro Scene의 실행 흐름

Reality Composer Pro에서 만든 Scene이 Swift 패키지에 포함되고 visionOS 앱의 `RealityView`에서 활성화되는 과정을 알아봅니다.

## Overview

### RCP에서 만든 Scene은 아직 화면에 보이지 않는다

Reality Composer Pro에서 Object Anchor와 가상 콘텐츠를 구성하면 Scene 파일이 만들어집니다. 현재 프로젝트에서는 그 파일이 `ObjectTrackingScene.usda`입니다.

Scene을 저장하는 것만으로 앱이 자동으로 보여 주지는 않습니다. Swift에서 Scene을 번들로부터 불러와 `RealityView`에 추가해야 합니다.

### RealityKitContent 패키지의 역할

현재 프로젝트의 RCP 자산은 로컬 Swift 패키지인 `RealityKitContent` 안에 있습니다.

```text
RealityKitContent
└─ RealityKitContent.rkassets
   ├─ ObjectTrackingScene.usda
   ├─ TreasureChest.referenceobject
   ├─ TreasureChest.usdz
   └─ ToyBiplane.usdz
```

Xcode가 패키지를 빌드하면 RCP Scene과 관련 자산이 `realityKitContentBundle`에 포함됩니다. 앱 타깃은 `import RealityKitContent`를 통해 이 번들에 접근합니다.

### Scene 이름은 파일 이름과 연결된다

`ImmersiveView`는 다음 호출로 RCP Scene을 불러옵니다.

```swift
let objectTrackingScene = try await Entity(
    named: "ObjectTrackingScene",
    in: realityKitContentBundle
)
```

`ObjectTrackingScene`은 Object Anchor가 아니라 불러올 RCP Scene의 이름입니다. 문자열과 Scene 파일 이름이 다르면 앱은 원하는 Scene을 찾지 못합니다.

### RealityView에 추가해야 활성화된다

`Entity(named:in:)`은 Scene의 루트 Entity를 비동기로 불러옵니다. 이 Entity를 `content.add(objectTrackingScene)`으로 `RealityView`에 추가해야 합니다. 그래야 Scene의 Entity와 Component가 실행 중인 공간 경험에 참여합니다.

```text
ObjectTrackingScene.usda
        ↓ Entity(named:in:)
Scene의 Root Entity
        ↓ RealityView content.add
TreasureChestAnchor 활성화
        ↓ 현실 TreasureChest 인식
자식 가상 콘텐츠 정렬
```

### Object Tracking에는 ImmersiveSpace가 필요하다

visionOS의 Object Tracking은 Window나 Volume이 아니라 `ImmersiveSpace`에서 동작합니다. 현재 앱은 현실 공간을 계속 볼 수 있도록 `mixed` 스타일을 사용합니다.

`ObjectTrackingWithRCPApp`이 `ObjectTrackingSpace`라는 ID로 Space를 등록하고, `ImmersiveSpaceButton`이 같은 ID를 사용해 Space를 엽니다. ID가 다르면 버튼이 의도한 Space를 열 수 없습니다.

### RCP와 Swift의 책임 구분

Reality Composer Pro는 다음을 담당합니다.

- 어떤 `.referenceobject`를 추적할지 설정
- Object Anchor와 자식 Entity의 부모-자식 구조 구성
- 가상 콘텐츠의 로컬 Transform 설정
- Timeline, Animation, Occlusion 같은 Scene 동작 구성

Swift와 SwiftUI는 다음을 담당합니다.

- `ImmersiveSpace` 등록과 열기·닫기
- `RealityKitContent` bundle에서 Scene 불러오기
- Scene의 Root Entity를 `RealityView`에 추가
- 로딩 실패 처리와 사용자 인터페이스 제공

현재 Swift 코드는 Object Tracking의 Pose를 직접 계산하지 않습니다. RCP Scene을 활성화하면 Anchoring Component와 부모-자식 구조가 추적과 콘텐츠 정렬을 담당합니다.

![Xcode 앱이 RealityKitContent bundle에서 ObjectTrackingScene을 불러와 RealityView에 추가하는 흐름](rcp-scene-runtime-flow.svg)

실제 Swift 코드를 연결하는 과정은 <doc:LoadTheRCPSceneInVisionOS>에서 진행합니다. Object Anchor와 자식 Entity의 관계를 다시 확인하려면 <doc:ObjectAnchorHierarchy>를 참고하세요.
