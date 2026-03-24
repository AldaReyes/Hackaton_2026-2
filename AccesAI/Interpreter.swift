import SwiftUI
import AVKit

struct VideoItem: Identifiable, Equatable {
    let id = UUID()
    let titulo: String
    let descripcion: String
    let url: URL
}

struct Interpreter: View {
    @State private var textoBusqueda: String = ""
    @State private var estaEscuchando: Bool = false
    @State private var mostrarVideoEnGrande: VideoItem?

    // Lista de videos disponibles
    let videos: [VideoItem] = [
        VideoItem(
            titulo: "Hola, ¿Como estas?",
            descripcion: "Presentacion",
            url: URL(string: "https://files.catbox.moe/szx16o.mp4")!
        ),
        VideoItem(
            titulo: "Ir al metro",
            descripcion: "Frase para pedir ir al metro.",
            url: URL(string: "https://files.catbox.moe/r5om0f.mp4")!
        ),
        VideoItem(
            titulo: "Ir a la cafetería",
            descripcion: "Frase para pedir ir a la cafetería.",
            url: URL(string: "https://files.catbox.moe/r0ggy9.mp4")!
        ),
    ]

    // Filtra los videos según la barra de búsqueda
    var resultados: [VideoItem] {
        let texto = textoBusqueda.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if texto.isEmpty { return videos }
        return videos.filter { $0.titulo.lowercased().contains(texto) || $0.descripcion.lowercased().contains(texto) }
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Barra de búsqueda + micrófono
                HStack {
                    TextField("Buscar...", text: $textoBusqueda)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding(10)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                    Button {
                        estaEscuchando.toggle()
                    } label: {
                        Image(systemName: estaEscuchando ? "mic.fill" : "mic")
                            .foregroundColor(estaEscuchando ? .red : .blue)
                            .font(.title2)
                            .padding(.horizontal, 6)
                    }
                }
                .padding([.horizontal, .bottom])

                // Lista de videos con miniatura
                List(resultados) { video in
                    Button {
                        mostrarVideoEnGrande = video
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.black.opacity(0.1))
                                    .frame(width: 70, height: 70)
                                    .cornerRadius(8)
                                VideoPlayer(player: AVPlayer(url: video.url))
                                    .frame(width: 70, height: 70)
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                                    .disabled(true) // Para evitar que interactúen aquí
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(video.titulo)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(video.descripcion)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listStyle(.plain)

                Spacer()
            }
            .navigationTitle("Intérprete")
            .fullScreenCover(item: $mostrarVideoEnGrande) { video in
                GeometryReader { geometry in
                    ZStack(alignment: .topTrailing) {
                        Color.black.opacity(0.85)
                            .edgesIgnoringSafeArea(.all)
                        VStack {
                            Spacer()
                            VideoPlayer(player: AVPlayer(url: video.url))
                                .frame(maxHeight: geometry.size.height * 0.5)
                                .cornerRadius(20)
                                .shadow(radius: 16)
                            Text(video.titulo)
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                                .padding(.top)
                            Text(video.descripcion)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.top, 4)
                            Spacer()
                        }
                        Button {
                            mostrarVideoEnGrande = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                                .padding()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Interpreter()
}

