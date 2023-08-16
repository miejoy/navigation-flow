//
//  NavigationAction.swift
//  
//
//  Created by 黄磊 on 2023/7/6.
//

import DataFlow
import ViewFlow

public struct NavigationAction: Action {
    
    enum InnerRouteOf {
        case root
        case route(AnyViewRoute)
    }
    
    struct InnerPushAction {
        let page: NavigationPage
        
        var baseOnRoute: InnerRouteOf?
    }
    
    /// 消失相关事件
    struct InnerPopAction {
        /// 依赖于 target 的销毁数，为 0  时即表示 target 变为最顶层
        let popCount: UInt
        let targetRoute: InnerRouteOf?
    }
    
    /// 内部事件
    enum ContentAction {
        case push(InnerPushAction)
        case pop(InnerPopAction)
        case remove(AnyViewRoute)
    }
    
    var action: ContentAction
}

extension NavigationAction {
    // MARK: - Push
    
    // MARK: -Push With View
    
    /// 推入展示对应界面
    ///
    /// - Parameter view: 需要展示界面
    /// - Parameter route: 基于那个路由的界面展示，默认是最顶部
    /// - Returns Self: 返回构造好的自己
    public static func push<P:PushableView>(
        _ view: P,
        baseOn route: AnyViewRoute? = nil
    ) -> Self {
        var routeOf: InnerRouteOf? = nil
        if let route = route {
            routeOf = .route(route)
        }
        return push(view, routeOf)
    }
    
    /// 从跟视图推入展示对应界面
    ///
    /// - Parameter view: 需要展示界面
    /// - Returns Self: 返回构造好的自己
    public static func pushOnRoot<P:PushableView>(
        _ view: P
    ) -> Self {
        push(view, .root)
    }
    
    static func push<P:PushableView>(
        _ view: P,
        _ baseOn: InnerRouteOf? = nil
    ) -> Self {
        .init(
            action: .push(
                .init(
                    page: .init(
                        viewRoute: P.defaultRoute.eraseToAnyRoute(),
                        viewInitData: (),
                        viewMaker: .init(view)
                    ),
                    baseOnRoute: baseOn
                )
            )
        )
    }
    
    // MARK: -Push With View Type
    
    /// 推入展示对应界面
    ///
    /// - Parameter viewType: 需要展示界面的类型
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    /// - Parameter route: 基于那个路由的界面展示，默认是最顶部
    /// - Returns Self: 返回构造好的自己
    public static func push<P:PushableView>(
        _ viewType: P.Type,
        _ initData: P.InitData,
        baseOn route: AnyViewRoute? = nil
    ) -> Self {
        var routeOf: InnerRouteOf? = nil
        if let route = route {
            routeOf = .route(route)
        }
        return push(P.self, initData, routeOf)
    }
    
    /// 推入展示对应无参数初始化界面
    ///
    /// - Parameter viewType: 需要展示界面的类型
    /// - Parameter route: 基于那个路由的界面展示，默认是最顶部
    /// - Returns Self: 返回构造好的自己
    public static func push<P:PushableView>(
        _ viewType: P.Type,
        baseOn: AnyViewRoute? = nil
    ) -> Self where P.InitData == Void {
        var routeOf: InnerRouteOf? = nil
        if let baseOn = baseOn {
            routeOf = .route(baseOn)
        }
        return push(P.self, (), routeOf)
    }
    
    /// 从跟视图推入展示对应界面
    ///
    /// - Parameter viewType: 需要展示界面的类型
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    /// - Returns Self: 返回构造好的自己
    public static func pushOnRoot<P:PushableView>(
        _ viewType: P.Type,
        _ initData: P.InitData
    ) -> Self {
        push(P.self, initData, .root)
    }
    
    /// 从跟视图推入展示对应无参数初始化界面
    ///
    /// - Parameter viewType: 需要展示界面的类型
    /// - Returns Self: 返回构造好的自己
    public static func pushOnRoot<P:PushableView>(
        _ viewType: P.Type
    ) -> Self where P.InitData == Void {
        push(P.self, (), .root)
    }
    
    static func push<P:PushableView>(
        _ viewType:P.Type,
        _ initData: P.InitData,
        _ baseOn: InnerRouteOf? = nil
    ) -> Self {
        .init(
            action: .push(
                .init(
                    page: .init(
                        P.defaultRoute.wrapper(initData),
                        viewMaker: .init(P.self)
                    ),
                    baseOnRoute: baseOn
                )
            )
        )
    }
    
    // MARK: -Push With Route
    
    /// 推入展示对应路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    /// - Parameter baseOn: 基于那个路由的界面展示，默认是最顶部
    /// - Returns Self: 返回构造好的自己
    public static func push<InitData>(
        _ route: ViewRoute<InitData>,
        _ data: InitData,
        baseOn: AnyViewRoute? = nil
    ) -> Self {
        var routeOf: InnerRouteOf? = nil
        if let baseOn = baseOn {
            routeOf = .route(baseOn)
        }
        return push(route.wrapper(data), routeOf)
    }
    
