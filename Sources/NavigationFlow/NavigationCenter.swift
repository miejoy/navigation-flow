//
//  NavigationCenter.swift
//  
//
//  Created by 黄磊 on 2023/7/4.
//

import SwiftUI
import DataFlow
import ViewFlow

public final class NavigationCenter {
    
    public static let shared: NavigationCenter = .init()
    
    var registerMap: [AnyViewRoute: PushedViewMaker] = [:]
    var externalViewMaker: ((_ routeData: ViewRouteData, _ sceneId: SceneId) -> AnyView)? = nil
    
    /// 使用默认路由注册对应展示界面
    @inlinable
    public func registerDefaultPushableView<V: PushableView>(_ presentableViewType: V.Type) {
        let route = V.defaultRoute
        registerPushableView(V.self, for: route)
    }
    
    /// 使用默认路由注册对应展示界面
    @inlinable
    public func registerDefaultPushableView<V: PushableView>(_ presentableViewType: V.Type) where V.InitData == Void {
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
    
    /// 注册对应展示界面
    public func registerPushableView<V: PushableView>(
        _ presentableViewType: V.Type,
        for route: ViewRoute<V.InitData>
    ) where V.InitData == Void {
        let key = route.eraseToAnyRoute()
        if registerMap[key] != nil {
            NavigationMonitor.shared.fatalError("Duplicate registration of PushableView '\(key)'")
        }
        registerMap[key] = .init(V.self)
    }
    
    public func registerExternalViewMaker(_ viewMaker: @escaping (_ routeData: ViewRouteData, _ sceneId: SceneId) -> AnyView) {
        if externalViewMaker != nil {
            NavigationMonitor.shared.fatalError("Duplicate registration of External View Maker")
        }
        externalViewMaker = viewMaker
    }
    
    func canMakeView(of page: NavigationPage) -> Bool {
        registerMap[page.viewRouteData.route] != nil
    }
    
    func makeView(of page: NavigationPage, for navStore: Store<NavigationState>, on sceneId: SceneId) -> AnyView {
        if let viewMaker = page.viewMaker {
            return viewMaker.makeView(page.viewRouteData.initData)
        }
        
        if let externalViewMaker = externalViewMaker {
            return externalViewMaker(page.viewRouteData, sceneId)
        }
        let notFoundView = VStack {
            Text("Push view not found with route '\(page.viewRouteData.route.description)'")
            Button("Dismiss") {
                navStore.send(action: .pop())
                // Store<PresentState>.shared(on: sceneId).dismissTopView()
            }
        }
        return AnyView(notFoundView)
    }
}
