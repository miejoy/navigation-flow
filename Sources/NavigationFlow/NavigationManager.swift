//
//  NavigationManager.swift
//  
//
//  Created by 黄磊 on 2023/7/5.
//

import DataFlow
import ViewFlow
import SwiftUI

/// 对应场景的导航管理器，主要获取共享导航堆栈，会保存在 AppState
public class NavigationManager {
    /// 导航堆栈容器，这里只是弱引用方式包装堆栈，堆栈实际持有者为 NavigationStackFlow 的 StateObject
    struct NavigationStackContainer {
        weak var navStack: Store<NavigationState>?
    }
    // 调用 ID，为了解决 SwifUI 中刷新界面时重复调用问题
    struct CallId: Hashable {
        let file: String
        let function: String
        let line: Int
    }
    
    public let sceneId: SceneId
    var mapSharedStacks: [String:NavigationStackContainer] = [:]
    var registerMap: [AnyViewRoute: PushedViewMaker] = [:]
    var registerCallSet: Set<CallId> = []
    
    init(sceneStore: Store<SceneState>?) {
        self.sceneId = sceneStore?.sceneId ?? .main
        self.mapSharedStacks = [:]
    }
    
    // MARK: - Shared
    
    /// 获取对应 scene 的导航管理器，暂时不对外公开，可以使用 @Environment(\.navManager) 获取
    static func shared(on sceneId: SceneId) -> NavigationManager {
        Store<SceneState>.shared(on: sceneId).storage[NavigationManagerKey.self]
    }
    
    /// 获取对应 scene 中指定的共享导航堆栈，可能返回 nil
    public static func sharedNavStack(on sceneId: SceneId, of navStackId: SharedNavigationStackId) -> Store<NavigationState>? {
        return shared(on: sceneId).sharedNavStack(of: navStackId)
    }
    
    
    // MARK: - Register
    
    /// 使用默认路由注册对应可推入界面
    @inlinable
    public func registerDefaultPushableView<V: PushableView>(_ pushableViewType: V.Type) {
        let route = V.defaultRoute
        registerPushableView(V.self, for: route)
    }
    
    /// 使用默认路由注册对应可推入界面
    @inlinable
    public func registerDefaultPushableView<V: PushableView>(_ pushableViewType: V.Type) where V.InitData == Void {
        let route = V.defaultRoute
        registerPushableView(V.self, for: route)
    }
    
    /// 注册对应可推入界面
    public func registerPushableView<V: PushableView>(
        _ pushableViewType: V.Type,
        for route: ViewRoute<V.InitData>
    ) {
        let key = route.eraseToAnyRoute()
        if registerMap[key] != nil {
            NavigationMonitor.shared.fatalError("Duplicate registration of PushableView '\(key)'")
        }
        registerMap[key] = .init(V.self)
    }
    
    /// 注册对应可推入界面
    public func registerPushableView<V: PushableView>(
        _ pushableViewType: V.Type,
        for route: ViewRoute<V.InitData>
    ) where V.InitData == Void {
        let key = route.eraseToAnyRoute()
        if registerMap[key] != nil {
            NavigationMonitor.shared.fatalError("Duplicate registration of PushableView '\(key)'")
        }
        registerMap[key] = .init(V.self)
    }
    
    // MARK: - Private
    
    /// 获取当前导航管理器中指定的共享导航堆栈，可能返回 nil
    public func sharedNavStack(of navStackId: SharedNavigationStackId) -> Store<NavigationState>? {
        guard let container = mapSharedStacks[navStackId.stackId] else {
            return nil
        }
        
        return container.navStack
    }
    
    /// 添加并保存共享导航堆栈，非共享导航堆栈将被忽略
    func addNavStack(_ navStack: Store<NavigationState>, at viewPath: ViewPath) {
        if let sharedStackId = navStack.stackId as? SharedNavigationStackId {
            if let oldContainer = mapSharedStacks[sharedStackId.stackId] {
                // 共享状态如果存在旧的，需要判断是否为同一个
                if let oldStack = oldContainer.navStack,
                   oldStack !== navStack {
                    // 不同，需要抛异常
                    NavigationMonitor.shared.fatalError("Add shared navigation stack[\(navStack)] with stackId[\(sharedStackId)] failed! Exist other stack[\(oldStack)]")
                }
            }
            
            // 这里用弱引用保存
            mapSharedStacks[sharedStackId.stackId] = .init(navStack: navStack)
            navStack.setDestroyCallback { [weak self] _ in
                self?.mapSharedStacks.removeValue(forKey: sharedStackId.stackId)
            }
        }
    }
    
    func canMakeView(of page: inout NavigationPage) -> Bool {
        if let viewMaker = registerMap[page.viewRoute],
            let initData = viewMaker.check(page.viewInitData) {
            page.viewInitData = initData
            return true
        }
        return NavigationCenter.shared.canMakeView(of: &page)
    }
    
    func makeView(of page: NavigationPage, for navStore: Store<NavigationState>, on sceneId: SceneId) -> AnyView {
        if let viewMaker = page.viewMaker {
            return AnyView(viewMaker.makeView(page.viewInitData).environment(\.suggestNavTitle, page.title))
        }
        
        if let viewMaker = registerMap[page.viewRoute] {
            return AnyView(viewMaker.makeView(page.viewInitData).environment(\.suggestNavTitle, page.title))
        }

        return NavigationCenter.shared.makeView(of: page, for: navStore, on: sceneId)
    }
}


// MARK: -

extension SceneState {
    /// 当前场景可共享状态的 Store 存储器
    @usableFromInline
    var navManager: NavigationManager {
        self.storage[NavigationManagerKey.self]
    }
}

public struct NavigationManagerKey: SceneStorageKey {
    public static func defaultValue(on sceneStore: Store<SceneState>?) -> NavigationManager {
        return .init(sceneStore: sceneStore)
    }
}
