//
//  OTPView().swift
//  accumate_app
//
//  Created by Nevin Richards on 2/1/25.
//

import SwiftUI
import UIKit

struct OTPFieldView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    @Binding var otp: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            TextField("", text: $otp)
                .foregroundStyle(.clear)
                .accentColor(.clear)
                .keyboardType(.numberPad)
                .frame(height: 60)
                .focused($isFocused)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .allowsHitTesting(false)
            Button {
                isFocused = true
            } label: {
                Rectangle()
                    .foregroundStyle(.clear)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
            }
            HStack {
                ForEach(0...5, id: \.self) { index in
                    VStack {
                        Text(Utils.getIndex(text: otp, index: index))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(height: 50)
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(.white)
                    }
                    .frame(height: 60)
                    .padding(.horizontal, 5)
                }
            }
            .onChange(of: otp) {
                otp = Utils.truncateTo6Digits(text: otp)
            }
        }
        .background(.black)
    }
    
    
}

