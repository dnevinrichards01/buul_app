import SwiftUI


struct LandingView: View {    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    @State var temp: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
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
            }
            
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
            .padding()
            
            Spacer()
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
    }
}

#Preview {
    LandingView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
