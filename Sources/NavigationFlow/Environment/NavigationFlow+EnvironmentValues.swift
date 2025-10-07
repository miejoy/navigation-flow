//
//  NavigationFlow+EnvironmentValues.swift
//  
//
//  Created by 黄磊 on 2023/7/2.
//

import SwiftUI
import DataFlow
import ViewFlow

extension EnvironmentValues {
    /// 导航管理器
    public var navManager: NavigationManager {
        get { self[NavigationManagerEnvironmentKey.self] ?? Store<SceneState>.shared(on: sceneId).navManager }
        set { self[NavigationManagerEnvironmentKey.self] = newValue }
    }
    
    /// 导航堆栈
    public var navStack: Store<NavigationState>? {
        get { self[NavigationStateKey.self] }
        set { self[NavigationStateKey.self] = newValue }
    }
}

/// 展示存储器对应的 key
struct NavigationManagerEnvironmentKey: EnvironmentKey {
    static let defaultValue: NavigationManager? = nil
}

/// 展示存储器对应的 key
struct NavigationStateKey: EnvironmentKey {
    static let defaultValue: Store<NavigationState>? = nil
}
