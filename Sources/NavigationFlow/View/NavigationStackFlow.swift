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
    @ViewState var navState: NavigationState
    
    @Environment(\.sceneId) var sceneId
    @Environment(\.viewPath) var viewPath
    @Environment(\.navManager) var navManager
        
    @ViewBuilder var content: Content
    
    @inlinable
    public init(@ViewBuilder content: () -> Content) {
        self.init(NormalNavigationStackId(), content: content)
    }
    
    public init(_ navStackId: NormalNavigationStackId, @ViewBuilder content: () -> Content) {
        self.init(stackId: navStackId, content: content)
    }
    
    public init(shared navStackId: SharedNavigationStackId, @ViewBuilder content: () -> Content) {
        self.init(stackId: navStackId, content: content)
    }
    
    init(stackId: NavigationStackId, @ViewBuilder content: () -> Content) {
        self._navState = .init(wrappedValue: .init(stackId))
        self.content = content()
    }
    
    public var body: some View {
        NavigationView {
            NavigationStack(path: $navState.arrPaths) {
                content
                    .navigationDestination(for: NavigationPage.self) { page in
                        $navState.makePushView(of: page, on: sceneId)
                            .environment(\.navStack, $navState)
                    }
            }
            .environment(\.navStack, $navState)
            .onAppear {
                navManager.addNavStack($navState, at: viewPath)
                // 暂时不需要 remove
            }
        }
    }
}
