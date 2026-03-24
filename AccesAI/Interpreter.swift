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
        VideoItem(
            titulo: "Llama a la policia",
            descripcion: "Frase para pedir ayuda a otra persona",
            url: URL(string: "https://files.catbox.moe/cobyel.mp4")!
        ),
        VideoItem(
            titulo: "Muchas gracias por tu ayuda",
            descripcion: "Frase para agradecer",
            url: URL(string: "https://files.catbox.moe/5pspid.mp4")!
        ),
        VideoItem(
            titulo: "¿Te puedo ayudar en algo?",
            descripcion: "Frase para ofreser tu ayuda a alguien más",
            url: URL(string: "https://files.catbox.moe/4t280x.mp4")!
        ),
    ]

    // Filtra los videos según la barra de búsqueda
    var resultados: [VideoItem] {
        let texto = textoBusqueda.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if texto.isEmpty { return videos }
        return videos.filter { $0.titulo.lowercased().contains(texto) || $0.descripcion.lowercased().contains(texto) }
    }

    var body: some View {
        ZStack{
            NavigationStack {
                VStack {
                    // Barra de búsqueda + micrófono
                    HStack {
                        TextField("Buscar...", text: $textoBusqueda)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(10)
                            .background(Color.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                            )
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
                            .padding(.horizontal, 8)
                            .background(Color.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .frame(height: 90, alignment: .center)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)

                    Spacer()
                }
                .background(Color.clear)
                .navigationTitle("Intérprete")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.azulPastel, Color.verdePastel]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                )
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
}

#Preview {
    Interpreter()
}