    /// 推入展示对应无参数路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter baseOn: 基于那个路由的界面展示，默认是最顶部
    /// - Returns Self: 返回构造好的自己
    public static func push(
        _ route: ViewRoute<Void>,
        baseOn: AnyViewRoute? = nil
    ) -> Self {
        var routeOf: InnerRouteOf? = nil
        if let baseOn = baseOn {
            routeOf = .route(baseOn)
        }
        return push(route.wrapper(()), routeOf)
    }
    
    /// 从跟视图推入展示对应路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    /// - Returns Self: 返回构造好的自己
    public static func pushOnRoot<InitData>(
        _ route: ViewRoute<InitData>,
        _ data: InitData
    ) -> Self {
        push(route.wrapper(data), .root)
    }
    
    /// 从跟视图推入展示对应无参数路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Returns Self: 返回构造好的自己
    public static func pushOnRoot(
        _ route: ViewRoute<Void>
    ) -> Self {
        push(route.wrapper(()), .root)
    }
    
    // MARK: -Push With RouteData
    
    public static func push(
        _ routeData: ViewRouteData,
        baseOn: AnyViewRoute? = nil
    ) -> Self {
        var routeOf: InnerRouteOf? = nil
        if let baseOn = baseOn {
            routeOf = .route(baseOn)
        }
        return push(routeData, routeOf)
    }
    
    public static func pushOnRoot(
        _ routeData: ViewRouteData
    ) -> Self {
        push(routeData, .root)
    }
    
    static func push(
        _ viewRootData: ViewRouteData,
        _ baseOn: InnerRouteOf? = nil
    ) -> Self {
        .init(
            action: .push(
                .init(
                    page: .init(viewRootData),
                    baseOnRoute: baseOn
                )
            )
        )
    }
    
    // MARK: -Push With AnyRoute
    
    /// 推入展示对应路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    /// - Parameter baseOn: 基于那个路由的界面展示，默认是最顶部
    /// - Returns Self: 返回构造好的自己
    public static func push(
        _ route: AnyViewRoute,
        _ data: Any = Void(),
        baseOn: AnyViewRoute? = nil
    ) -> Self {
        var routeOf: InnerRouteOf? = nil
        if let baseOn = baseOn {
            routeOf = .route(baseOn)
        }
        return push(route, data, routeOf)
    }
    
    /// 从跟视图推入展示对应路由的界面
    ///
    /// - Parameter route: 需要展示界面的路由
    /// - Parameter initData: 需要展示界面初始化所需要的数据
    /// - Returns Self: 返回构造好的自己
    public static func pushOnRoot(
        _ route: AnyViewRoute,
        _ data: Any = Void()
    ) -> Self {
        push(route, data, .root)
    }
    
    static func push(
        _ route: AnyViewRoute,
        _ data: Any = Void(),
        _ baseOn: InnerRouteOf? = nil
    ) -> Self {
        .init(
            action: .push(
                .init(
                    page: .init(viewRoute: route, viewInitData: data),
                    baseOnRoute: baseOn
                )
            )
        )
    }
    
    // MARK: - Pop
    
    /// 弹出消失指定数量的界面
    ///
    /// - Parameter popCount: 需要弹出消失的界面数，默认是 1 个
    /// - Parameter route: 从那个界面开始弹出，默认是顶部
    /// - Returns Self: 返回构造好的自己
    public static func pop(_ popCount: UInt = 1, from route: AnyViewRoute? = nil) -> Self {
        var targetRoute: InnerRouteOf? = nil
        if let route = route {
            targetRoute = .route(route)
        }
        return pop(popCount, targetRoute)
    }
    
    /// 弹出消失直到指定的路由对应界面
    ///
    /// - Parameter route: 直到的指定 route 对应界面
    /// - Returns Self: 返回构造好的自己
    public static func pop(to route: AnyViewRoute? = nil) -> Self {
        var targetRoute: InnerRouteOf? = nil
        if let route = route {
            targetRoute = .route(route)
        }
        return pop(0, targetRoute)
    }
    
    /// 弹出消失到跟试图
    ///
    /// - Returns Self: 返回构造好的自己
    public static func popToRoot() -> Self {
        pop(0, .root)
    }
    
    static func pop(
        _ count: UInt,
        _ targetRoute: InnerRouteOf? = nil
    ) -> Self {
        .init(
            action: .pop(
                .init(
                    popCount: count,
                    targetRoute: targetRoute
                )
            )
        )
    }
    
    
    // MARK: - Remove
    
    /// 移除对应路由的界面
    ///
    /// - Parameter route: 需要移除界面对应的路由
    /// - Returns Self: 返回构造好的自己
    public static func remove(with route: AnyViewRoute) -> Self {
        .init(action: .remove(route))
    }
}
