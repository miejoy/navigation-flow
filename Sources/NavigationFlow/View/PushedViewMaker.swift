//
//  PushedViewMaker.swift
//  
//
//  Created by 黄磊 on 2023/7/6.
//

import SwiftUI

struct PushedViewMaker {
    
    let run: (Any) -> AnyView
    
    init<V: PushableView>(_ pushableViewType: V.Type) {
        self.run = { data -> AnyView in
            if let data = data as? V.InitData {
                return AnyView(V(data))
            }
            // 这里需要记录异常
            NavigationMonitor.shared.fatalError("Make pushable view '\(String(describing: V.self))' failed. Convert to initialization data of '\(String(describing: V.InitData.self))' failed")
            return AnyView(EmptyView())
        }
    }
    
    init<V: PushableView>(_ pushableViewType: V.Type) where V.InitData == Void  {
        self.run = { data -> AnyView in
            return AnyView(V(Void()))
        }
    }
    
    func makeView(_ data: Any) -> AnyView {
        return run(data)
    }
}
