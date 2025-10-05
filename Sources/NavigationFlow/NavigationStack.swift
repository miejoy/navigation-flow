//
//  NavigationStack.swift
//  
//
//  Created by 黄磊 on 2023/7/28.
//

import Foundation
import DataFlow
import ViewFlow
import SwiftUI

extension Store where State == NavigationState {
    // MARK: - Push
    
    // MARK: -Push With View
    
    /// 推入展示对应界面
    ///
    /// - Parameter view: 需要展示界面
    /// - Parameter route: 基于那个路由的界面展示，默认是最顶部
    @inlinable
    public func push<P: PushableView>(
        _ view: P,
        baseOn route: AnyViewRoute? = nil
    ) {
        if route == nil {
            self.send(action: .push(view, baseOn: route))
        } else {
            withAnimation {
                self.send(action: .push(view, baseOn: route))
            }
        }
    }
    
    /// 从跟视图推入展示对应界面
    ///
    /// - Parameter view: 需要展示界面
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    @inlinable
    public func pushOnRoot<P:PushableView>(
        _ view: P
    ) {
        withAnimation {
            self.send(action: .pushOnRoot(view))
        }
    }
    
    // MARK: -Push With View Type
    
    /// 推入展示对应界面
    ///
    /// - Parameter viewType: 需要展示界面的类型
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    /// - Parameter route: 基于那个路由的界面展示，默认是最顶部
    @inlinable
    public func push<P: PushableView>(
        _ viewType: P.Type,
        _ data: P.InitData,
        baseOn route: AnyViewRoute? = nil
    ) {
        if route == nil {
            self.send(action: .push(P.self, data, baseOn: route))
        } else {
            withAnimation {
                self.send(action: .push(P.self, data, baseOn: route))
            }
        }
    }
    
    @inlinable
    public func push<P: PushableView>(
        _ viewType: P.Type,
        baseOn route: AnyViewRoute? = nil
    ) where P.InitData == Void {
        if route == nil {
            self.send(action: .push(P.self, baseOn: route))
        } else {
            withAnimation {
                self.send(action: .push(P.self, baseOn: route))
            }
        }
    }
    
    /// 从跟视图推入展示对应界面
    ///
    /// - Parameter viewType: 需要展示界面的类型
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    @inlinable
    public func pushOnRoot<P:PushableView>(
        _ viewType: P.Type,
        _ initData: P.InitData
    ) {
        withAnimation {
            self.send(action: .pushOnRoot(P.self, initData))
        }
    }
    
    /// 从跟视图推入展示对应无参数初始化界面
    ///
    /// - Parameter viewType: 需要展示界面的类型
    @inlinable
    public func pushOnRoot<P:PushableView>(
        _ viewType: P.Type
    ) where P.InitData == Void {
        withAnimation {
            self.send(action: .pushOnRoot(P.self))
        }
    }
    
    // MARK: -Push With Route
    
    /// 推入展示对应路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    /// - Parameter baseOn: 基于那个路由的界面展示，默认是最顶部
    @inlinable
    public func push<InitData>(
        _ route: ViewRoute<InitData>,
        _ data: InitData,
        baseOn: AnyViewRoute? = nil
    ) {
        if baseOn == nil {
            self.send(action: .push(route, data, baseOn: baseOn))
        } else {
            withAnimation {
                self.send(action: .push(route, data, baseOn: baseOn))
            }
        }
    }
    
    /// 推入展示对应无参数路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter baseOn: 基于那个路由的界面展示，默认是最顶部
    @inlinable
    public func push(
        _ route: ViewRoute<Void>,
        baseOn: AnyViewRoute? = nil
    ) {
        if baseOn == nil {
            self.send(action: .push(route, baseOn: baseOn))
        } else {
            withAnimation {
                self.send(action: .push(route, baseOn: baseOn))
            }
        }
    }
    
    /// 从跟视图推入展示对应路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    @inlinable
    public func pushOnRoot<InitData>(
        _ route: ViewRoute<InitData>,
        _ data: InitData
    ) {
        withAnimation {
            self.send(action: .pushOnRoot(route, data))
        }
    }
    
    /// 从跟视图推入展示对应无参数路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    @inlinable
    public func pushOnRoot(
        _ route: ViewRoute<Void>
    ) {
        withAnimation {
            self.send(action: .pushOnRoot(route))
        }
    }
    
