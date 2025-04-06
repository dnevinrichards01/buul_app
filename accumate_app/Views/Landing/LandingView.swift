import SwiftUI


struct LandingView: View {    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    @State var temp: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Image("BuulLogoText")
                    .resizable()
                    .frame(width: 300, height: 127)
                
                // Welcome Message
                Text("Welcome to Buul")
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
        .onAppear {
            if sessionManager.preAccountId == nil {
                sessionManager.preAccountId = Int.random(in: 10_000_000...99_999_999)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.ignoresSafeArea())
        
        .toolbar {
//            ToolbarItem (placement: .topBarLeading) {
//                Text("Buul")
//                    .font(.system(size: 24, weight: .bold))
//                    .foregroundColor(.white)
//            }
//            
//            ToolbarItem(placement: .topBarTrailing) {
//                Image("BuulLogo")
//                    .resizable()
//                    .frame(width: 40, height: 40)
//                    .foregroundColor(.white)
//            }
        }
    }
}

#Preview {
    LandingView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
