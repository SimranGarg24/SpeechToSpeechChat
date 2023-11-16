//
//  LineView.swift
//  AdvancedChat
//
//  Created by Saheem Hussain on 15/11/23.
//

import SwiftUI

struct LineView: View {
    @Binding var scale: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .scale(scale)
            .fill(.blue.opacity(scale >= 0.7 ? scale : scale - 0.1))
            .frame(width: 6, height: 42, alignment: .leading)
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(scale: Binding.constant(10))
    }
}
