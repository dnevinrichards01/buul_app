//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    @FocusState private var focusedField: Int?
    @State private var isKeyboardVisible = false
    
    private var fieldBindings: [SignUpField: Binding<String>] {
        [
            .username: $username,
            .password: $password,
        ]
    }
    
    @EnvironmentObject var navManager : NavigationPathManager
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) { 
                        ForEach(SignUpField.allCases.indices, id: \.self) { index in
                            let option = SignUpField.allCases[index]
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
                        
                        // Continue Button
                        Button {
                            navManager.path.append("HomeView")
                        } label: {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                        if focusedField != nil {
                            Color.clear
                                .frame(height: geometry.size.height * 0.8)
                        }
                    }
                    .padding()
                    .frame(minHeight: geometry.size.height)
                    
                }
                .onChange(of: focusedField) { oldValue, newValue in
                    if let newValue = newValue {
                        scrollToField(
                            id: newValue,
                            scrollProxy: scrollProxy
                        )
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .all)
                .background(Color.black.ignoresSafeArea())
                .navigationBarBackButtonHidden(true)
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
                        Text("Login")
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
                .navigationDestination(for: String.self) { value in
                    HomeView()
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

struct HomeView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    var body: some View {
        Text("Hellooooo")
    }
}


#Preview {
    LoginView()
}
