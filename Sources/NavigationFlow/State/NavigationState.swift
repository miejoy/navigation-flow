//
//  NavigationState.swift
//  
//
//  Created by 黄磊 on 2023/7/2.
//

import Foundation
import DataFlow
import ViewFlow
import SwiftUI

// MARK: - NavigationState

/// 导航状态
public struct NavigationState: FullStorableViewState {
    public typealias BindAction = NavigationAction
    
    /// 当前栈 ID
    var stackId: NavigationStackId
    var arrPaths: [NavigationPage] = []
    
    /// 当前栈中界面数量（调试用）
    public var pathCount: Int { arrPaths.count }
    
    public init(_ stackId: NavigationStackId) {
        self.stackId = stackId
    }
    
    public static func assembly(store: Store<some StorableState>, with state: some StorableState) {
        guard let store = store as? Store<Self>, let state = state as? Self else { return }
        store[.stackId] = state.stackId
    }
    
    public static func loadReducers(on store: Store<NavigationState>) {
        store.registerDefault { [weak store] state, action in
            guard let store = store else { return }
            switch action.action {
            case .push(let pushAction):
                state.pushWith(pushAction: pushAction, on: store.sceneId)
            case .pop(let popAction):
                state.popWith(popAction: popAction)
            case .remove(let viewRoute):
                let index = state.arrPaths.lastIndex { page in
                    viewRoute == page.viewRoute
                }
                guard let index = index else {
                    // 没有找到，需要记录
                    NavigationMonitor.shared.record(event: .removeFailedTargetRouteNotFound(viewRoute))
                    return
                }
                state.arrPaths[index].cancelRoute()
                state.arrPaths.remove(at: index)
            }
        }
    }
    
    /// 统一处理推出界面方法
    @MainActor
    mutating func pushWith(pushAction: NavigationAction.InnerPushAction, on sceneId: SceneId) {
        var navPage = pushAction.page
        if pushAction.page.viewMaker == nil &&
            !NavigationManager.shared(on: sceneId).canMakeView(of: &navPage) {
            navPage.failRoute(reason: "Cannot make view for route: \(pushAction.page.viewRoute.description)")
            NavigationMonitor.shared.record(event: .pushFailedNotRegister(pushAction.page.viewRoute))
            return
        }
        
        if let baseOn = pushAction.baseOnRoute {
            switch baseOn {
            case .root:
                arrPaths.forEach { $0.cancelRoute() }
                arrPaths.removeAll()
            case .route(let viewRoute):
                let index = arrPaths.lastIndex { page in
                    viewRoute == page.viewRoute
                }
                guard let index = index else {
                    // 没有找到，需要记录
                    navPage.failRoute(reason: "Base on route not found: \(viewRoute.description)")
                    NavigationMonitor.shared.record(event: .pushFailedBaseOnRouteNotFound(viewRoute))
                    return
                }
                let nextIndex = arrPaths.index(after: index)
                if nextIndex != arrPaths.endIndex {
                    arrPaths[nextIndex...].forEach { $0.cancelRoute() }
                    arrPaths.removeSubrange(nextIndex...)
                }
            }
        }
        arrPaths.append(navPage)
    }
    
    /// 统一处理退出界面方法
    mutating func popWith(popAction: NavigationAction.InnerPopAction) {
        if let baseOn = popAction.targetRoute {
            switch baseOn {
            case .root:
                arrPaths.forEach { $0.cancelRoute() }
                arrPaths.removeAll()
                return
            case .route(let viewRoute):
                let index = arrPaths.lastIndex { page in
                    viewRoute == page.viewRoute
                }
                guard let index = index else {
                    // 没有找到，需要记录
                    NavigationMonitor.shared.record(event: .popFailedTargetRouteNotFound(viewRoute))
                    return
                }
                let nextIndex = arrPaths.index(after: index)
                if nextIndex != arrPaths.endIndex {
                    arrPaths[nextIndex...].forEach { $0.cancelRoute() }
                    arrPaths.removeSubrange(nextIndex...)
                }
            }
        }
        if popAction.popCount > 0 {
            if popAction.popCount <= arrPaths.count {
                let removeStart = arrPaths.count - Int(popAction.popCount)
                arrPaths[removeStart...].forEach { $0.cancelRoute() }
                arrPaths.removeLast(Int(popAction.popCount))
            } else {
                NavigationMonitor.shared.fatalError("Pop \(popAction.popCount) view while \(arrPaths.count) views exist")
                arrPaths.forEach { $0.cancelRoute() }
                arrPaths.removeAll()
            }
        }
    }
}

// MARK: - NavigationPage

/// 导航中的一页数据（内部使用）
struct NavigationPage: Hashable, @unchecked Sendable {
    static func == (lhs: NavigationPage, rhs: NavigationPage) -> Bool {
        lhs.pageUUID == rhs.pageUUID
    }
    
    let pageUUID: UUID = UUID()
    let title: String?
    // 这里为什么不直接保存 ViewRouteData，
    // 主要由于有些场景无法构造出来，比如传入的是 View 实例，那就只能用 viewMake 构造了
    let viewRoute: AnyViewRoute
    var viewInitData: Sendable
    // 界面构造器，如果有，优先使用这个
    let viewMaker: PushedViewMaker?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(viewRoute)
        hasher.combine(pageUUID)
    }
    
    init(_ viewRouteData: ViewRouteData, title: String? = nil, viewMaker: PushedViewMaker? = nil) {
        self.viewRoute = viewRouteData.route
        self.viewInitData = viewRouteData.initData
        self.title = title
        self.viewMaker = viewMaker
    }
    
    /// 使用 AnyViewRoute 和 data 初始化是不可靠的，所以这里必须提供 viewMake，AnyViewRoute 只作为路由标记
    init(viewRoute: AnyViewRoute, title: String? = nil, viewMaker: PushedViewMaker) {
        self.viewRoute = viewRoute
        self.viewInitData = ()
        self.title = title
        self.viewMaker = viewMaker
    }

    // MARK: - Resultable

    /// 如果 initData 实现了 `CancellableRouteData`，调用其 `cancelRoute()`；否则 no-op
    func cancelRoute() {
        (viewInitData as? CancellableRouteData)?.cancelRoute()
    }

    /// 如果 initData 实现了 `CancellableRouteData`，调用其 `failRoute(reason:)`；否则 no-op
    func failRoute(reason: String) {
        (viewInitData as? CancellableRouteData)?.failRoute(reason: reason)
    }
}
