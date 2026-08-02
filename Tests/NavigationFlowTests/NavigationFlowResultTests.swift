//
//  NavigationFlowResultTests.swift
//  navigation-flow
//
//  可返回结果路由测试（基于 ViewTest 实际渲染场景）
//

import SwiftUI
import Testing
@testable import DataFlow
@testable import ViewFlow
@testable import NavigationFlow
import XCTViewFlow

@MainActor
@Suite("可返回结果路由测试")
struct NavigationFlowResultTests {

    static let register: Void = {
        NavigationCenter.shared.registerPushableView(ResultPickerView.self, for: ResultPickerView.defaultRoute)
        NavigationCenter.shared.registerPushableView(AnotherResultPickerView.self, for: AnotherResultPickerView.defaultRoute)
        NavigationCenter.shared.registerPushableView(VoidInitStringResultPickerView.self, for: VoidInitStringResultPickerView.defaultRoute)
    }()

    init() {
        _ = Self.register
    }

    // MARK: - Push With Result Route

    @Test("push 未注册路由触发 failRoute")
    func testPushUnregisteredRouteFails() {        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        nonisolated(unsafe) var received: ViewResult<String>?
        let route = ResultViewRoute<String, String>("UnregisteredRoute")
        let routeData = ResultableRouteData<String, String>("init") { result in
            received = result
        }
        navStack.push(route.wrapper(routeData))

        guard case .failed = received else {
            Issue.record("Expected .failed, got \(String(describing: received))")
            return
        }
        #expect(navStack.arrPaths.count == 0)

        ViewTest.releaseHost(host)
    }

    @Test("push 基于不存在的路由触发 failRoute")
    func testPushBaseOnNotFoundFails() {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        nonisolated(unsafe) var received: ViewResult<String>?
        let routeData = ResultableRouteData<String, String>("init") { result in
            received = result
        }
        let unregisteredBaseRoute = ViewRoute<String>("NonExistentBase").eraseToAnyRoute()
        navStack.push(ResultPickerView.defaultRoute.wrapper(routeData), baseOn: unregisteredBaseRoute)

        guard case .failed = received else {
            Issue.record("Expected .failed, got \(String(describing: received))")
            return
        }
        #expect(navStack.arrPaths.count == 0)

        ViewTest.releaseHost(host)
    }

    // MARK: - Push 成功 + 退出清除 → cancelRoute

    @Test("push 成功后 finishRoute 返回结果")
    func testPushSuccessThenFinish() {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        nonisolated(unsafe) var received: ViewResult<String>?
        let routeData = ResultableRouteData<String, String>("init") { result in
            received = result
        }
        navStack.push(ResultPickerView.defaultRoute.wrapper(routeData))
        ViewTest.refreshHost(host)

        #expect(navStack.arrPaths.count == 1)
        #expect(received == nil)

        routeData.finishRoute("picked")
        #expect(received == .finished("picked"))

        // pop 后 cancelRoute 不影响已 finish 的结果
        navStack.pop()
        ViewTest.refreshHost(host)
        #expect(navStack.arrPaths.count == 0)
        #expect(received == .finished("picked"))

        ViewTest.releaseHost(host)
    }

    @Test("pop 触发 cancelRoute")
    func testPopTriggersCancelRoute() {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        nonisolated(unsafe) var received: ViewResult<String>?
        let routeData = ResultableRouteData<String, String>("init") { result in
            received = result
        }
        navStack.push(ResultPickerView.defaultRoute.wrapper(routeData))
        ViewTest.refreshHost(host)

        #expect(navStack.arrPaths.count == 1)
        #expect(received == nil)

        navStack.pop()
        ViewTest.refreshHost(host)

        #expect(received == .cancelled)
        #expect(navStack.arrPaths.count == 0)

        ViewTest.releaseHost(host)
    }

