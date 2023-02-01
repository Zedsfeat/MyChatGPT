//
//  ContentView.swift
//  ChatGPTSwiftUI
//
//  Created by zedsbook on 27.01.2023.
//

import OpenAISwift
import SwiftUI

final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: "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")
    }
    
    func send(text: String, completion: @escaping (String) -> Void) {
        print(text)
        client?.sendCompletion(with: text,
                               maxTokens: 500,
                               completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                print(output)
                completion(output)
            case .failure:
                break
            }
        })
    }
}

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    @State var messageText = ""
    @State var messages = [String]()
    
    var body: some View {
        
        VStack {
            // Title
            HStack {
                Text("ChatGPT")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.gray)
                
                Image("chatGPT")
                    .resizable()
                    .frame(width: 38, height: 38)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            //Messages
            ScrollView {
                ForEach(messages, id:  \.self) { message in
                    if message.contains("[USER]") {
                        let newMessage = message.replacingOccurrences(of: "[USER]", with: "")
                        
                        HStack {
                            Spacer()
                            Text(newMessage)
                                .padding()
                                .foregroundColor(.white)
                                .background(.blue.opacity(0.8))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                        }
                        
                    } else {
                        HStack {
                            Text(message)
                                .padding()
                                .background(.gray.opacity(0.15))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                            Spacer()
                        }
                    }
                }.rotationEffect(.degrees(180))
            }
            .rotationEffect(.degrees(180))
            .onAppear {
                viewModel.setup()
            }
            
            HStack {
                TextField("Type something", text: $messageText)
                    .padding(.leading, 10)
                    .font(.body)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .onSubmit {
                        sendMessage(messageText)
                    }
                Button {
                    sendMessage(messageText)
                } label: {
                    Image("send")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
        }
        
        
//        VStack(alignment: .leading) {
//            ForEach(messages, id: \.self) { string in
//                Text(string)
//            }
//
//            Spacer()
//
//            HStack {
//                TextField("Type here...", text: $messageText)
//                Button("send") {
//                    send()
//                }
//            }
//        }
//        .onAppear {
//            viewModel.setup()
//        }
//        .padding()
    }
    
    func sendMessage(_ message: String) {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        withAnimation {
            messages.append("[USER]" + message)
            self.messageText = ""
        }
        
        viewModel.send(text: messageText) { response in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    self.messages.append(response)
                }
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
