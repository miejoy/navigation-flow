//
//  PushableRegister.swift
//  navigation-flow
//
//  Created by 黄磊 on 2025/10/7.
//

import SwiftUI
import DataFlow
import ViewFlow

extension View {
    /// 注册对应可展示界面
    public func registerPushableView<V: PushableView>(_ pushableViewType: V.Type, file: String = #fileID, function: String = #function, line: Int = #line) -> some View {
        return registerPushableView(pushableViewType, for: V.defaultRoute, file: file, function: function, line: line)
    }
    
    /// 注册对应可展示界面
    public func registerPushableView<V: PushableView>(_ pushableViewType: V.Type, for route: ViewRoute<V.InitData>, file: String = #fileID, function: String = #function, line: Int = #line) -> some View {
        return self.modifier(PushableRegisterModifier(callback: { sceneId in
            let navManager = NavigationManager.shared(on: sceneId)
            let callId = NavigationManager.CallId(file: file, function: function, line: line)
            if !navManager.registerCallSet.contains(callId) {
                navManager.registerPushableView(pushableViewType, for: route)
                navManager.registerCallSet.insert(callId)
            }
        }))
    }
    
    /// 在回调内注册对应可展示界面
    public func registerPushOn(_ callback: @escaping (_ navManager: NavigationManager) -> Void, file: String = #fileID, function: String = #function, line: Int = #line) -> some View {
        return self.modifier(PushableRegisterModifier(callback: { sceneId in
            let navManager = NavigationManager.shared(on: sceneId)
            let callId = NavigationManager.CallId(file: file, function: function, line: line)
            if !navManager.registerCallSet.contains(callId) {
                callback(navManager)
                navManager.registerCallSet.insert(callId)
            }
        }))
    }
}

/// 展示修改器
struct PushableRegisterModifier: ViewModifier {
    
    var callback: (SceneId) -> Void
    @Environment(\.sceneId) var sceneId
    
    func body(content: Content) -> some View {
        return content.onAppear {
            callback(sceneId)
        }
    }
}
