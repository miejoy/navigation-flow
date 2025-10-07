# NavigationFlow

NavigationFlow 是基于 ViewFlow 的 导航堆栈流操作模块，为 SwiftUI 提供方便的界面推入和退出导航堆栈的功能。

NavigationFlow 是自定义 RSV(Resource & State & View) 设计模式中 State 层的应用模块，同时也是 View 层的应用模块。负责给 View 提供可操作的导航堆栈流。

[![Swift](https://github.com/miejoy/navigation-flow/actions/workflows/test.yml/badge.svg)](https://github.com/miejoy/navigation-flow/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/miejoy/navigation-flow/branch/main/graph/badge.svg)](https://codecov.io/gh/miejoy/navigation-flow)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![Swift](https://img.shields.io/badge/swift-5.8-brightgreen.svg)](https://swift.org)

## 依赖

- iOS 16.0+ / macOS 13+
- Xcode 15.0+
- Swift 5.8+

## 简介

### 该模块包含如下内容:

- NavigationState: 导航状态，对应 Store 叫导航堆栈(NavigationStack)，外部可通过这个导航堆栈对导航堆栈流进行各种操作，如果 推入界面、退出界面、移除界面等
- NavigationAction: 导航堆栈操作事件，主要对外提供 推入、退出、移除 三类事件
- NavigationStackFlow: 导航堆栈包装界面，如果需要可操作的导航堆栈流，需要在合适的外出使用该界面包装起来，用 NavigationStackModifier 修饰是同样的效果
- NavigationStackId: 导航堆栈ID，用户标记一个导航堆栈，目前包含下列两种：
  - NormalNavigationStackId: 普通导航堆栈，这种都是临时使用的，可创建多个，不会共享
  - SharedNavigationStackId: 共享导航堆栈，通过这个ID获取的导航堆栈是共享的
- PushableView: 可推入界面协议，所以需要推入到导航堆栈的界面需要遵循这个协议
- NavigationCenter: 导航中心，主要用于注册可 Push 界面，独立存储，不会保存在 AppState 中
- NavigationManager: 导航管理器，主要获取共享导航堆栈，会保存在 AppState 中

### 为 SwiftUI 提供如下环境变量:

- navManager: 导航管理器，可用于获取共享导航堆栈
- navStack: 当前导航堆栈，实际是导航状态的存储器，外部可通过这个导航堆栈对导航堆栈流进行各种操作

### 为 SwiftUI 提供如下修改器:
- NavigationStackModifier: 导航堆栈修改器，用于构造一个可操作的导航堆栈流
- NavigationTitleModifier: 导航标题修改器，用于修改导航标题

## 安装

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

在项目中的 Package.swift 文件添加如下依赖:

```swift
dependencies: [
    .package(url: "https://github.com/miejoy/navigation-flow.git", from: "0.1.0"),
]
```

## 使用

### 前置准备工作

- 使用 NavigationStackFlow 包装需要导航堆栈的根界面（这里使用导航堆栈修饰器 NavigationStackModifier() 是一样的效果）
- 使用 registerPushOn 方法注册可推入界面界面，注册的界面可直接用路由来推入，不需要知道对应界面

```swift
import SwiftUI
import NavigationFlow

struct MainView: View {
    var body: some View {
        // 使用导航堆栈流包装器
        NavigationStackFlow {
            NavigationRootView()
        }
        .registerPushOn { navManager in
            // 注册路由对应可推入界面
            // 可以直接注册默认路由
            navManager.registerDefaultPushableView(PushFirstView.self)
            // 也可以指定路由
            navManager.registerPushableView(PushSecondView.self, for: .secondRoute)
        }
    }
}

// 可以单独定义路由
extension ViewRoute where InitData == Void {
    static let firstRoute: ViewRoute<Void> = PushFirstView.defaultRoute
    static let secondRoute: ViewRoute<Void> = PushSecondView.defaultRoute
}

```

### 使用导航堆栈推入界面

- 有如下多类方式推入界面:
  - 使用 PushableView 对应界面实例直接推入，这种适用于当前环境能构造对应界面
  - 使用 PushableView 对应界面类型和初始化数据推入，这种适用于知道推入界面类型和对应初始化数据
  - 使用 ViewRoute 路由方式推入界面，这种方式适用于当前界面不知道被推入界面的具体类型时使用，路由也有三种
    - ViewRoute: 包含初始化数据类型的路由，需要配合初始化数据使用
    - AnyViewRoute: 任意路由，需要配合任意初始化数据使用，使用过程中可能失败
    - ViewRouteData: 任意路由数据，可直接使用

```swift
import SwiftUI
import NavigationFlow

struct NavigationRootView: View {

    // 读取环境中的导航堆栈，这里可能是 nil，因为当前界面无法保证是否被包裹在 NavigationStackFlow 中
    @Environment(\.navStack) var navStack

    var body: some View {
        VStack {
            VStack {
                Button {
                    navStack?.push(PushFirstView())
                } label: {
                    Text("Push One View")
                }
                
                Button {
                    navStack?.push(PushFirstView.self)
                } label: {
                    Text("Push One View With Type")
                }
                
                Button {
                    navStack?.push(PushFirstView.defaultRoute)
                } label: {
                    Text("Push One View With Route")
                }
                
                Button {
                    navStack?.push(PushFirstView.self)
                    navStack?.push(PushSecondView.self)
                } label: {
                    Text("Push Two View")
                }
            }
        }
    }
}
```

### 使用共享导航堆栈推入界面

#### 首先需要用共享导航堆栈ID构造导航堆栈根界面
```swift
import SwiftUI
import NavigationFlow

@main
struct MainView: View {
    var body: some View {
        // 使用共享导航堆栈流包装器
        NavigationStackFlow(shared: .main) {
            NavigationRootView()
        }
    }
}
```

#### 使用导航管理器获取共享导航堆栈

```swift
import SwiftUI
import NavigationFlow

struct NavigationRootView: View {

    // 读取环境中的导航管理器
    @Environment(\.navManager) var navManager

    var body: some View {
        VStack {
            VStack {
                Button {
                    // 先用 sharedNavStack 获取导航堆栈，可能失败，在用 push 推入界面
                    navManager.sharedNavStack(of: .main)?.push(PushFirstView())
                } label: {
                    Text("Push One View On Main Nav")
                }
            }
        }
    }
}
```


### 使用导航堆栈退出界面

- 有如下多种方式消失界面:
  - 使用系统的 dismiss 环境变量消失界面
  - 使用导航堆栈提供的方法消失界面

```swift
import SwiftUI
import NavigationFlow

struct PushFirstView: VoidPushableView {

    @Environment(\.dismiss) var dismiss
    @Environment(\.navStack) var navStack

    var content: some View {
        VStack {
            Button {
                dismiss()
            } label: {
                Text("Dismiss Top View")
            }
            Button {
                navStack?.pop()
            } label: {
                Text("Pop Top View")
            }
            Button {
                navStack?.popToRoot()
            } label: {
                Text("Pop To Root View")
            }
        }
    }
}
```

### 使用导航堆栈直接移除指定界面

注意：尽量不要使用这个，调用会让界面出现意料之外的动画

```swift
import SwiftUI
import NavigationFlow

struct PushSecondView: VoidPushableView {
    @Environment(\.navStack) var navStack

    var content: some View {
        VStack {
            Button {
                navStack?.remove(with: PushFirstView.defaultRoute)
            } label: {
                Text("Remove First View")
            }
        }
    }
}
```

## 作者

Raymond.huang: raymond0huang@gmail.com

## License

NavigationFlow is available under the MIT license. See the LICENSE file for more info.

