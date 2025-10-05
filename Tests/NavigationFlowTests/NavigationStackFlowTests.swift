//
//  NavigationStackFlowTests.swift
//  navigation-flow
//
//  Created by 黄磊 on 2025/10/5.
//

import SwiftUI
import Testing
@testable import DataFlow
@testable import ViewFlow
@testable import NavigationFlow
import XCTViewFlow

@MainActor
@Suite("导航堆栈界面测试")
struct NavigationStackFlowTests {
    static let register: Void = {
        NavigationCenter.shared.registerPushableView(NormalView.self, for: NormalView.defaultRoute)
        NavigationCenter.shared.registerDefaultPushableView(FirstPushView.self)
        NavigationCenter.shared.registerDefaultPushableView(SecondPushView.self)
        NavigationCenter.shared.registerDefaultPushableView(ThirdPushView.self)
    }()
    
    init() {
        _ = Self.register
    }
    
    @Test("使用导航堆栈流")
    func testUseNavigationStackFlow() {
        let sceneId = SceneId.custom(#function)
        let rootView = NavigationStackFlow {
            NormalView()
        }
        
        NormalView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        #expect(NormalView.s_navStack != nil)

        ViewTest.releaseHost(host)
    }
    
    @Test("使用共享导航堆栈流")
    func testUseNavigationStackFlowWithSharedStackId() {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = NavigationStackFlow(shared: shareStackId) {
            NormalView()
        }
        
        NormalView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let shareNavStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId)
        
        #expect(NormalView.s_navStack != nil)
        #expect(shareNavStack != nil)
        if let navStack = NormalView.s_navStack,
            let shareNavStack = shareNavStack {
            #expect(navStack === shareNavStack)
        }

        ViewTest.releaseHost(host)
    }
    
    @Test("使用导航堆栈修饰器")
    func testUseNavigationStackModifier() {
        let sceneId = SceneId.custom(#function)
        let rootView = NormalView().modifier(NavigationStackModifier(#function))
        
        NormalView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        #expect(NormalView.s_navStack != nil)
        if let navStack = NormalView.s_navStack {
            #expect(navStack.stackId.description == #function)
        }

        ViewTest.releaseHost(host)
    }
    
    @Test("使用共享导航堆栈修饰器")
    func testUseNavigationStackModifierWithSharedStackId() {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = NormalView().modifier(NavigationStackModifier(shared: shareStackId))
        
        NormalView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let shareNavStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId)
        
        #expect(NormalView.s_navStack != nil)
        #expect(shareNavStack != nil)
        if let navStack = NormalView.s_navStack,
            let shareNavStack = shareNavStack {
            #expect(navStack === shareNavStack)
            #expect(navStack.stackId.description == shareStackId.description)
        }

        ViewTest.releaseHost(host)
    }
    
    @Test("使用共享导航堆栈推入界面")
    func testUseNavigationStackPushView() {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = NormalView().modifier(NavigationStackModifier(shared: shareStackId))
        
        NormalView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let shareNavStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId)
        
        #expect(shareNavStack != nil)
        if let shareNavStack = shareNavStack {
            FirstPushView.s_navStack = nil
            shareNavStack.push(FirstPushView.self)
            ViewTest.refreshHost(host)
            
            #expect(FirstPushView.s_navStack != nil)
            if let navStack = FirstPushView.s_navStack {
                #expect(navStack === shareNavStack)
            }
            
            #expect(shareNavStack.arrPaths.count == 1)
            if shareNavStack.arrPaths.count == 1 {
                #expect(shareNavStack.state.arrPaths[0].viewRoute == FirstPushView.defaultRoute.eraseToAnyRoute())
            }
        }

        ViewTest.releaseHost(host)
    }
    
    @Test("使用共享导航堆栈退出界面")
    func testUseNavigationStackPopView() {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = NormalView().modifier(NavigationStackModifier(shared: shareStackId))
        
        NormalView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))
        
        let shareNavStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId)
        
        #expect(shareNavStack != nil)
        if let shareNavStack = shareNavStack {
            shareNavStack.push(FirstPushView.self)
            ViewTest.refreshHost(host)
            #expect(shareNavStack.arrPaths.count == 1)
            
            shareNavStack.push(SecondPushView.defaultRoute)
            ViewTest.refreshHost(host)
            #expect(shareNavStack.arrPaths.count == 2)
            
            shareNavStack.push(ThirdPushView.defaultRoute.eraseToAnyRoute())
            ViewTest.refreshHost(host)
            #expect(shareNavStack.arrPaths.count == 3)
            
            shareNavStack.pop()
            #expect(shareNavStack.arrPaths.count == 2)
            
            shareNavStack.popToRoot()
            #expect(shareNavStack.arrPaths.count == 0)
        }

        ViewTest.releaseHost(host)
    }
}


// MARK: - Views

extension ViewRoute where InitData == Void {
    static let normalRoute: ViewRoute<Void> = NormalView.defaultRoute
    static let firstRoute: ViewRoute<Void> = FirstPushView.defaultRoute
    static let secondRoute: ViewRoute<Void> = SecondPushView.defaultRoute
    static let thirdRoute: ViewRoute<Void> = ThirdPushView.defaultRoute
}

struct NormalView: VoidPushableView {
    static var s_navStack: Store<NavigationState>? = nil
    @Environment(\.navStack) var navStack
    
    var content: some View {
        Text("")
            .onAppear {
                Self.s_navStack = navStack
            }
    }
}

struct FirstPushView: VoidPushableView {
    static var s_navStack: Store<NavigationState>? = nil
    @Environment(\.navStack) var navStack
    var content: some View {
        Text("")
            .onAppear {
            Self.s_navStack = navStack
        }
    }
}

struct SecondPushView: VoidPushableView {
    var content: some View {
        Text("")
    }
}

struct ThirdPushView: VoidPushableView {
    var content: some View {
        Text("")
    }
}
