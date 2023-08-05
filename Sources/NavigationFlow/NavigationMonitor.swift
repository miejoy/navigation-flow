//
//  NavigationMonitor.swift
//  
//
//  Created by 黄磊 on 2023/7/5.
//

import Foundation
import Combine
import ViewFlow

/// 存储器变化事件
public enum NavigationEvent {
    case pushFailedNotRegister(AnyViewRoute)
    case pushFailedBaseOnRouteNotFound(AnyViewRoute)
    case popFailedTargetRouteNotFound(AnyViewRoute)
    case removeFailedTargetRouteNotFound(AnyViewRoute)
    case fatalError(String)
}

public protocol NavigationMonitorOberver: AnyObject {
    func receiveNavigationEvent(_ event: NavigationEvent)
}

/// 存储器监听器
public final class NavigationMonitor {
        
    struct Observer {
        let observerId: Int
        weak var observer: NavigationMonitorOberver?
    }
    
    /// 监听器共享单例
    public static var shared: NavigationMonitor = .init()
    
    /// 所有观察者
    var arrObservers: [Observer] = []
    var generateObserverId: Int = 0
    
    required init() {
    }
    
    /// 添加观察者
    public func addObserver(_ observer: NavigationMonitorOberver) -> AnyCancellable {
        generateObserverId += 1
        let observerId = generateObserverId
        arrObservers.append(.init(observerId: generateObserverId, observer: observer))
        return AnyCancellable { [weak self] in
            if let index = self?.arrObservers.firstIndex(where: { $0.observerId == observerId}) {
                self?.arrObservers.remove(at: index)
            }
        }
    }
    
    /// 记录对应事件，这里只负责将所有事件传递给观察者
    @usableFromInline
    func record(event: NavigationEvent) {
        guard !arrObservers.isEmpty else { return }
        arrObservers.forEach { $0.observer?.receiveNavigationEvent(event) }
    }
    
    @usableFromInline
    func fatalError(_ message: String) {
        guard !arrObservers.isEmpty else {
            #if DEBUG
            Swift.fatalError(message)
            #else
            return
            #endif
        }
        arrObservers.forEach { $0.observer?.receiveNavigationEvent(.fatalError(message)) }
    }
}
