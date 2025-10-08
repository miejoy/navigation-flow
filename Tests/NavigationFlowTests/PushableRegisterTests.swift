//
//  PushableRegisterTests.swift
//  navigation-flow
//
//  Created by 黄磊 on 2025/10/7.
//

import SwiftUI
import Testing
@testable import DataFlow
@testable import ViewFlow
@testable import NavigationFlow
import XCTViewFlow

@MainActor
@Suite("导航堆栈界面测试")
struct PushableRegisterTests {
    init() {
        _ = NavigationStackFlowTests.register
    }
    
    @Test("默认导航中心注册测试")
    func testDefaultCenterRegister() {
        let sceneId = SceneId.custom(#function)
        let rootView = NavigationStackFlow {
            NormalView()
        }
        
        NormalView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        #expect(NormalView.s_navStack != nil)
        if let navStack = NormalView.s_navStack {
            navStack.push(PushFirstView.self)
            ViewTest.refreshHost(host)
            
            #expect(navStack.arrPaths.count == 1)
            if navStack.arrPaths.count == 1 {
                #expect(navStack.state.arrPaths[0].viewRoute == PushFirstView.defaultRoute.eraseToAnyRoute())
            }
        }
        

        ViewTest.releaseHost(host)
    }
    
    @Test("导航管理器注册测试")
    func testNavigationManagerRegister() {
        let sceneId = SceneId.custom(#function)
        let rootView = NavigationStackFlow {
            NormalView()
                .registerPushableView(PushManagerRegisterView.self)
                .registerPushableView(PushFirstView.self, for: .secondRoute)
                .registerPushOn { navManager in
                    navManager.registerPushableView(PushSecondView.self, for: .firstRoute)
                }
        }
        
        NormalView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        #expect(NormalView.s_navStack != nil)
        if let navStack = NormalView.s_navStack {
            navStack.push(PushManagerRegisterView.defaultRoute)
            ViewTest.refreshHost(host)
            #expect(navStack.arrPaths.count == 1)
            
            PushFirstView.s_navStack = nil
            PushSecondView.s_navStack = nil
            
            navStack.push(.firstRoute)
            ViewTest.refreshHost(host)
            #expect(navStack.arrPaths.count == 2)
            // 实际推入的是 PushSecondView
            #expect(PushFirstView.s_navStack == nil)
            #expect(PushSecondView.s_navStack != nil)
            
            PushFirstView.s_navStack = nil
            PushSecondView.s_navStack = nil
            navStack.push(.secondRoute)
            ViewTest.refreshHost(host)
            #expect(navStack.arrPaths.count == 3)
            #expect(PushFirstView.s_navStack != nil)
            #if os(macOS)
            #expect(PushSecondView.s_navStack == nil)
            #else
            // 由于这个也在堆栈中，所以他也会刷新，这可能是 ViewTest 缺陷，正常应该不会出现
            #expect(PushSecondView.s_navStack != nil)
            #endif
        }
        
        ViewTest.releaseHost(host)
    }
}


struct PushManagerRegisterView: VoidPushableView {
    var content: some View {
        Text("")
    }
}
