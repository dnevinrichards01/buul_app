import SwiftUI


struct LandingView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    @State var temp: String = ""
    
    var body: some View {
        
        NavigationStack(path: $navManager.path) {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    // App Name
                    Image("AccumateLogoText")
                        .resizable()
                        .frame(width: 350, height: 115)
                    
                    // Welcome Message
                    Text("Welcome to Accumate")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("Turn your spending into wealth")
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)
                    
                    // Buttons
                    VStack(spacing: 20) {
                        Button {
                            navManager.path.append(NavigationPathViews.login)
                        } label: {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        
                        Button {
                            navManager.path.append(NavigationPathViews.signUpPhone)
//                            navManager.path.append(NavigationPathViews.home)
                        } label: {
                            Text("Sign Up")
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
                    .padding(
                        .horizontal,
                        horizontalSizeClass == .compact ? geometry.size.width * 0.05 : geometry.size.width * 0.15
                    )
                    
                    Spacer()
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                }
//                .onAppear {
//                    navManager.resetNavigation()
//                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.black.ignoresSafeArea())
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
                    ChangeAccountInfoView(signUpFields: [.password, .password2])
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
                    ChangeAccountInfoView(signUpFields: [.password, .password2])
                case .changeEmailOTP:
                    OTPView(
                        title: "Change Email Address",
                        subtitle: "Enter the code sent to your email to verify your identity before we proceed.",
                        nextPage: NavigationPathViews.changeEmail
                    )
                case .changeEmail:
                    ChangeAccountInfoView(signUpFields: [SignUpFields.email])
                case .changePhoneOTP:
                    OTPView(
                        title: "Change Phone Number",
                        subtitle: "Enter the code sent to your email to verify your identity before we proceed.",
                        nextPage: NavigationPathViews.changePhone
                    )
                case .changePhone:
                    ChangeAccountInfoView(signUpFields: [SignUpFields.phoneNumber])
                case .changeNameOTP:
                    OTPView(
                        title: "Change Name",
                        subtitle: "Enter the code sent to your email to verify your identity before we proceed.",
                        nextPage: NavigationPathViews.changeName
                    )
                case .changeName:
                    ChangeAccountInfoView(signUpFields: [SignUpFields.fullName])
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
            .toolbar {
                ToolbarItem (placement: .topBarLeading) {
                    Text("Accumate")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Image("AccumateLogo")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
            }
            .environmentObject(navManager)
        }
    }
}

#Preview {
    LandingView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
