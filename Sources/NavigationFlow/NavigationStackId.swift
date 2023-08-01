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
}

extension NavigationStackId {
    public static var anyId: NavigationStackId {
        NormalNavigationStackId(stackId: UUID().uuidString)
    }
}

extension SharedNavigationStackId {
    static var main = SharedNavigationStackId(stackId: "Main")
}
