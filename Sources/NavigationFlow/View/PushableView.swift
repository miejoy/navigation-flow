//
//  PushableView.swift
//  
//
//  Created by 黄磊 on 2023/7/4.
//

import ViewFlow
import SwiftUI

/// 可用于 Push 的界面
public protocol PushableView: RoutableView {
}

public protocol VoidPushableView: PushableView, VoidInitializableView {
}
