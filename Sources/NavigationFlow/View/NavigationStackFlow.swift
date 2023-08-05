//
//  NavigationStackFlow.swift
//  
//
//  Created by 黄磊 on 2023/7/2.
//

import SwiftUI
import DataFlow
import ViewFlow

/// 导航栈包装界面
public struct NavigationStackFlow<Content: View>: View {
    @StateObject var navStack: Store<NavigationState>
    
    @Environment(\.sceneId) var sceneId
    @Environment(\.viewPath) var viewPath
    @Environment(\.navManager) var navManager
    @Environment(\.navStack) var prevNavStack
        
    @ViewBuilder var content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self._navStack = .init(wrappedValue: .box(.init(NormalNavigationStackId(stackId: UUID().uuidString))))
        self.content = content()
    }
    
    public init(_ navStackId: NavigationStackId, @ViewBuilder content: () -> Content) {
        self._navStack = .init(wrappedValue: .box(.init(navStackId)))
        self.content = content()
    }
    
    public init(shared navStackId: SharedNavigationStackId, @ViewBuilder content: () -> Content) {
        self._navStack = .init(wrappedValue: .box(.init(navStackId)))
        self.content = content()
    }
    
    public var body: some View {
        print("update")
        return NavigationView {
            NavigationStack(path: $navStack.arrPaths) {
                content
                    .navigationDestination(for: NavigationPage.self) { page in
                        navStack.makePushView(of: page, on: sceneId)
                    }
            }
            .environment(\.navStack, navStack)
            .onAppear {
                if let prevNavStack = prevNavStack {
                    NavigationMonitor.shared.fatalError("NavigationStack[\(navStack.stackId)] nested in NavigationStack[\(prevNavStack.stackId)]. This is not supported by now")
                }
                navManager.addNavStack(navStack, at: viewPath)
                // 暂时不需要 remove
            }
        }
    }
}
