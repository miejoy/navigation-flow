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

/// 普通导航堆栈ID，这种都是临时使用的，如果希望在多个界面调用，需要用 SharedNavigationStackId
public struct NormalNavigationStackId: NavigationStackId, ExpressibleByStringLiteral {
    public var stackId: String
    public init(stackId: String = UUID().uuidString) {
        self.stackId = stackId
    }
    
    public init(stringLiteral value: String) {
        self.stackId = value
    }
}

/// 共享导航堆栈ID，通过这个ID获取的导航堆栈是共享的
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
