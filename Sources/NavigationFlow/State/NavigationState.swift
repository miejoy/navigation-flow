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

/// 导航状态
public struct NavigationState: FullStorableViewState {
    public typealias BindAction = NavigationAction
    
    var stackId: NavigationStackId
    var arrPaths: [NavigationPage] = []
    
    public init(_ stackId: NavigationStackId) {
        self.stackId = stackId
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
                state.arrPaths.remove(at: index)
            }
        }
    }
    
    /// 统一处理推出界面方法
    mutating func pushWith(pushAction: NavigationAction.InnerPushAction, on sceneId: SceneId) {
        var navPage = pushAction.page
        if pushAction.page.viewMaker == nil &&
            !NavigationManager.shared(on: sceneId).canMakeView(of: &navPage) {
            NavigationMonitor.shared.record(event: .pushFailedNotRegister(pushAction.page.viewRoute))
            return
        }
        
        if let baseOn = pushAction.baseOnRoute {
            switch baseOn {
            case .root:
                arrPaths.removeAll()
            case .route(let viewRoute):
                let index = arrPaths.lastIndex { page in
                    viewRoute == page.viewRoute
                }
                guard let index = index else {
                    // 没有找到，需要记录
                    NavigationMonitor.shared.record(event: .pushFailedBaseOnRouteNotFound(viewRoute))
                    return
                }
                let nextIndex = arrPaths.index(after: index)
                if nextIndex != arrPaths.endIndex {
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
                    arrPaths.removeSubrange(nextIndex...)
                }
            }
        }
        if popAction.popCount > 0 {
            if popAction.popCount <= arrPaths.count {
                arrPaths.removeLast(Int(popAction.popCount))
            } else {
                NavigationMonitor.shared.fatalError("Pop \(popAction.popCount) view while \(arrPaths.count) views exist")
                arrPaths.removeAll()
            }
        }
    }
}

/// 导航中的一页数据（内部使用）
struct NavigationPage: Hashable {
    static func == (lhs: NavigationPage, rhs: NavigationPage) -> Bool {
        lhs.pageUUID == rhs.pageUUID
    }
    
    let pageUUID: UUID = UUID()
    let title: String?
    // 这里为什么不直接保存 ViewRouteData，
    // 主要由于有些场景无法构造出来，比如传入的是 View 实例，那就只能用 viewMake 构造了
    let viewRoute: AnyViewRoute
    var viewInitData: Any
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
}
