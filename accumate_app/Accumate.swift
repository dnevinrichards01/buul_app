//
//  accumate_appApp.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/2/24.
//

import SwiftUI

@main
struct Accumate: App {
    @StateObject var navManager = NavigationPathManager()
    @StateObject var sessionManager = UserSessionManager()
    
    init() {
        initToolbarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            LoadingScreen()
                .environmentObject(navManager)
                .environmentObject(sessionManager)
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
    
    @State var destinationPage: NavigationPathViews? = nil
    @State private var rotationAngle: Double = 0.0
    
    var body: some View {
        NavigationStack(path: $navManager.path) {
            ZStack {
                VStack {
                    Spacer()
                    
                    // App Name
                    Image("AccumateLogoText")
                        .resizable()
                        .frame(width: 350, height: 115)
                        .padding(.bottom, -30)
                    
                    
                    Text("Turn your spending into wealth")
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 5)
                            .frame(width: 60)
                        
                        Circle()
                            .trim(from: 0.2, to: 1.0)
                            .stroke(Color.white, lineWidth: 5)
                            .frame(width: 60)
                            .rotationEffect(.degrees(rotationAngle))
                    }
                    .frame(width: 100, height: 100)
                    
                    Spacer()
                }
                .background(.black)
                .onAppear {
                    withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
                .task {
                    destinationPage = await sessionManager.login()
                }
                .onChange(of: destinationPage) {
                    if destinationPage == .signUpPhone {
                        navManager.extend([.landing, .signUpPhone])
                    } else if destinationPage == .signUpEmail {
                        navManager.extend([.landing, .signUpPhone, .signUpEmail])
                    } else if destinationPage == .signUpFullName {
                        navManager.extend([.landing, .signUpPhone, .signUpEmail, .signUpEmailVerify, .signUpFullName])
                    } else if destinationPage == .signUpETFs {
                        navManager.extend([.landing, .signUpPhone, .signUpEmail, .signUpEmailVerify, .signUpFullName,
                                           .signUpETFs])
                    } else if destinationPage == .signUpBrokerage {
                        navManager.extend([.landing, .signUpPhone, .signUpEmail, .signUpEmailVerify, .signUpFullName,
                                           .signUpETFs, .signUpBrokerage])
                    } else if destinationPage == .link {
                        navManager.extend([.landing, .signUpPhone, .signUpEmail, .signUpEmailVerify, .signUpFullName,
                                           .signUpETFs, .signUpBrokerage, .signUpRobinhoodSecurityInfo, .signUpRobinhood])
                        // leaving out rh mfa bc not relevant to them, and they can always get it by going back then forward.
                    } else if destinationPage == .home {
                        navManager.extend([.home])
                    } else if destinationPage == .landing {
                        navManager.extend([.landing])
                    }
                }
            }
            .navigationDestination(for: NavigationPathViews.self) { view in
                switch view {
                case .landing:
                    LandingView()
                case .home:
                    HomeView()
                    
                case .signUpPhone:
                    SignUpPhoneView()
                case .signUpEmail:
                    SignUpEmailView()
                case .signUpEmailVerify:
                    SignUpEmailVerifyView()
                case .signUpFullName:
                    SignUpFullNameView()
                case .signUpETFs:
                    SignUpETFsView()
                case .signUpBrokerage:
                    SignUpBrokerageView()
                case .signUpRobinhoodSecurityInfo:
                    RobinhoodSecurityInfoView()
                case .signUpRobinhood:
                    SignUpRobinhoodView()
                case .signUpMfaRobinhood:
                    SignUpRobinhoodMFAView()
                case .login:
                    LoginView(signUpFields: [.username, .password])
                case .link:
                    LinkView()
                case .emailRecover:
                    EmailRecoverView()
                case .passwordRecoverInitiate:
                    PasswordRecoverInitiateView()
                case .passwordRecoveryOTP:
                    OTPView(
                        title: "Reset Password",
                        subtitle: "Enter the code sent to your email",
                        nextPage: NavigationPathViews.passwordRecover
                    )
                case .passwordRecover:
                    ChangeAccountInfoView(title: "Reset Password", signUpFields: [.password, .password2])
                case .accountInfo:
                    SettingsAccountInfoView()
                case .bank:
                    SettingsBankInfoView()
                case .help:
                    SettingsHelpView()
                case .deleteOTP:
                    OTPView(
                        title: "Delete Account",
                        subtitle: "Enter the code sent to your email to proceed. You cannot undo this action and all data will be lost.",
                        nextPage: NavigationPathViews.delete
                    )
                case .delete:
                    SettingsDeleteView()
                case .changePasswordOTP:
                    OTPView(
                        title: "Reset Password",
                        subtitle: "Enter the code sent to your email to verify your identity before we proceed.",
                        nextPage: NavigationPathViews.changePassword
                    )
                case .changePassword:
                    ChangeAccountInfoView(title: "Reset Password", signUpFields: [.password, .password2])
                case .changeEmailOTP:
                    OTPView(
                        title: "Change Email Address",
                        subtitle: "Enter the code sent to your email to verify your identity before we proceed.",
                        nextPage: NavigationPathViews.changeEmail
                    )
                case .changeEmail:
                    ChangeAccountInfoView(title: "Change Email Address", signUpFields: [SignUpFields.email])
                case .changePhoneOTP:
                    OTPView(
                        title: "Change Phone Number",
                        subtitle: "Enter the code sent to your email to verify your identity before we proceed.",
                        nextPage: NavigationPathViews.changePhone
                    )
                case .changePhone:
                    ChangeAccountInfoView(title: "Change Phone Number", signUpFields: [SignUpFields.phoneNumber])
                case .changeNameOTP:
                    OTPView(
                        title: "Change Name",
                        subtitle: "Enter the code sent to your email to verify your identity before we proceed.",
                        nextPage: NavigationPathViews.changeName
                    )
                case .changeName:
                    ChangeAccountInfoView(title: "Change Name", signUpFields: [SignUpFields.fullName])
                case .changeBrokerage:
                    SignUpBrokerageView(isSignUp: false)
                case .robinhoodSecurityInfo:
                    RobinhoodSecurityInfoView(isSignUp: false)
                case .connectRobinhood:
                    SignUpRobinhoodView(isSignUp: false)
                case .mfaRobinhood:
                    SignUpRobinhoodMFAView(isSignUp: false)
                case .changeETFOTP:
                    OTPView(
                        title: "Change Your Investment",
                        subtitle: "Enter the code sent to your email to verify your identity before we proceed.",
                        nextPage: NavigationPathViews.changeETF
                    )
                case .changeETF:
                    SignUpETFsView(isSignUp: false)
                case .plaidSettings:
                    SettingsPlaidView()
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
