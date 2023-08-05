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

public struct NavigationState: FullStorableViewState {
    
    public typealias BindAction = NavigationAction
    
    var stackId: NavigationStackId
    var arrPaths: [NavigationPage] = []
    
    public init(_ stackId: NavigationStackId) {
        self.stackId = stackId
    }
    
    public static func loadReducers(on store: Store<NavigationState>) {
        store.registerDefault { state, action in
            switch action.action {
            case .push(let pushAction):
                if pushAction.page.viewMaker == nil &&
                    !NavigationCenter.shared.canMakeView(of: pushAction.page) {
                    NavigationMonitor.shared.record(event: .pushFailedNotRegister(pushAction.page.viewRoute))
                    return
                }
                if let baseOn = pushAction.baseOnRoute {
                    switch baseOn {
                    case .root:
                        state.arrPaths.removeAll()
                    case .route(let viewRoute):
                        let index = state.arrPaths.lastIndex { page in
                            viewRoute == page.viewRoute
                        }
                        guard let index = index else {
                            // 没有找到，需要记录
                            NavigationMonitor.shared.record(event: .pushFailedBaseOnRouteNotFound(viewRoute))
                            return
                        }
                        let nextIndex = state.arrPaths.index(after: index)
                        if nextIndex != state.arrPaths.endIndex {
                            state.arrPaths.removeSubrange(nextIndex...)
                        }
                    }
                }
                state.arrPaths.append(pushAction.page)
            case .pop(let popAction):
                if let baseOn = popAction.targetRoute {
                    switch baseOn {
                    case .root:
                        state.arrPaths.removeAll()
                        return
                    case .route(let viewRoute):
                        let index = state.arrPaths.lastIndex { page in
                            viewRoute == page.viewRoute
                        }
                        guard let index = index else {
                            // 没有找到，需要记录
                            NavigationMonitor.shared.record(event: .popFailedTargetnRouteNotFound(viewRoute))
                            return
                        }
                        let nextIndex = state.arrPaths.index(after: index)
                        if nextIndex != state.arrPaths.endIndex {
                            state.arrPaths.removeSubrange(nextIndex...)
                        }
                    }
                }
                if popAction.popCount > 0 {
                    if popAction.popCount <= state.arrPaths.count {
                        state.arrPaths.removeLast(Int(popAction.popCount))
                    } else {
                        NavigationMonitor.shared.fatalError("Pop \(popAction.popCount) view while \(state.arrPaths.count) exist")
                        state.arrPaths.removeAll()
                    }
                }
            case .remove(let viewRoute):
                let index = state.arrPaths.lastIndex { page in
                    viewRoute == page.viewRoute
                }
                guard let index = index else {
                    // 没有找到，需要记录
                    NavigationMonitor.shared.record(event: .removeFailedTargetnRouteNotFound(viewRoute))
                    return
                }
                state.arrPaths.remove(at: index)
            }
        }
    }
}

/// 导航中的一页数据
struct NavigationPage: Hashable {
    static func == (lhs: NavigationPage, rhs: NavigationPage) -> Bool {
        lhs.pageUUID == rhs.pageUUID
    }
    
    var pageUUID: UUID = UUID()
    var viewRoute: AnyViewRoute
    var viewInitData: Any
    // 界面构造器，如果有，优先使用这个
    var viewMaker: PushedViewMaker?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(viewRoute)
        hasher.combine(pageUUID)
    }
    
    init(_ viewRouteData: ViewRouteData, viewMaker: PushedViewMaker? = nil) {
        self.viewRoute = viewRouteData.route
        self.viewInitData = viewRouteData.initData
        self.viewMaker = viewMaker
    }
    
    init(viewRoute: AnyViewRoute, viewInitData: Any, viewMaker: PushedViewMaker? = nil) {
        self.viewRoute = viewRoute
        self.viewInitData = viewInitData
        self.viewMaker = viewMaker
    }
}
