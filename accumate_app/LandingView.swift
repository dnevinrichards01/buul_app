import SwiftUI


struct LandingView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @EnvironmentObject var navManager : NavigationPathManager
    
    init() {
        // Configure appearance for the navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        // Apply appearance to the navigation bar
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

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
                            navManager.path.append("LoginView")
                        } label: {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        
                        Button {
                            navManager.path.append("SignUpView")
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
            .background(Color.black.ignoresSafeArea())
            .navigationDestination(for: String.self) { value in
                if value == "LoginView" {
                    LoginView()
                } else if value == "SignUpView" {
                    SignUpView()
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


struct NewView: View {
    var body: some View {
        Text("Welcome to the New View!")
            .font(.largeTitle)
            .padding()
    }
    
}

#Preview {
    LandingView()
        .environmentObject(NavigationPathManager())
}
