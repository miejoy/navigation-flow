//
//  NavigationMonitor.swift
//  
//
//  Created by 黄磊 on 2023/7/5.
//

import Foundation
import Combine
import ViewFlow
import ModuleMonitor

/// 导航相关事件
public enum NavigationEvent: MonitorEvent, Sendable {
    case pushFailedNotRegister(AnyViewRoute)
    case pushFailedBaseOnRouteNotFound(AnyViewRoute)
    case popFailedTargetRouteNotFound(AnyViewRoute)
    case removeFailedTargetRouteNotFound(AnyViewRoute)
    case fatalError(String)
}

/// 导航监视器观察者
public protocol NavigationMonitorObserver: MonitorObserver {
    @MainActor
    func receiveNavigationEvent(_ event: NavigationEvent)
}

/// 导航监视器
public final class NavigationMonitor: ModuleMonitor<NavigationEvent> {
    public nonisolated(unsafe) static let shared: NavigationMonitor = {
        NavigationMonitor { event, observer in
            DispatchQueue.executeOnMain {
                (observer as? NavigationMonitorObserver)?.receiveNavigationEvent(event)
            }
        }
    }()

    public func addObserver(_ observer: NavigationMonitorObserver) -> AnyCancellable {
        super.addObserver(observer)
    }

    public override func addObserver(_ observer: MonitorObserver) -> AnyCancellable {
        Swift.fatalError("Only NavigationMonitorObserver can observer this monitor")
    }
}
