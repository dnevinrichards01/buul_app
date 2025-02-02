//
//  SettingsAccountInfoFieldView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/1/25.
//

import SwiftUI

struct SettingsAccountInfoFieldView: View {
    var instruction : String
    var info : String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(instruction)
                .foregroundColor(.white.opacity(0.9))
                .font(.system(size: 18))
                .background(.black)
                .cornerRadius(10)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                ZStack(alignment: .leading) {
                    Text(info)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(.black)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray.opacity(0.4), lineWidth: 2)
                )
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(width: 13, height: 16)
                    .padding(5)
                    .padding(.leading, 10)
            }
        }
        //        .frame()
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

#Preview {
    SettingsAccountInfoFieldView(
        instruction: "example instruction",
        info: "value like this"
    )
    .background(.black)
}
