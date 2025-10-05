//
//  NavigationCenter.swift
//  
//
//  Created by 黄磊 on 2023/7/4.
//

import SwiftUI
import DataFlow
import ViewFlow

/// 导航中心，主要用于注册可 Push 界面，独立存储，不会保存在 AppState
public final class NavigationCenter {
    public static let shared: NavigationCenter = .init()
    
    var registerMap: [AnyViewRoute: PushedViewMaker] = [:]
    
    /// 使用默认路由注册对应展示界面
    @inlinable
    public func registerDefaultPushableView<V: PushableView>(_ presentableViewType: V.Type) {
        let route = V.defaultRoute
        registerPushableView(V.self, for: route)
    }
    
    /// 注册对应展示界面
    public func registerPushableView<V: PushableView>(
        _ presentableViewType: V.Type,
        for route: ViewRoute<V.InitData>
    ) {
        let key = route.eraseToAnyRoute()
        if registerMap[key] != nil {
            NavigationMonitor.shared.fatalError("Duplicate registration of PushableView '\(key)'")
        }
        registerMap[key] = .init(V.self)
    }
    
    func canMakeView(of page: inout NavigationPage) -> Bool {
        if let viewMaker = registerMap[page.viewRoute],
            let initData = viewMaker.check(page.viewInitData) {
            page.viewInitData = initData
            return true
        }
        return false
    }
    
    func makeView(of page: NavigationPage, for navStore: Store<NavigationState>, on sceneId: SceneId) -> AnyView {
        if let viewMaker = page.viewMaker {
            return AnyView(viewMaker.makeView(page.viewInitData).environment(\.suggestNavTitle, page.title))
        }
        
        if let viewMaker = registerMap[page.viewRoute] {
            return AnyView(viewMaker.makeView(page.viewInitData).environment(\.suggestNavTitle, page.title))
        }
        
        let notFoundView = VStack {
            Text("Push view not found with route '\(page.viewRoute.description)'")
            Button("Dismiss") {
                navStore.send(action: .pop())
            }
        }
        return AnyView(notFoundView)
    }
}
