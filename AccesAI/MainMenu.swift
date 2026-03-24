//
//  MainMenu.swift
//  AccesAI
//
//  Created by Fernando Aguilar on 24/03/26.
//

import SwiftUI

struct MainMenu: View {
    @State private var selectedIndex: Int? = nil
    
    var body: some View {
        ZStack(){
            Group {
                if let index = selectedIndex {
                    Nav(index: index)
                } else
                {
                    VStack(spacing: 24) {
                        Text("AccesAI")
                            .font(Font.custom("Helvetica Neue", size: 28).weight(.bold))

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            menuButton(imageName: "image2", title: "Fes Acatlán Map", index: 0)
                            menuButton(imageName: "image3", title: "Mexico City Map", index: 1)
                            menuButton(imageName: "image4", title: "Opción 3", index: 2)
                            menuButton(imageName: "image5", title: "Opción 4", index: 3)
                            menuButton(imageName: "image6", title: "Information", index: 4)
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .animation(.easeInOut, value: selectedIndex)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.azulPastel, Color.verdePastel]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    @ViewBuilder
    private func menuButton(imageName: String, title: String, index: Int) -> some View {
        Button {
            selectedIndex = index
        } label: {
            VStack(spacing: 8) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                    )
                    .background(
                        {
                            let pattern = [Color.verdeFuerte, Color.azulFuerte, Color.azulFuerte, Color.verdeFuerte, Color.verdeFuerte]
                            return pattern[index % pattern.count]
                        }()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Text(title)
                    .font(Font.custom("Helvetica Neue", size: 14))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text("Doble toque para continuar"))
        .buttonStyle(.plain)
    }
}

#Preview {
    MainMenu()
}

