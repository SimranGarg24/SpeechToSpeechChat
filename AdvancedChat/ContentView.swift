//
//  ContentView.swift
//  AdvancedChat
//
//  Created by Saheem Hussain on 15/11/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var vm = ContentViewModel()
    @StateObject var speechRecognizer = SpeechRecognizer()
    
    @State private var isSpeaking = false
    
    var body: some View {
        
        VStack {
            
            Text("AI Speech-to-Speech Demo")
                .font(.title)
                .padding()
            
            Spacer()
            
            
            VStack {
                Image(systemName: "mic")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .padding()
                
                Text(isSpeaking ? "Speaking..." : "Tap and Hold")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .frame(width: 250, height: 250)
            .background(.blue)
            .clipShape(Circle())
            .scaleEffect(isSpeaking ? 1.5 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.6))
            .gesture(!vm.apiLoading && !vm.sysSpeaking ?
                     DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    print("tapping")
                    if !self.isSpeaking {
                        speechRecognizer.resetTranscript()
                        speechRecognizer.startTranscribing()
                        self.isSpeaking = true
                    }
                }
                .onEnded { _ in
                    print("end")
                    self.isSpeaking = false
                    vm.apiLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        vm.text = speechRecognizer.transcript
                        speechRecognizer.stopTranscribing()
                        vm.sendMessage()
                    }
                }
                     : nil
            )
            .onChange(of: speechRecognizer.transcript, perform: { _ in
                print(speechRecognizer.transcript)
            })
            
            
            Spacer()
            
            VStack {
                if vm.apiLoading {
                    ThreeBounceAnimation(lineDot: .dot)
                }
                
                if vm.sysSpeaking {
                    ThreeBounceAnimation(lineDot: .line)
                }
            }
            .frame(height: 100)
        }
        .padding()
        .alert(vm.error ?? "", isPresented: $vm.isPresented) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            speechRecognizer.resetTranscript()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
