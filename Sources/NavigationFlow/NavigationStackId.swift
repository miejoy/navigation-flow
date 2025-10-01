//
//  NavigationStackId.swift
//  
//
//  Created by 黄磊 on 2023/7/26.
//

import Foundation

/// 导航堆栈ID
public protocol NavigationStackId: CustomStringConvertible {
    var stackId: String { get }
}

public extension NavigationStackId {
    var description: String {
        stackId
    }
}

/// 普通导航堆栈ID
struct NormalNavigationStackId: NavigationStackId {
    var stackId: String
}

/// 共享导航堆栈ID
public struct SharedNavigationStackId: NavigationStackId {
    public var stackId: String
    public init(stackId: String) {
        self.stackId = stackId
    }
}

extension SharedNavigationStackId {
    /// 主共享导航堆栈ID
    public static var main = SharedNavigationStackId(stackId: "Main")
}
