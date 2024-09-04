//
//  LoginView.swift
//  iForest
//
//  Created by Marcel Mravec on 04.09.2024.
//

import SwiftUI

struct LoginView: View {
    // In MVVM the Output will be located in the ViewModel
    
    struct Output {
        var goToMainScreen: () -> Void
        
    }
    var output: Output
    
    var body: some View {
        Button(
            action: {
                self.output.goToMainScreen()
            },
            label: {
                Text("Login")
            }
        ).padding()
    }
}

#Preview {
    LoginView(output: .init(goToMainScreen: {}))
}
