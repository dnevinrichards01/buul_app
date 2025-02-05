import SwiftUI


struct LandingView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    @State var temp: String = ""
    
    var body: some View {
        
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
                        navManager.append(NavigationPathViews.login)
                    } label: {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        navManager.append(NavigationPathViews.signUpPhone)
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
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.ignoresSafeArea())
        
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

#Preview {
    LandingView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
