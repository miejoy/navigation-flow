//
//  NavigationTitleModifier.swift
//  
//
//  Created by 黄磊 on 2023/8/18.
//

import SwiftUI

/// 导航标题修改器
public struct NavigationTitleModifier: ViewModifier {
    @Environment(\.suggestNavTitle) var suggestNavTitle
    var navTitle: String? = nil
    
    public init(_ navTitle: String? = nil) {
        self.navTitle = navTitle
    }
    
    public func body(content: Content) -> some View {
        content.navigationTitle(navTitle ?? suggestNavTitle ?? "")
    }
}
