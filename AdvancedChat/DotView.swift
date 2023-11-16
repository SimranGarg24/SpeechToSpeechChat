//
//  DotView.swift
//  AdvancedChat
//
//  Created by Saheem Hussain on 15/11/23.
//

import SwiftUI

struct AnimationData {
    var delay: TimeInterval
}

let DATA = [
    AnimationData(delay: 0.0),
    AnimationData(delay: 0.2),
    AnimationData(delay: 0.4),
]

struct DotView: View {
    @Binding var scale: CGFloat
    
    var body: some View {
        Circle()
            .scale(scale)
            .fill(.blue.opacity(scale >= 0.7 ? scale : scale - 0.1))
            .frame(width: 18, height: 18, alignment: .leading)
    }
}

struct DotView_Previews: PreviewProvider {
    static var previews: some View {
        DotView(scale: Binding.constant(10))
    }
}