    @Test("popToRoot 触发所有 page 的 cancelRoute")
    func testPopToRootTriggersCancelRoute() {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        nonisolated(unsafe) var received1: ViewResult<String>?
        nonisolated(unsafe) var received2: ViewResult<String>?
        let routeData1 = ResultableRouteData<String, String>("init1") { result in
            received1 = result
        }
        let routeData2 = ResultableRouteData<String, String>("init2") { result in
            received2 = result
        }
        navStack.push(ResultPickerView.defaultRoute.wrapper(routeData1))
        navStack.push(ResultPickerView.defaultRoute.wrapper(routeData2))
        ViewTest.refreshHost(host)

        #expect(navStack.arrPaths.count == 2)
        #expect(received1 == nil)
        #expect(received2 == nil)

        navStack.popToRoot()
        ViewTest.refreshHost(host)

        #expect(received1 == .cancelled)
        #expect(received2 == .cancelled)
        #expect(navStack.arrPaths.count == 0)

        ViewTest.releaseHost(host)
    }

    @Test("remove 触发 cancelRoute")
    func testRemoveTriggersCancelRoute() {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        nonisolated(unsafe) var received: ViewResult<String>?
        let routeData = ResultableRouteData<String, String>("init") { result in
            received = result
        }
        navStack.push(ResultPickerView.defaultRoute.wrapper(routeData))
        ViewTest.refreshHost(host)

        #expect(navStack.arrPaths.count == 1)
        #expect(received == nil)

        navStack.remove(with: ResultPickerView.defaultRoute.eraseToAnyRoute())
        ViewTest.refreshHost(host)

        #expect(received == .cancelled)
        #expect(navStack.arrPaths.count == 0)

        ViewTest.releaseHost(host)
    }

    @Test("push baseOn 清除上方 page 触发 cancelRoute")
    func testPushBaseOnClearsAboveTriggersCancelRoute() {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        // push 第一个界面（base）
        nonisolated(unsafe) var receivedBase: ViewResult<String>?
        let routeDataBase = ResultableRouteData<String, String>("base") { result in
            receivedBase = result
        }
        navStack.push(ResultPickerView.defaultRoute.wrapper(routeDataBase))
        ViewTest.refreshHost(host)
        #expect(navStack.arrPaths.count == 1)
        #expect(receivedBase == nil)

        // push 第二个界面（mid，将被清除）
        nonisolated(unsafe) var receivedMid: ViewResult<String>?
        let routeDataMid = ResultableRouteData<String, String>("mid") { result in
            receivedMid = result
        }
        navStack.push(AnotherResultPickerView.defaultRoute.wrapper(routeDataMid))
        ViewTest.refreshHost(host)
        #expect(navStack.arrPaths.count == 2)

        // 基于 base 的 route push 第三个 → mid（AnotherResultPickerView）被清除 → cancelRoute
        nonisolated(unsafe) var receivedNew: ViewResult<String>?
        let routeDataNew = ResultableRouteData<String, String>("new") { result in
            receivedNew = result
        }
        navStack.push(AnotherResultPickerView.defaultRoute.wrapper(routeDataNew), baseOn: ResultPickerView.defaultRoute.eraseToAnyRoute())
        ViewTest.refreshHost(host)

        #expect(receivedMid == .cancelled)
        #expect(navStack.arrPaths.count == 2)
        #expect(receivedNew == nil)

        ViewTest.releaseHost(host)
    }

    // MARK: - Void ResultData

    @Test("push Void 参数界面成功后 finishRoute")
    func testPushVoidSuccessThenFinish() {        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        nonisolated(unsafe) var received: ViewResult<String>?
        let routeData = ResultableRouteData<Void, String>(Void()) { result in
            received = result
        }
        navStack.push(VoidInitStringResultPickerView.defaultRoute.wrapper(routeData))
        ViewTest.refreshHost(host)

        #expect(navStack.arrPaths.count == 1)

        routeData.finishRoute("void-result")
        #expect(received == .finished("void-result"))

        ViewTest.releaseHost(host)
    }

    // MARK: - Async Push With Result Route

    @Test("async push(route, data) 返回 finished")
    func testAsyncPushWithDataReturnsFinished() async throws {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        let task = Task<String, Error> {
            try await navStack.push(ResultPickerView.defaultRoute, "hello")
        }

        await Task.yield()
        await Task.yield()
        ViewTest.refreshHost(host)

        #expect(navStack.arrPaths.count == 1)

        let routeData = navStack.arrPaths[0].viewInitData as? ResultableRouteData<String, String>
        #expect(routeData != nil)

        routeData?.finishRoute("world")
        let result = try await task.value
        #expect(result == "world")

        ViewTest.releaseHost(host)
    }

