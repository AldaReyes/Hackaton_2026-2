
import SwiftUI

struct Splash: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        if isActive {
            MainMenu()
        } else {
            VStack {
                VStack {
                    Image("image1")
                        .resizable() // Asegúrate de que la imagen sea redimensionable
                        .aspectRatio(contentMode: .fill) // Rellena el espacio del círculo
                        .frame(width: 300, height: 300) // Ajusta el tamaño del círculo
                        .clipShape(Circle()) // Recorta la imagen como círculo
                        //.overlay(Circle().stroke(Color(hex: 0xFFD700), lineWidth: 5)) // Añade un borde blanco opcional
                        .background(Circle().fill(Color.white)) // Fondo blanco del círculo
                    Text("Acces AI".uppercased())
                        .font(Font.custom("Baskerville-Bold", size: 30))
                        .foregroundColor(.black.opacity(0.80))
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
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ocupa toda la pantalla
            .background(Color.white) // Fondo blanco de la pantalla
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isActive = true
                }
            }
        }
    }
}


struct SplashScreenView_Previews : PreviewProvider{
    static var previews: some View{
        Splash()
    }
}
