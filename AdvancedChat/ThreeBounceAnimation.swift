//
//  ThreeBounceAnimation.swift
//  AdvancedChat
//
//  Created by Saheem Hussain on 15/11/23.
//

import SwiftUI

enum LineDot {
    case line
    case dot
}
struct ThreeBounceAnimation: View {

    @State var scales: [CGFloat] = DATA.map { _ in return 0 }

    var animation = Animation.easeInOut.speed(0.5)
    var lineDot: LineDot

    var body: some View {
        
        HStack {
            switch lineDot {
            case .dot:
                DotView(scale: .constant(scales[0]))
                DotView(scale: .constant(scales[1]))
                DotView(scale: .constant(scales[2]))
                
            case .line:
                LineView(scale: .constant(scales[0]))
                LineView(scale: .constant(scales[1]))
                LineView(scale: .constant(scales[2]))
            }
            
        }
        .onAppear {
            animateDots() // Not defined yet
        }
    }
    
    func animateDots() {

        for (index, data) in DATA.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + data.delay) {
                animateDot(binding: $scales[index], animationData: data)
            }
        }

        //Repeat
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            animateDots()
        }
    }

    func animateDot(binding: Binding<CGFloat>, animationData: AnimationData) {
        withAnimation(animation) {
            binding.wrappedValue = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(animation) {
                binding.wrappedValue = 0.2
            }
        }
    }
}

struct ThreeBounceAnimation_Previews: PreviewProvider {
    static var previews: some View {
        ThreeBounceAnimation(lineDot: .line)
    }
}
