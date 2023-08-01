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
    @State
    var navStackId: NavigationStackId
    
    @StateObject var navStack: Store<NavigationState> = .init()
    
    @Environment(\.sceneId) var sceneId
    @Environment(\.viewPath) var viewPath
    @Environment(\.navManager) var navManager
        
    @ViewBuilder var content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self._navStackId = .init(wrappedValue: NormalNavigationStackId(stackId: UUID().uuidString))
        self.content = content()
    }
    
    public init(_ navStackId: NavigationStackId, @ViewBuilder content: () -> Content) {
        self._navStackId = .init(wrappedValue: navStackId)
        self.content = content()
    }
    
    public init(shared navStackId: SharedNavigationStackId, @ViewBuilder content: () -> Content) {
        self._navStackId = .init(wrappedValue: navStackId)
        self.content = content()
    }
    
    public var body: some View {
        NavigationStack(path: navStack.arrPaths) {
            content
                .navigationDestination(for: NavigationPage.self) { page in
                    navStack.makePushView(of: page, on: sceneId)
                }
                .environment(\.navStack, navStack)
        }
        .onAppear {
            navManager.addNavStack(navStack, with: navStackId, at: viewPath)
            // 暂时不需要 remove
        }
    }
}
