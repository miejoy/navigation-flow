//
//  NavigationStateTests.swift
//  navigation-flow
//
//  Created by 黄磊 on 2025/10/1.
//

import SwiftUI
import Testing
@testable import DataFlow
@testable import ViewFlow
@testable import NavigationFlow
import XCTViewFlow

@MainActor
@Suite("导航堆栈测试")
struct NavigationStateTests {    
    init() {
        _ = NavigationStackFlowTests.register
    }
    
    @Test("导航堆栈构造测试")
    func testCreateNavigationState() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.stackId.stackId == "\(#file):\(#function)")
        #expect(navStack.state.arrPaths.isEmpty)
    }
    
    // MARK: - Push
    
    @Test("导航堆栈使用界面推入事件测试")
    func testPushWithView() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        navStack.push(NormalView())
        
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count > 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[0].viewMaker != nil)
        }
    }
    
    @Test("导航堆栈使用界面类型推入事件测试")
    func testPushWithViewType() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        navStack.push(NormalView.self)
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count > 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
        }
        
        navStack.push(FirstPushView.self, ())
        #expect(navStack.state.arrPaths.count == 2)
        
        navStack.push(SecondPushView.self, baseOn: NormalView.defaultRoute.eraseToAnyRoute())
        #expect(navStack.state.arrPaths.count == 2)
        if navStack.state.arrPaths.count == 2 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == SecondPushView.defaultRoute.eraseToAnyRoute())
        }
        
        navStack.push(ThirdPushView.self, (), baseOn: NormalView.defaultRoute.eraseToAnyRoute())
        #expect(navStack.state.arrPaths.count == 2)
        if navStack.state.arrPaths.count == 2 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == ThirdPushView.defaultRoute.eraseToAnyRoute())
        }
    }
    
    @Test("导航堆栈使用路由推入事件测试")
    func testPushWithRoute() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        let viewRoute: ViewRoute<Void> = .normalRoute
        navStack.push(viewRoute)
        
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count > 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == viewRoute.eraseToAnyRoute())
        }
        
        navStack.push(.firstRoute, ())
        #expect(navStack.state.arrPaths.count == 2)
        
        navStack.push(.secondRoute, baseOn: NormalView.defaultRoute.eraseToAnyRoute())
        #expect(navStack.state.arrPaths.count == 2)
        if navStack.state.arrPaths.count == 2 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == SecondPushView.defaultRoute.eraseToAnyRoute())
        }
        
        navStack.push(.thirdRoute, (), baseOn: NormalView.defaultRoute.eraseToAnyRoute())
        #expect(navStack.state.arrPaths.count == 2)
        if navStack.state.arrPaths.count == 2 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == ThirdPushView.defaultRoute.eraseToAnyRoute())
        }
    }
    
    @Test("导航堆栈使用任意路由推入事件测试")
    func testPushWithAnyViewRoute() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        let anyViewRoute: AnyViewRoute = .init(route: .normalRoute)
        navStack.push(anyViewRoute)
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count > 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == anyViewRoute)
        }
        
        let firstAnyRoute = ViewRoute<Void>.firstRoute.eraseToAnyRoute()
        navStack.push(firstAnyRoute, ())
        #expect(navStack.state.arrPaths.count == 2)
        
        let secondAnyRoute = ViewRoute<Void>.secondRoute.eraseToAnyRoute()
        navStack.push(secondAnyRoute, baseOn: NormalView.defaultRoute.eraseToAnyRoute())
        #expect(navStack.state.arrPaths.count == 2)
        if navStack.state.arrPaths.count == 2 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == SecondPushView.defaultRoute.eraseToAnyRoute())
        }
        
        let thirdAnyRoute = ViewRoute<Void>.thirdRoute.eraseToAnyRoute()
        navStack.push(thirdAnyRoute, (), baseOn: NormalView.defaultRoute.eraseToAnyRoute())
        #expect(navStack.state.arrPaths.count == 2)
        if navStack.state.arrPaths.count == 2 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == ThirdPushView.defaultRoute.eraseToAnyRoute())
        }
    }
    
    @Test("导航堆栈使用带数据路由推入事件测试")
    func testPushWithViewRouteData() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        let viewRouteData = ViewRoute<Void>.normalRoute.wrapper(())
        navStack.push(viewRouteData)
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count == 1 {
            #expect(navStack.state.arrPaths[0].viewRoute == ViewRoute<Void>.normalRoute.eraseToAnyRoute())
        }
        
        navStack.push(ViewRoute<Void>.firstRoute.wrapper(()))
        #expect(navStack.state.arrPaths.count == 2)
        
        navStack.push(ViewRoute<Void>.secondRoute.wrapper(()), baseOn: NormalView.defaultRoute.eraseToAnyRoute())
        #expect(navStack.state.arrPaths.count == 2)
        if navStack.state.arrPaths.count == 2 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == SecondPushView.defaultRoute.eraseToAnyRoute())
        }
    }
    
    @Test("导航堆栈从根视图推入界面事件测试")
    func testPushOnRoot() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        navStack.push(FirstPushView())
        #expect(navStack.state.arrPaths.count == 1)
        navStack.push(SecondPushView())
        #expect(navStack.state.arrPaths.count == 2)
        navStack.push(ThirdPushView())
        #expect(navStack.state.arrPaths.count == 3)
        if navStack.state.arrPaths.count == 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == SecondPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[2].viewRoute == ThirdPushView.defaultRoute.eraseToAnyRoute())
        }
        
        // View
        navStack.pushOnRoot(NormalView())
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count > 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
        }
        
        // View Type
        navStack.push(NormalView.self)
        #expect(navStack.state.arrPaths.count == 2)
        navStack.pushOnRoot(FirstPushView.self)
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count > 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
        }
        
        navStack.push(FirstPushView.self)
        #expect(navStack.state.arrPaths.count == 2)
        navStack.pushOnRoot(NormalView.self, ())
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count > 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
        }
        
        // View Route
        navStack.push(NormalView.defaultRoute)
        #expect(navStack.state.arrPaths.count == 2)
        navStack.pushOnRoot(SecondPushView.defaultRoute)
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count > 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == SecondPushView.defaultRoute.eraseToAnyRoute())
        }
        
        navStack.push(SecondPushView.defaultRoute)
        #expect(navStack.state.arrPaths.count == 2)
        navStack.pushOnRoot(NormalView.defaultRoute, ())
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count > 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
        }
        
        // Any View Route
        navStack.push(NormalView.defaultRoute.eraseToAnyRoute())
        #expect(navStack.state.arrPaths.count == 2)
        navStack.pushOnRoot(ThirdPushView.defaultRoute.eraseToAnyRoute())
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count > 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == ThirdPushView.defaultRoute.eraseToAnyRoute())
        }
        
        navStack.push(ThirdPushView.defaultRoute.eraseToAnyRoute())
        #expect(navStack.state.arrPaths.count == 2)
        navStack.pushOnRoot(NormalView.defaultRoute.eraseToAnyRoute(), ())
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count > 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
        }
        
        // View Route Data
        navStack.push(ViewRoute<Void>.normalRoute.wrapper(()))
        #expect(navStack.state.arrPaths.count == 2)
        navStack.pushOnRoot(ViewRoute<Void>.firstRoute.wrapper(()))
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count > 0 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
        }
    }
    
    @Test("导航堆栈从指定界面推入界面事件测试")
    func testPushBaseOnRoute() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        navStack.push(FirstPushView())
        #expect(navStack.state.arrPaths.count == 1)
        navStack.push(SecondPushView())
        #expect(navStack.state.arrPaths.count == 2)
        navStack.push(ThirdPushView())
        #expect(navStack.state.arrPaths.count == 3)
        
        navStack.push(NormalView(), baseOn: FirstPushView.defaultRoute.eraseToAnyRoute())
        #expect(navStack.state.arrPaths.count == 2)
        if navStack.state.arrPaths.count == 2 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == NormalView.defaultRoute.eraseToAnyRoute())
        }
    }
    
    // MARK: - Pop
    
    @Test("导航堆栈退出顶部界面事件测试")
    func testPopTopView() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        navStack.push(FirstPushView())
        #expect(navStack.state.arrPaths.count == 1)
        navStack.push(SecondPushView())
        #expect(navStack.state.arrPaths.count == 2)
        navStack.push(ThirdPushView())
        #expect(navStack.state.arrPaths.count == 3)
        if navStack.state.arrPaths.count == 3 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == SecondPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[2].viewRoute == ThirdPushView.defaultRoute.eraseToAnyRoute())
        }
        
        navStack.pop()
        #expect(navStack.state.arrPaths.count == 2)
        if navStack.state.arrPaths.count == 2 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == SecondPushView.defaultRoute.eraseToAnyRoute())
        }
    }
    
    @Test("导航堆栈退出顶部2个界面事件测试")
    func testPopTopTwoView() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        navStack.push(FirstPushView())
        #expect(navStack.state.arrPaths.count == 1)
        navStack.push(SecondPushView())
        #expect(navStack.state.arrPaths.count == 2)
        navStack.push(ThirdPushView())
        #expect(navStack.state.arrPaths.count == 3)
        if navStack.state.arrPaths.count == 3 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == SecondPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[2].viewRoute == ThirdPushView.defaultRoute.eraseToAnyRoute())
        }
        
        navStack.pop(2)
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count == 1 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
        }
    }
    
    @Test("导航堆栈从指定路由退出一个界面事件测试")
    func testPopTopFromView() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        navStack.push(FirstPushView())
        #expect(navStack.state.arrPaths.count == 1)
        navStack.push(SecondPushView())
        #expect(navStack.state.arrPaths.count == 2)
        navStack.push(ThirdPushView())
        #expect(navStack.state.arrPaths.count == 3)
        if navStack.state.arrPaths.count == 3 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == SecondPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[2].viewRoute == ThirdPushView.defaultRoute.eraseToAnyRoute())
        }
        
        navStack.pop(1, from: SecondPushView.defaultRoute.eraseToAnyRoute())
        #expect(navStack.state.arrPaths.count == 1)
        if navStack.state.arrPaths.count == 1 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
        }
    }
    
    @Test("导航堆栈退出到根视图事件测试")
    func testPopToRoot() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        navStack.push(FirstPushView())
        #expect(navStack.state.arrPaths.count == 1)
        navStack.push(SecondPushView())
        #expect(navStack.state.arrPaths.count == 2)
        navStack.push(ThirdPushView())
        #expect(navStack.state.arrPaths.count == 3)
        if navStack.state.arrPaths.count == 3 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == SecondPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[2].viewRoute == ThirdPushView.defaultRoute.eraseToAnyRoute())
        }
        
        navStack.popToRoot()
        #expect(navStack.state.arrPaths.count == 0)
    }
    
    // MARK: - Remove
    
    @Test("导航堆栈移除指定路由界面事件测试")
    func testRemoveViewWithRoute() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        navStack.push(FirstPushView())
        #expect(navStack.state.arrPaths.count == 1)
        navStack.push(SecondPushView())
        #expect(navStack.state.arrPaths.count == 2)
        navStack.push(ThirdPushView())
        #expect(navStack.state.arrPaths.count == 3)
        
        navStack.remove(with: SecondPushView.defaultRoute)
        if navStack.state.arrPaths.count == 2 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == ThirdPushView.defaultRoute.eraseToAnyRoute())
        }
    }
    
    @Test("导航堆栈移除指定任意路由界面事件测试")
    func testRemoveViewWithAnyViewRoute() {
        let navStack = NavigationState.makeNormalNavStack()
        
        #expect(navStack.state.arrPaths.isEmpty)
        navStack.push(FirstPushView())
        #expect(navStack.state.arrPaths.count == 1)
        navStack.push(SecondPushView())
        #expect(navStack.state.arrPaths.count == 2)
        navStack.push(ThirdPushView())
        #expect(navStack.state.arrPaths.count == 3)
        navStack.push(SecondPushView())
        #expect(navStack.state.arrPaths.count == 4)
        
        navStack.remove(with: SecondPushView.defaultRoute.eraseToAnyRoute())
        if navStack.state.arrPaths.count == 2 {
            #expect(navStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
            #expect(navStack.state.arrPaths[1].viewRoute == ThirdPushView.defaultRoute.eraseToAnyRoute())
        }
    }
}

extension NavigationState {
    static func makeNormalNavStack(_ file: String = #file, _ func: String = #function) -> Store<NavigationState> {
        print("make with stackId: \(file):\(`func`)\n")
        let store = Store<NavigationState>.box(.init(NormalNavigationStackId(stackId: "\(file):\(`func`)")))
        // 由于 data_flow 中的 loadReducers 会被异步执行，这里需要等待执行完成，后期 data_flow 支持 MainActor 后可修复
        // sleep(1)
        return store
    }
}
