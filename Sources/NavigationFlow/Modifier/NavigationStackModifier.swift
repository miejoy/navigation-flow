//
//  NavigationStackModifier.swift
//  
//
//  Created by 黄磊 on 2023/7/2.
//

import SwiftUI

/// 展示修改器
public struct NavigationStackModifier: ViewModifier {
    var stackId: NavigationStackId
    
    public init(_ stackId: String = UUID().uuidString) {
        self.stackId = NormalNavigationStackId(stackId: stackId)
    }
    
    public init(shared: SharedNavigationStackId) {
        self.stackId = shared
    }
    
    public func body(content: Content) -> some View {
        NavigationStackFlow(stackId) {
            content
        }
    }
}
