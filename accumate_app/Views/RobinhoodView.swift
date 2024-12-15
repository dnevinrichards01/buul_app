//
//  RobinhoodView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

struct RobinhoodView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var password2: String = ""
    
    private var fieldBindings: [RobinhoodFields: Binding<String>] {
        [
            .username: $username,
            .password: $password,
            .password2: $password2
        ]
    }
    
    @FocusState private var focusedField: Int?
    
    @EnvironmentObject var navManager: NavigationPathManager
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Image("RobinhoodLogo")
                            .resizable()
                            .frame(width: 150, height: 150)
                        ForEach(RobinhoodFields.allCases.indices, id: \.self) { index in
                            let option = RobinhoodFields.allCases[index]
                            if let binding = fieldBindings[option] {
                                SignUpFieldView(
                                    instruction: option.instruction,
                                    placeholder: option.placeholder,
                                    inputValue: binding,
                                    keyboard: option.keyboardType
                                )
                                .focused($focusedField, equals: index)
                                .id(index)
                            }
                            Spacer().frame(height: 20)
                        }
                        
                        Button {
                            navManager.path.append(NavigationPathViews.etf)
                        } label: {
                            Text("Connect")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color(red: 75/255, green: 135/255, blue: 120/255))
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                        Button {
                            
                        } label: {
                            Text("Sign up for Robinhood")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(.black)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.gray.opacity(0.4), lineWidth: 2)
                                )
                        }
                        .padding(.top, 10)
                        
                        Spacer()
                        
                        if focusedField != nil {
                            Color.clear
                                .frame(height: geometry.size.height * 0.8)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height, maxHeight: .infinity)
                }
                .onChange(of: focusedField) { oldFocusedField, newFocusedField in
                    if let newFocusedField = newFocusedField {
                        scrollToField(
                            id: newFocusedField,
                            scrollProxy: scrollProxy
                        )
                    }
                }
                .background(Color.black.ignoresSafeArea())
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            navManager.path.removeLast()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .medium))
                                .frame(maxHeight: 30)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Connect to Robinhood")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .semibold))
                            .frame(maxHeight: 30)
                    }
                    ToolbarItemGroup(placement: .keyboard) {
                        Button {
                            if let focusedField {
                                scrollToField(
                                    id: max(focusedField - 1, 0),
                                    scrollProxy: scrollProxy
                                )
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                        }
                        Button {
                            if let focusedField {
                                scrollToField(
                                    id: min(focusedField + 1, fieldBindings.count - 1),
                                    scrollProxy: scrollProxy
                                )
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        Button("Done") {
                            dismissKeyboard()
                        }
                        .foregroundColor(.blue) // Customize the button appearance
                    }
                }
            }
        }
    }
    
    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func scrollToField(id: Int, scrollProxy: ScrollViewProxy) {
        focusedField = id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2)) {
                scrollProxy.scrollTo(id, anchor: .center)
            }
        }
    }
}

#Preview {
    RobinhoodView()
        .environmentObject(NavigationPathManager())
}
