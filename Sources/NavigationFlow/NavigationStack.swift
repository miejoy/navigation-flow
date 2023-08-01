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
    // MARK: - Present
    
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
        self.send(action: .push(P.self, data, baseOn: route))
    }
    
    @inlinable
    public func push<P: PushableView>(
        _ viewType: P.Type,
        baseOn route: AnyViewRoute? = nil
    ) where P.InitData == Void {
        self.send(action: .push(P.self, baseOn: route))
    }
    
    /// 从跟视图推入展示对应界面
    ///
    /// - Parameter viewType: 需要展示界面的类型
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    @inlinable
    public func pushOnRoot<P:PushableView>(
        _ viewType:P.Type,
        _ initData: P.InitData
    ) where P.InitData == Void {
        self.send(action: .pushOnRoot(P.self))
    }
    
    /// 从跟视图推入展示对应无参数初始化界面
    ///
    /// - Parameter viewType: 需要展示界面的类型
    public func pushOnRoot<P:PushableView>(
        _ viewType:P.Type
    ) where P.InitData == Void {
        self.send(action: .pushOnRoot(P.self))
    }
    
    /// 推入展示对应路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    /// - Parameter baseOn: 基于那个路由的界面展示，默认是最顶部
    public func push<InitData>(
        _ route: ViewRoute<InitData>,
        _ data: InitData,
        baseOn: AnyViewRoute? = nil
    ) {
        self.send(action: .push(route, data, baseOn: baseOn))
    }
    
    /// 推入展示对应无参数路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter baseOn: 基于那个路由的界面展示，默认是最顶部
    public func push(
        _ route: ViewRoute<Void>,
        baseOn: AnyViewRoute? = nil
    ) {
        self.send(action: .push(route, baseOn: baseOn))
    }
    
    /// 从跟视图推入展示对应路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    public func pushOnRoot<InitData>(
        _ route: ViewRoute<InitData>,
        _ data: InitData
    ) {
        self.send(action: .pushOnRoot(route, data))
    }
    
    /// 从跟视图推入展示对应无参数路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    public func pushOnRoot(
        _ route: ViewRoute<Void>
    ) {
        self.send(action: .pushOnRoot(route))
    }
    
    // MARK: - Pop
    
    /// 弹出消失指定数量的界面
    ///
    /// - Parameter popCount: 需要弹出消失的界面数，默认是 1 个
    /// - Parameter route: 从那个界面开始弹出，默认是顶部
    public func pop(_ popCount: UInt = 1, from route: AnyViewRoute? = nil) {
        self.send(action: .pop(popCount, from: route))
    }
    
    /// 弹出消失到跟试图
    public func popToRoot() {
        self.send(action: .popToRoot())
    }
    
    // MARK: - Remove
    
    /// 移除对于路由的界面
    ///
    /// - Parameter route: 需要移除界面对应的路由
    public func remove(with route: AnyViewRoute) {
        self.send(action: .remove(with: route))
    }
    
    // MARK: - Make View
    
    func makePushView(of page: NavigationPage, on sceneId: SceneId) -> some View {
        NavigationCenter.shared.makeView(of: page, for: self, on: sceneId)
    }
}
