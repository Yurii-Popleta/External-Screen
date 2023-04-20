//
//  Image.swift
//  ScreenExternal1
//
//  Created by Admin on 06/03/2023.
//

import SwiftUI

extension Image {
     func normalImage(viewModel: ViewModel) -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
            .frame(width: viewModel.frame().width, height: viewModel.frame().height)
            .cornerRadius(10)
            .contentShape(Rectangle())
    }
    
     func externalImage() -> some View {
        self.resizable()
            .scaledToFit()
    }
    
     func systemImage(viewModel: ViewModel) -> some View {
        self.resizable()
            .padding(15)
            .frame(width: viewModel.frame().width, height: viewModel.frame().height)
            .background(.gray)
            .foregroundColor(Color.white)
            .cornerRadius(10)
            .opacity(0.5)
      }
}

