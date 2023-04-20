//
//  IntroPageView.swift
//  ScreenExternal1
//
//  Created by Admin on 01/04/2023.
//

import SwiftUI

struct IntroPageView: View {
    @State private var pageIndex = 0
    @Binding var intro: Bool
    private let pages: [Page] = Page.samplePages
    private let dotAppearance = UIPageControl.appearance()
    
    var body: some View {
  
        TabView(selection: $pageIndex) {
            ForEach(pages) { page in
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color("color4"), Color("color1")]), startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea(.all, edges: .all)
                VStack(spacing: 20) {
                    Spacer()
                    Image("\(page.imageName)")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(30)
                        .overlay(RoundedRectangle(cornerRadius: 30)
                        .stroke(Color("color4"), lineWidth: 3))
                        .shadow(radius: 10)
                        .padding()
                    Text(page.name)
                        .font(.title)
                        .foregroundColor(Color("color4"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                    
                    Text(page.description)
                        .font(.title3)
                        .frame(width: 350)
                        .foregroundColor(Color("color4"))
                        .minimumScaleFactor(0.01)
                    Spacer()
                    if page == pages.last {
                        Button("Go to app") {
                            UserDefaults.standard.set(true, forKey: "intro")
                            intro = true
                        }.buttonStyle(.bordered)
                    } else {
                        Button("Next") {
                            pageIndex += 1
                        }.buttonStyle(.bordered)
                    }
                    Spacer().frame(height: 30)
                }
              }.tag(page.tag)
            }
        }.ignoresSafeArea()
         .animation(.easeInOut, value: pageIndex)
         .tabViewStyle(.page)
         .indexViewStyle(.page(backgroundDisplayMode: .interactive))
         .onAppear {
             dotAppearance.currentPageIndicatorTintColor = .black
             dotAppearance.pageIndicatorTintColor = .gray
         }
        
    }
}
