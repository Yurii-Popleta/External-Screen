//
//  SplashScreenView.swift
//  ScreenExternal1
//
//  Created by Admin on 01/04/2023.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var size = 0.8
    @State private var opacity = 0.3
    
    var body: some View {
                VStack {
                    Image("icon")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 10)
                    Spacer().frame(height: 15)
                    Text("External Screen")
                        .font(.system(size: 26, weight: .semibold, design: .monospaced))
                        .foregroundColor(.black.opacity(0.50))
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                 }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
