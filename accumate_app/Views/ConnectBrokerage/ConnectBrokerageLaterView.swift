//
//  ConnectBrokerageLaterView.swift
//  accumate_app
//
//  Created by Nevin Richards on 3/13/25.
//

import SwiftUI

struct ConnectBrokerageLaterView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    var isSignUp: Bool
    @State private var brokerage: Brokerages?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    init(isSignUp: Bool) {
        self.isSignUp = isSignUp
    }
    
    var body: some View {
        VStack {
            VStack (alignment: .center) {
                if let brokerage = brokerage {
                    Image(brokerage.imageName)
                        .resizable()
                        .frame(width: brokerage.imageDim[0], height: brokerage.imageDim[1])
                        .padding(.leading, -6)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .padding(.leading, -6)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            VStack (alignment: .leading, spacing: 15) {
                Text("We are working on connecting users to \(brokerage?.displayName ?? "your brokerage") but we aren't quite ready. We have saved your preference and will notify you when it is time to connect!")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                Text("If you would like to connect to a brokerage immediately, we are only able to connect to \(Brokerages.robinhood.displayName).")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                if !isSignUp {
                    Text("You may change your preference again from the 'Banking Information' page.")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
            
            Spacer()
            
            VStack {
                Button {
                    if isSignUp {
                        sessionManager.brokerageCompleted = true
                        navManager.append(.plaidInfo)
                    } else {
                        navManager.removeLast(3)
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                }
                
                HStack {
                    Image(systemName: "lock.shield")
                        .foregroundStyle(.gray)
                    Text("Accumate uses bank level security to connect to your brokerage")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .padding(.leading, 10)
                }
                .padding()
            }
            
        }
        .padding()
        .alert(alertMessage, isPresented: $showAlert) {
            if showAlert {
                Button("OK", role: .cancel) {
                    showAlert = false
                }
            }
        }
        .onAppear {
            let brokerage: Brokerages? = Utils.getBrokerage(sessionManager: sessionManager)
            print(sessionManager.brokerageName)
            guard let _ = brokerage else {
                alertMessage = "An internal error occurred and the page could not be loaded. Please contact Accumate"
                showAlert = true
                return
            }
            self.brokerage = brokerage
        }
        .onChange(of: showAlert) { oldValue, newValue in
            if oldValue && !newValue {
                if brokerage == nil {
                    navManager.removeLast(1)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    navManager.removeLast(1)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxHeight: 30)
                }
            }
        }
    }
}

#Preview {
    ConnectBrokerageLaterView(isSignUp: true)
}
