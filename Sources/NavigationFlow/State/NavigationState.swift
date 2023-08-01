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

public struct NavigationState: FullStorableViewState, InitializableState {
    
    public typealias BindAction = NavigationAction
    
    var arrPaths: [NavigationPage] = []
    
    public init() {
    }
    
    public static func loadReducers(on store: Store<NavigationState>) {
        store.registerDefault { state, action in
            switch action.action {
            case .push(let pushAction):
                if !NavigationCenter.shared.canMakeView(of: pushAction.page) {
                    NavigationMonitor.shared.record(event: .pushFailedNotRegister(pushAction.page.viewRouteData.route))
                    return
                }
                if let baseOn = pushAction.baseOnRoute {
                    switch baseOn {
                    case .root:
                        state.arrPaths.removeAll()
                    case .route(let viewRoute):
                        let index = state.arrPaths.lastIndex { page in
                            viewRoute == page.viewRouteData.route
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
                            viewRoute == page.viewRouteData.route
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
                    state.arrPaths.removeLast(Int(popAction.popCount))
                }
            case .remove(let viewRoute):
                let index = state.arrPaths.lastIndex { page in
                    viewRoute == page.viewRouteData.route
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
    var viewRouteData: ViewRouteData
    // 界面构造器，如果有，优先使用这个
    var viewMaker: PushedViewMaker?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(viewRouteData.route)
        hasher.combine(pageUUID)
    }
    
    init(_ viewRouteData: ViewRouteData, viewMaker: PushedViewMaker? = nil) {
        self.viewRouteData = viewRouteData
        self.viewMaker = viewMaker
    }
}
