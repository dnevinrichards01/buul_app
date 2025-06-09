//
//  accumate_appApp.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/2/24.
//

import SwiftUI

@main
struct Buul: App {
    @StateObject var navManager = NavigationPathManager()
    @StateObject var sessionManager = UserSessionManager()
    @StateObject var plaidManager = PlaidLinkManager()
    
    init() {
        initToolbarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            LoadingScreen()
                .environmentObject(navManager)
                .environmentObject(sessionManager)
                .environmentObject(plaidManager)
        }
    }
    
    func initToolbarAppearance() {
        // Configure appearance for the navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.black
        // Apply appearance to the navigation bar
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithOpaqueBackground()
        toolbarAppearance.backgroundColor = .black
        toolbarAppearance.shadowColor = nil
        UIToolbar.appearance().standardAppearance = toolbarAppearance
        UIToolbar.appearance().compactAppearance = toolbarAppearance
        UIToolbar.appearance().scrollEdgeAppearance = toolbarAppearance
    }
}


struct LoadingScreen: View {
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var rotationAngle: Double = 0.0
    @State private var destinationPage: NavigationPathViews? = nil
    @State private var useBiometrics: Bool = true
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationStack(path: $navManager.path) {
            ZStack {
                VStack {
                    Spacer()
                    if useBiometrics { Spacer() }
                    
                    VStack {
                        Image("BuulLogoText")
                            .resizable()
                            .frame(width: 300, height: 127)
                            .padding(.bottom, 30)
                        
                        
                        Text("Turn your spending into wealth")
                            .foregroundColor(.gray)
                            .padding(.bottom, 30)
                    }
                    if !useBiometrics {
                        VStack(spacing: 20) {
                            Button {
                                useBiometrics = true
                            } label: {
                                Text("Unlock")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }
                            Button {
                                Task {
                                    _ = await sessionManager.resetComplete() // await
                                    navManager.reset()
                                }
                            } label: {
                                Text("Log Out")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(.black)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.gray.opacity(0.6), lineWidth: 2)
                                    )
                            }
                        }
                        .padding()
                    } else {
                        LoadingCircle(spacers: false)
                            .background(Color.black.ignoresSafeArea())
                        Spacer()
                            
                    }
                    Spacer()
                }
                
            }
            .background(Color.black.ignoresSafeArea())
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { showAlert = false }
            }
            .onAppear {
                withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
            .animation(.easeInOut, value: useBiometrics)
            .task {
                authenticate()
                
            }
            .onChange(of: destinationPage) {
                if let destinationPage = destinationPage {
                    let path = sessionManager.signUpFlowPlacementPaths(destinationPage)
                    navManager.extend(path)
                }
            }
            .onChange(of: useBiometrics) {
                if useBiometrics {
                    authenticate()
                }
            }
            .navigationDestination(for: NavigationPathViews.self) { view in
                switch view {
                    // main landing pages
                case .landing:
                    LandingView()
                case .home:
                    HomeView()
                    
                    // sign up or login
                case .login:
                    LoginView()
                    
                case .signUpPhone:
                    FieldsRequestOTPView(
                        signUpFields: [.phoneNumber],
                        nextPage: .signUpEmail,
                        signUpField: .phoneNumber,
                        authenticate: false,
                        isSignUp: true
                    )
                    
                case .signUpEmail:
                    FieldsRequestOTPView(
                        signUpFields: [.email],
                        nextPage: .signUpEmailVerify,
                        signUpField: .email,
                        authenticate: false,
                        isSignUp: true
                    )
                case .signUpEmailVerify:
                    OTPView(
                        title: "Verify Your Email",
                        subtitle: "Enter the code sent to your email address",
                        goBackNPagesToRedoEntries: 1,
                        goBackNPagesIfCompleted: 0,
                        nextPage: .signUpFullName,
                        signUpField: .email,
                        authenticate: false
                    )
                    
                case .signUpFullName:
                    NoOTPFieldsView(
                        signUpFields: [.fullName],
                        signUpField: .fullName,
                        title: nil,
                        subtitle: nil,
                        nextPage: .signUpPassword,
                        authenticate: false
                    )
                case .signUpPassword:
                    SignUpPasswordView()
                case .accountCreated:
                    AccountCreated()
                        .transition(.move(edge: .trailing))
                
                case .signUpETFs:
                    NoOTPFieldsView(
                        signUpFields: [.symbol],
                        signUpField: .symbol,
                        title: "Select an investment",
                        subtitle: "We will invest your cashback monthly. You can change your choice later.",
                        nextPage: .signUpBrokerage,
                        authenticate: true
                    )
                case .signUpBrokerage:
                    NoOTPFieldsView(
                        signUpFields: [.brokerage],
                        signUpField: .brokerage,
                        title: "Select a brokerage",
                        subtitle: "Choose the brokerage you want to use with Buul.",
                        nextPage: .signUpBrokerage,
                        authenticate: true
                    )
                    
                case .signUpRobinhoodSecurityInfo:
                    RobinhoodSecurityInfoView(isSignUp: true)
                case .signUpRobinhood:
                    SignUpRobinhoodView(
                        signUpFields: [.email, .password],
                        isSignUp: true
                    )
                case .signUpMfaRobinhood:
                    SignUpRobinhoodMFAView(isSignUp: true)
                case .signUpConnectBrokerageLater:
                    ConnectBrokerageLaterView(isSignUp: true)
                    
                case .plaidInfo:
                    PlaidInfo(
                        nextPage: .link,
                        isSignUp: true,
                        isUpdate: false
                    )
                case .link:
                    LinkView(
                        goBackNPagesToRedoEntries: 0,
                        goBackNPagesIfCompleted: 0,
                        nextPage: .redeemCashbackInstructions,
                        isSignUp: true
                    )
                case .redeemCashbackInstructions:
                    RedeemCashbackInstructionsView(
                        nextPage: .home,
                        isSignUp: true
                    )
                case .emailRecover:
                    EmailRecoverView()
                case .passwordRecoverInitiate:
                    FieldsRequestOTPView(
                        signUpFields: [.verificationEmail, .password, .password2],
                        title: "Forgot your password?",
                        subtitle: "We will send you a code if we have an account associated with this email.",
                        nextPage: .passwordRecoveryOTP,
                        signUpField: .password,
                        authenticate: false,
                        isSignUp: false
                    )
                case .passwordRecoveryOTP:
                    OTPView(
                        title: "Reset Password",
                        subtitle: "Enter the code sent to your email",
                        goBackNPagesToRedoEntries: 1,
                        goBackNPagesIfCompleted: 2,
                        nextPage: nil,
                        signUpField: .password,
                        authenticate: false
                    )
                    
                    // settings
                case .accountInfo:
                    SettingsAccountInfoView()
                case .bank:
                    SettingsBankInfoView()
                case .help:
                    SettingsHelpView()
                case .plaidSettingsHelp:
                    SettingsPlaidHelpView()
                case .plaidSettings:
                    SettingsPlaidView()
                    
                    // change account into
                case .delete:
                    FieldsRequestOTPView(
                        signUpFields: [],
                        title: "Delete Account",
                        subtitle: "You cannot undo this action and all data will be lost. Press 'Next' to begin account deletion.",
                        nextPage: .deleteOTP,
                        signUpField: .deleteAccount,
                        authenticate: true,
                        isSignUp: false
                    )
                case .deleteOTP:
                    OTPView(
                        title: "Delete Account",
                        subtitle: "Enter the code sent to your email to proceed. You cannot undo this action and all data will be lost.",
                        goBackNPagesToRedoEntries: 1,
                        goBackNPagesIfCompleted: 0,
                        nextPage: .landing,
                        signUpField: .deleteAccount,
                        authenticate: true
                    )
                    
                    
                case .changePassword:
                    FieldsRequestOTPView(
                        signUpFields: [.password, .password2],
                        title: "Reset Password",
                        subtitle: nil,
                        nextPage: .changePasswordOTP,
                        signUpField: .password,
                        authenticate: true,
                        isSignUp: false
                    )
                case .changePasswordOTP:
                    OTPView(
                        title: "Reset Password",
                        subtitle: "Enter the code sent to your email to verify your identity before we proceed.",
                        goBackNPagesToRedoEntries: 1,
                        goBackNPagesIfCompleted: 2,
                        nextPage: nil,
                        signUpField: .password,
                        authenticate: true
                    )
                    
                case .changeEmail:
                    FieldsRequestOTPView(
                        signUpFields: [.email],
                        title: "Change Email Address",
                        subtitle: nil,
                        nextPage: .changeEmailOTP,
                        signUpField: .email,
                        authenticate: true,
                        isSignUp: false
                    )
                case .changeEmailOTP:
                    OTPView(
                        title: "Change Email Address",
                        subtitle: "Enter the code sent to your email to verify your identity before we proceed.",
                        goBackNPagesToRedoEntries: 1,
                        goBackNPagesIfCompleted: 2,
                        nextPage: nil,
                        signUpField: .email,
                        authenticate: true
                    )
                    
                    
                case .changePhone:
                    FieldsRequestOTPView(
                        signUpFields: [.phoneNumber],
                        title: "Change Phone Number",
                        subtitle: nil,
                        nextPage: .changePhoneOTP,
                        signUpField: .phoneNumber,
                        authenticate: true,
                        isSignUp: false
                    )
                case .changePhoneOTP:
                    OTPView(
                        title: "Change Phone Number",
                        subtitle: "Enter the code sent to your email to verify your identity before we proceed.",
                        goBackNPagesToRedoEntries: 1,
                        goBackNPagesIfCompleted: 2,
                        nextPage: nil,
                        signUpField: .phoneNumber,
                        authenticate: true
                    )
                    
                case .changeName:
                    FieldsRequestOTPView(
                        signUpFields: [.fullName],
                        title: "Change Name",
                        subtitle: nil,
                        nextPage: .changeNameOTP,
                        signUpField: .fullName,
                        authenticate: true,
                        isSignUp: false
                    )
                case .changeNameOTP:
                    OTPView(
                        title: "Change Name",
                        subtitle: "Enter the code sent to your email to verify your identity before we proceed.",
                        goBackNPagesToRedoEntries: 1,
                        goBackNPagesIfCompleted: 2,
                        nextPage: nil,
                        signUpField: .fullName,
                        authenticate: true
                    )
                    
                case .changeETF:
                    FieldsRequestOTPView(
                        signUpFields: [.symbol],
                        title: "Select an investment",
                        subtitle: "We will invest your cashback monthly. You can change your choice later.",
                        nextPage: .changeETFOTP,
                        signUpField: .symbol,
                        authenticate: true,
                        isSignUp: false
                    )
                case .changeETFOTP:
                    OTPView(
                        title: nil,
                        subtitle: "Enter the code sent to your email to change your investment preference.",
                        goBackNPagesToRedoEntries: 1,
                        goBackNPagesIfCompleted: 2,
                        nextPage: nil,
                        signUpField: .symbol,
                        authenticate: true
                    )
                    
                case .changeBrokerage:
                    FieldsRequestOTPView(
                        signUpFields: [.brokerage],
                        title: "Select a brokerage",
                        subtitle: "Choose the brokerage you want to use with Buul.",
                        nextPage: .changeBrokerageOTP,
                        signUpField: .brokerage,
                        authenticate: true,
                        isSignUp: false
                    )
                case .changeBrokerageOTP:
                    OTPView(
                        title: nil,
                        subtitle: "Enter the code sent to your email to change your brokerage.",
                        goBackNPagesToRedoEntries: 1,
                        goBackNPagesIfCompleted: 0,
                        nextPage: .robinhoodSecurityInfo,
                        signUpField: .brokerage,
                        authenticate: true
                    )
                case .robinhoodSecurityInfo:
                    RobinhoodSecurityInfoView(isSignUp: false)
                case .connectRobinhood:
                    SignUpRobinhoodView(
                        signUpFields: [.email, .password],
                        isSignUp: false
                    )
                case .mfaRobinhood:
                    SignUpRobinhoodMFAView(isSignUp: false)
                case .connectBrokerageLater:
                    ConnectBrokerageLaterView(isSignUp: false)
                    
                case .plaidInfoAdd:
                    PlaidInfo(
                        nextPage: .linkAdd,
                        isSignUp: false,
                        isUpdate: false
                    )
                case .linkAdd:
                    LinkView(
                        goBackNPagesToRedoEntries: 0,
                        goBackNPagesIfCompleted: 2,
                        nextPage: .redeemCashbackInstructionsAdd,
                        isSignUp: false
                    )
                case .redeemCashbackInstructionsAdd:
                    RedeemCashbackInstructionsView(
                        nextPage: .home,
                        isSignUp: false
                    )
                case .plaidInfoUpdate:
                    PlaidInfo(
                        nextPage: .linkUpdate,
                        isSignUp: false,
                        isUpdate: true
                    )
                case .linkUpdate:
                    LinkViewUpdate(
                        goBackNPagesToRedoEntries: 0,
                        goBackNPagesIfCompleted: 2,
                        nextPage: .redeemCashbackInstructionsUpdate,
                        isSignUp: false
                    )
                case .redeemCashbackInstructionsUpdate:
                    RedeemCashbackInstructionsView(
                        nextPage: .home,
                        isSignUp: false
                    )
                case .redeemCashbackInstructionsHelp:
                    RedeemCashbackInstructionsView(
                        nextPage: .home,
                        isSignUp: true,
                        goBackNPagesOnCompletion: 1
                    )
                }
            }
        }
    }
    
    private func authenticate() {
        if !sessionManager.loadSavedTokens() {
            sessionManager.isLoggedIn = false
            destinationPage = sessionManager.signUpFlowPlacement()
            useBiometrics = false
            return
        }
        sessionManager.authenticateUser() { response in
            switch response {
            case .success:
                destinationPage = sessionManager.signUpFlowPlacement()
            case .failure(let error):
                if error == .failedAuthentication {
                    useBiometrics = false
                } else {
                    useBiometrics = false
                    showAlert = true
                    alertMessage = "Face ID is not accessible. Please log in manually."
                }   
            }
        }
    }
    
}

#Preview {
    LoadingScreen()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
