//
//  ContentViewModel.swift
//  AdvancedChat
//
//  Created by Saheem Hussain on 15/11/23.
//

import Foundation
import OpenAI
import AVFoundation

class ContentViewModel: NSObject, ObservableObject {
    
    @Published var apiLoading: Bool = false
    @Published var error: String?
    @Published var isPresented: Bool = false
    @Published var sysSpeaking: Bool = false
    
    let openAI = OpenAIManager.shared
    let synthesizer = AVSpeechSynthesizer()
    var messages = [Chat(role: .system, content: "Hello!! I am your personal chat assistant. How may I help you?")]
    var text = ""
    var first = true
    
    var wordsArray: [String] = []
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func sendMessage() {
        
        if !text.isEmpty {
            apiLoading = true
            error = nil
            isPresented = false
            messages.append(Chat(role: .user, content: self.text))
            chat()
        } else {
            apiLoading = false
            isPresented = true
            error = "Please speak again."
        }
    }
    
    //api call
    func chat() {
        
        // Because the models have no memory of past requests, all relevant information must be supplied as part of the conversation history in each request. If a conversation cannot fit within the model’s token limit, it will need to be shortened in some way(such as keep the summarized conversation in request)
        
        // To mimic the effect seen in ChatGPT where the text is returned iteratively, set the stream parameter to true.
        
        let query = ChatQuery(model: .gpt3_5Turbo,
                              messages: messages,
                              temperature: 0,
                              topP: 1,
                              stop: ["\\n"],
                              presencePenalty: 0,
                              frequencyPenalty: 0,
                              stream: false) //false if not stream
        
        
        self.text = String()
        self.wordsArray = []
        first = true
        sysSpeaking = false
        chats(query: query)
//        chatStream(query: query)
    }
    
    // if you want to show full response at once
    func chats(query: ChatQuery) {
        
        openAI.chats(query: query) { result, error in
            //Handle result here
            DispatchQueue.main.async {
                self.apiLoading = false
                
                if let result {
                    self.messages.append(Chat(role: .assistant, content: result.choices[0].message.content))
                    if let response = result.choices[0].message.content {
                        self.sysSpeaking = true
                        self.speakText(response)
                    }
                } else if let error {
                    self.isPresented = true
                    self.error = error.localizedDescription
                }
            }
        }
    }
    
    //if you want to shpw response word by word as chatgpt shows
    func chatStream(query: ChatQuery) {
        
        openAI.chatsStream(query: query) { result, error in
            
            DispatchQueue.main.async {
                
                if let result {
                    
                    if let content = result.choices[0].delta.content {
                        
                        self.wordsArray.append(content)
                            // if self.wordsArray.count >= 3 {
                        self.speakText(content)
                            //}
                    }
                    
                } else if let error {
                    
                    self.wordsArray = []
                    self.isPresented = true
                    self.error = error.localizedDescription
                }
            }
            
        } onCompletion: { error in
            
            DispatchQueue.main.async {
                if let error {
                    
                    print(error)
                    self.apiLoading = false
                    self.isPresented = true
                    self.error = error.localizedDescription
                    
                } else {
                    
                    self.apiLoading = false
                    self.messages.append(Chat(role: .assistant, content: self.wordsArray.joined()))
                }
            }
        }
    }
    
    func speakText(_ text: String) {
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
        
        // if wordsArray.count >= 3 {
        //   let ind = wordsArray.count
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-IN")
        utterance.rate = 0.5
        
        self.synthesizer.speak(utterance)
        
        // Remove the spoken chunk from the queue
        //   wordsArray.removeFirst(ind)
        // }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension ContentViewModel: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // This method is called when the synthesizer finishes speaking an utterance
        // You can handle any post-speaking logic here
        self.sysSpeaking = false
    }
}
