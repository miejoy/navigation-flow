//
//  NavigationStackId.swift
//  
//
//  Created by 黄磊 on 2023/7/26.
//

import Foundation


public protocol NavigationStackId: CustomStringConvertible {
    var stackId: String { get }
}

public extension NavigationStackId {
    var description: String {
        stackId
    }
}

struct NormalNavigationStackId: NavigationStackId {
    var stackId: String
}

public struct SharedNavigationStackId: NavigationStackId {
    public var stackId: String
    public init(stackId: String) {
        self.stackId = stackId
    }
}

extension SharedNavigationStackId {
    public static var main = SharedNavigationStackId(stackId: "Main")
}
