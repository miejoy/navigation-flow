//
//  NavigationManager.swift
//  
//
//  Created by 黄磊 on 2023/7/5.
//

import DataFlow
import ViewFlow
import SwiftUI

public class NavigationManager {
    
    /// 导航堆栈容器，这里只是弱引用方式包装堆栈，堆栈实际持有者为 NavigationStackFlow 的 StateObject
    struct NavigationStackContainer {
        weak var navStack: Store<NavigationState>?
    }
    
    let sceneId: SceneId
    var mapSharedStacks: [String:NavigationStackContainer] = [:]
    
    init(sceneStore: Store<SceneState>?) {
        self.sceneId = sceneStore?.sceneId ?? .main
        self.mapSharedStacks = [:]
    }
    
    public static func shared(on sceneId: SceneId) -> NavigationManager {
        Store<SceneState>.shared(on: .main).storage[NavigationManagerKey.self]
    }
    
    public func sharedNavStack(of navStackId: SharedNavigationStackId) -> Store<NavigationState>? {
        guard let container = mapSharedStacks[navStackId.stackId] else {
            return nil
        }
        
        return container.navStack
    }
    
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
            
            mapSharedStacks[sharedStackId.stackId] = .init(navStack: navStack)
            navStack.setDestroyCallback { [weak self] _ in
                self?.mapSharedStacks.removeValue(forKey: sharedStackId.stackId)
            }
        }
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