    @Test("async push(route, data) pop 后抛 cancelled")
    func testAsyncPushWithDataThrowsCancelled() async throws {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        let task = Task<String, Error> {
            try await navStack.push(ResultPickerView.defaultRoute, "hello")
        }

        await Task.yield()
        await Task.yield()
        ViewTest.refreshHost(host)

        #expect(navStack.arrPaths.count == 1)

        navStack.pop()
        ViewTest.refreshHost(host)

        do {
            _ = try await task.value
            Issue.record("Expected cancelled")
        } catch {
            #expect(error as? ViewRouteError == .cancelled)
        }

        ViewTest.releaseHost(host)
    }

    @Test("async push 未注册路由抛 failed")
    func testAsyncPushUnregisteredRouteThrowsFailed() async throws {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        let unregisteredRoute = ResultViewRoute<String, String>("UnregisteredRoute")

        do {
            _ = try await navStack.push(unregisteredRoute, "hello")
            Issue.record("Expected failed")
        } catch {
            guard case .failed = error as? ViewRouteError else {
                Issue.record("Expected .failed, got \(error)")
                return
            }
        }

        ViewTest.releaseHost(host)
    }

    @Test("async push(route) void 参数返回 finished")
    func testAsyncPushVoidRouteReturnsFinished() async throws {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        let task = Task<String, Error> {
            try await navStack.push(VoidInitStringResultPickerView.defaultRoute)
        }

        await Task.yield()
        await Task.yield()
        ViewTest.refreshHost(host)

        #expect(navStack.arrPaths.count == 1)

        let routeData = navStack.arrPaths[0].viewInitData as? ResultableRouteData<Void, String>
        #expect(routeData != nil)

        routeData?.finishRoute("void-result")
        let result = try await task.value
        #expect(result == "void-result")

        ViewTest.releaseHost(host)
    }

    @Test("async push(route) void 参数 pop 后抛 cancelled")
    func testAsyncPushVoidRouteThrowsCancelled() async throws {
        let sceneId = SceneId.custom(#function)
        let shareStackId = SharedNavigationStackId(stackId: #function)
        let rootView = RootHostView().modifier(NavigationStackModifier(shared: shareStackId))

        RootHostView.s_navStack = nil
        let host = ViewTest.host(rootView.environment(\.sceneId, sceneId))

        guard let navStack = NavigationManager.sharedNavStack(on: sceneId, of: shareStackId) else {
            Issue.record("navStack not found")
            ViewTest.releaseHost(host)
            return
        }

        let task = Task<String, Error> {
            try await navStack.push(VoidInitStringResultPickerView.defaultRoute)
        }

        await Task.yield()
        await Task.yield()
        ViewTest.refreshHost(host)

        #expect(navStack.arrPaths.count == 1)

        navStack.pop()
        ViewTest.refreshHost(host)

        do {
            _ = try await task.value
            Issue.record("Expected cancelled")
        } catch {
            #expect(error as? ViewRouteError == .cancelled)
        }

        ViewTest.releaseHost(host)
    }
}

// MARK: - 测试用 View

/// 根界面，用于获取 navStack 引用
struct RootHostView: View {
    static var s_navStack: Store<NavigationState>? = nil
    @Environment(\.navStack) var navStack

    var body: some View {
        Text("Root")
            .onAppear {
                Self.s_navStack = navStack
            }
    }
}

// MARK: - 测试用 ResultableView

private struct ResultPickerView: PushableView, ResultableView {
    typealias InitParam = String
    typealias ResultData = String

    let routeData: ResultableRouteData<String, String>

    init(_ routeData: ResultableRouteData<String, String>) {
        self.routeData = routeData
    }

    var content: some View {
        Text("Picker")
    }
}

private struct VoidInitStringResultPickerView: PushableView, ResultableView {
    typealias InitParam = Void
    typealias ResultData = String

    let routeData: ResultableRouteData<Void, String>

    init(_ routeData: ResultableRouteData<Void, String>) {
        self.routeData = routeData
    }

    var content: some View {
        Text("Void Init Picker")
    }
}

private struct AnotherResultPickerView: PushableView, ResultableView {
    typealias InitParam = String
    typealias ResultData = String

    let routeData: ResultableRouteData<String, String>

    init(_ routeData: ResultableRouteData<String, String>) {
        self.routeData = routeData
    }

    var content: some View {
        Text("Another Picker")
    }
}