    // MARK: -Push With Route Data
    
    /// 推入展示对应路由的界面
    ///
    /// - Parameter routeData: 需要展示界面的路由数据
    /// - Parameter baseOn: 基于那个路由的界面展示，默认是最顶部
    @inlinable
    public func push(
        _ routeData: ViewRouteData,
        baseOn: AnyViewRoute? = nil
    ) {
        if baseOn == nil {
            self.send(action: .push(routeData, baseOn: baseOn))
        } else {
            withAnimation {
                self.send(action: .push(routeData, baseOn: baseOn))
            }
        }
    }
    
    /// 从跟视图推入展示对应路由的界面
    ///
    /// - Parameter routeData: 需要展示界面的路由数据
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    @inlinable
    public func pushOnRoot(
        _ routeData: ViewRouteData
    ) {
        withAnimation {
            self.send(action: .pushOnRoot(routeData))
        }
    }
    
    // MARK: -Push With AnyRoute
    
    /// 推入展示对应路由的界面
    /// 注意: 这种方式有可能失败，建议自行构造 ViewRouteData，然后使用上面方法代替。此方法后期可能删除
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    /// - Parameter baseOn: 基于那个路由的界面展示，默认是最顶部
    /// - Returns: 返回是否推入成功
    @inlinable
    @discardableResult
    public func push(
        _ route: AnyViewRoute,
        _ data: Any = Void(),
        baseOn: AnyViewRoute? = nil
    ) -> Bool {
        guard let viewRouteData = route.wrapper(data) else {
            NavigationMonitor.shared.fatalError("Push view [\(route)] failed! Cann't make viewRouteData with data [\(data)]")
            return false
        }
        if baseOn == nil {
            self.send(action: .push(viewRouteData, baseOn: baseOn))
        } else {
            withAnimation {
                self.send(action: .push(viewRouteData, baseOn: baseOn))
            }
        }
        return true
    }
    
    /// 从跟视图推入展示对应路由的界面
    /// 注意: 这种方式有可能失败，建议自行构造 ViewRouteData，然后使用上面方法代替。此方法后期可能删除
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    /// - Returns: 返回是否推入成功
    @inlinable
    @discardableResult
    public func pushOnRoot(
        _ route: AnyViewRoute,
        _ data: Any = Void()
    ) -> Bool {
        guard let viewRouteData = route.wrapper(data) else {
            NavigationMonitor.shared.fatalError("Push view [\(route)] failed! Cann't make viewRouteData with data [\(data)]")
            return false
        }
        withAnimation {
            self.send(action: .pushOnRoot(viewRouteData))
        }
        return true
    }
    
    // MARK: - Pop
    
    /// 弹出消失指定数量的界面
    ///
    /// - Parameter popCount: 需要弹出消失的界面数，默认是 1 个
    /// - Parameter route: 从那个界面开始弹出，默认是顶部
    @inlinable
    public func pop(_ popCount: UInt = 1, from route: AnyViewRoute? = nil) {
        withAnimation {
            self.send(action: .pop(popCount, from: route))
        }
    }
    
    /// 弹出消失到跟试图
    @inlinable
    public func popToRoot() {
        withAnimation {
            self.send(action: .popToRoot())
        }
    }
    
    // MARK: - Remove
    
    /// 移除对应路由的界面
    /// 注意：尽量不要使用这个，调用会让界面出现意料之外的动画
    ///
    /// - Parameter route: 需要移除界面对应的路由
    @inlinable
    public func remove<InitData>(with route: ViewRoute<InitData>) {
        withAnimation {
            self.send(action: .remove(with: route.eraseToAnyRoute()))
        }
    }
    
    /// 移除对应路由的界面
    /// 注意：尽量不要使用这个，调用会让界面出现意料之外的动画
    ///
    /// - Parameter route: 需要移除界面对应的路由
    @inlinable
    public func remove(with route: AnyViewRoute) {
        withAnimation {
            self.send(action: .remove(with: route))
        }
    }
        
    // MARK: - Make View
    
    func makePushView(of page: NavigationPage, on sceneId: SceneId) -> some View {
        NavigationCenter.shared.makeView(of: page, for: self, on: sceneId)
    }
}
