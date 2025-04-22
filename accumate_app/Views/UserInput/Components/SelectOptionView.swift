//
//  SignUpBrokerageView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

struct SelectOptionView: View {
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var title: String? // Select Brokerage
    var subtitle: String?
    var signUpField: SignUpFields
    @Binding var alertMessage: String
    @Binding var showAlert: Bool
    @Binding var buttonDisabled: Bool
    @Binding var selectedBrokerage: String
    @Binding var selectedETF: String
    @Binding var otherSelected: Bool
    @Binding var customField: String
    @Binding var customFieldError: String
    @State var isSecure: Bool
    @FocusState var focusedField: Int?
    
    init(
        title: String? = nil,
        subtitle: String? = nil,
        signUpField: SignUpFields,
        alertMessage: Binding<String>,
        showAlert: Binding<Bool>,
        buttonDisabled: Binding<Bool>,
        selectedBrokerage: Binding<String>,
        selectedETF: Binding<String>,
        otherSelected: Binding<Bool>,
        customField: Binding<String>,
        customFieldError: Binding<String>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.signUpField = signUpField
        self._alertMessage = alertMessage
        self._showAlert = showAlert
        self._buttonDisabled = buttonDisabled
        self._selectedBrokerage = selectedBrokerage
        self._selectedETF = selectedETF
        self._otherSelected = otherSelected
        self._customField = customField
        self._customFieldError = customFieldError
        self._showAlert = showAlert
        self.isSecure = signUpField == .password || signUpField == .password2
    }

    var body: some View {
        ZStack {
            ZStack {
                VStack {
                    VStack (alignment: .leading, spacing: 10) {
                        if let title = title {
                            Text(title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    //            .padding(.bottom, 25)
                    
                    if signUpField == .brokerage {
                        ScrollView {
                            ForEach(Brokerages.allCases, id: \.self) { brokerage in
                                BrokerageButtonView(
                                    brokerage: brokerage,
                                    buttonDisabled: $buttonDisabled,
                                    selectedBrokerage: $selectedBrokerage,
                                    alertMessage: $alertMessage,
                                    showAlert: $showAlert
                                )
                            }
                            Button {
                                otherSelected = true
                            } label: {
                                VStack {
                                    HStack {
                                        Image(systemName: "plus")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .padding(.leading, 30)
                                            .foregroundColor(.white)
                                        Text("Connect another broker")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    .frame(height: 80)
                                    .disabled(buttonDisabled)
                                    .background(.black)
                                    Divider()
                                        .frame(height: 1.5)
                                        .frame(maxWidth: .infinity)
                                        .background(.white.opacity(0.6))
                                }
                                .frame(height: 80)
                            }
                        }
                    } else if signUpField == .symbol {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(Array(etfsList.enumerated()), id: \.0) { index, etf in
                                    SignUpETFsButtonView(
                                        imageName: etf.imageName,
                                        title: etf.name,
                                        subtitle: etf.timePeriod,
                                        growth: etf.growth,
                                        etf: etf,
                                        buttonDisabled: $buttonDisabled,
                                        selectedETF: $selectedETF
                                    )
                                }
                                Button {
                                    otherSelected = true
                                } label: {
                                    VStack {
                                        HStack {
                                            Image(systemName: "plus")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .padding(.leading, 30)
                                                .foregroundColor(.white)
                                            Text("Select another investment")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                        .frame(height: 80)
                                        .disabled(buttonDisabled)
                                        .background(.black)
                                        Divider()
                                            .frame(height: 1.5)
                                            .frame(maxWidth: .infinity)
                                            .background(.white.opacity(0.6))
                                    }
                                    .frame(height: 80)
                                }
                            }
                            .padding(.top, 10)
                        }
                        .background(.black)
                    } else {
                        EmptyView()
                    }
                    
                    Spacer()
                }
                Color(otherSelected ? .black.opacity(0.6) : .clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            HStack {
                Spacer()
                if otherSelected {
                    VStack (alignment: .leading) {
                        Spacer()
                        Text("Request a custom \(signUpField == .symbol ? "security" : "brokerage").")
                            .foregroundColor(.white.opacity(0.9))
                            .font(.system(size: 18))
                            .background(.black)
                            .cornerRadius(10)
                        CustomTextField(
                            inputValue: $customField,
                            placeholder: signUpField == .symbol ? "AAPL" : "J. P. Morgan",
                            keyboard: .default,
                            isSecure: $isSecure,
                            focusedField: $focusedField,
                            index: -1
                        )
                        Text(customFieldError)
                            .foregroundColor(.red)
                            .font(.system(size: 18))
                            .background(.black)
                            .cornerRadius(10)
                            .opacity(customFieldError != "" ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5), value: customFieldError)
                        HStack (spacing: 10) {
                            Button {
                                otherSelected = false
                            } label: {
                                Text("Dismiss")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 45)
                                    .background(.white.opacity(0.6))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.gray.opacity(0.6), lineWidth: 2)
                                    )
                            }
                            Button {
                                if signUpField == .brokerage {
                                    if customField == "" {
                                        customFieldError = "Please enter a value."
                                    } else {
                                        print("otherStart", otherSelected)
                                        customFieldError = ""
                                        showAlert = true
                                        alertMessage = "We can save this selection as your brokerage, but we are not yet able to connect with it. Do you want to select it anyways?"
                                        print("otherStart2", otherSelected)
                                    }
                                } else {
                                    if customField == "" {
                                        customFieldError = "Please enter a value."
                                    } else {
                                        customFieldError = ""
                                        buttonDisabled = true
                                    }
                                }
                            } label: {
                                Text("Select")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 45)
                                    .background(.white.opacity(0.6))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.gray.opacity(0.6), lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding()
                    .background(.black)
                    .cornerRadius(10)
                    Spacer()
                }
                Spacer()
            }
            .frame(width: 320, height: 150)
        }
        .alert(alertMessage, isPresented: $showAlert) {
            
            if (customField != "" && otherSelected) || (selectedBrokerage != "" && selectedBrokerage != Brokerages.robinhood.rawValue) {
                Button("No", role: .cancel) {
                    showAlert = false
                }
                Button("Select", role: .none) {
                    print("otherSelect", otherSelected)
                    showAlert = false
                    buttonDisabled = true
                }
            } else if sessionManager.refreshFailed {
                Button("OK", role: .cancel) {
                    showAlert = false
                }
                Button("Log Out", role: .destructive) {
                    Task {
                        showAlert = false
                        
                        sessionManager.refreshFailed = false
                        _ = await sessionManager.resetComplete()
                        navManager.reset(views: [.landing])
                    }
                }
            } else {
                Button("OK", role: .cancel) {
                    showAlert = false
                }
            }
        }
        .onAppear {
            print(selectedETF)
            buttonDisabled = false
        }
        .background(.black)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    Utils.dismissKeyboard()
                }
                .foregroundColor(.blue)
            }
        }
    }
}
