//
//  SwiftUIView.swift
//  ScreenExternal1
//
//  Created by Admin on 24/03/2023.
//

import SwiftUI

struct CastomtoolbarView: View {
   @ObservedObject var viewModel: ViewModel
    
    var body: some View {
            ZStack{
                Capsule().frame(width: UIScreen.screenWidth-30, height: 50, alignment: .center)
                    .foregroundColor(Color("color1"))
                    .background(.clear)
                    .opacity(0.8)
                HStack {
                        Text("  "+viewModel.sizeExternalScreen()+"  ")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .opacity(0.8)
                            .padding(5)
                            .background(content: {
                                ZStack {
                                    if viewModel.screen != nil {
                                        Color.green
                                            .opacity(0.4)
                                    } else {
                                        Color("color3")
                                            //.opacity(0.2)
                                    }
                                }
                            }).cornerRadius(20)
                               Spacer()
                    Button {
                        viewModel.sheetPlayItem = true
                    } label: {
                        Image(systemName: "app.connected.to.app.below.fill")
                            .foregroundColor(Color.black)
                            .padding(5)
                            .background(viewModel.color.opacity(0.7))
                            .cornerRadius(180)
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
            }.frame(width: UIScreen.screenWidth-30, height: 50, alignment: .center)
     }
}
