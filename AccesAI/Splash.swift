
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
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 300)
                        .clipShape(Circle())
                        .background(Circle().fill(Color.white))
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
