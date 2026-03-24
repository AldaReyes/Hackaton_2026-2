//
//  AsistenceVoice.swift
//  AccesAI
//
//  Created by DEVELOP02 on 23/03/26.
//

import SwiftUI
import AVFoundation

struct AsistenceVoice: View {
    @State private var texto: String = ""
    @State private var estaEscuchando: Bool = false
    @State private var frasesDetectadas: [String] = []
    @State private var isLoading: Bool = false
    @State private var error: String?
    @FocusState private var textFieldIsFocused: Bool

    @State private var audioRecorder: AVAudioRecorder?
    private let apiKey = ""
    let frasesClave = ["acatlan", "cafeteria", "metro", "asistencia", "accesibilidad"]

    @EnvironmentObject var navModel: NavModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Campo de texto MULTILINEA Y AJUSTABLE
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.2))
                    TextEditor(text: $texto)
                        .focused($textFieldIsFocused)
                        .disableAutocorrection(false)
                        .textInputAutocapitalization(.never)
                        .padding(10)
                        .frame(minHeight: 56, maxHeight: 180)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    // Placeholder
                    if texto.isEmpty {
                        Text("Escribe aquí...")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal)

                // Resultados o mensajes
                if isLoading {
                    ProgressView("Procesando con Groq...")
                        .padding()
                } else if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if !frasesDetectadas.isEmpty {
                    VStack(spacing: 16) {
                        Text("Destinos detectados:")
                            .font(.headline)
                        if frasesDetectadas.count > 2 {
                            // Mostrar en grid de 2 columnas con botones más pequeños
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(frasesDetectadas, id: \.self) { frase in
                                    Button(action: {
                                        irAlDestino(frase: frase)
                                    }) {
                                        Text("Ir a \(frase.capitalized)")
                                            .font(.subheadline)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(Color.blue.opacity(0.85), in: RoundedRectangle(cornerRadius: 10))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        } else {
                            // Uno o dos botones grandes, verticales
                            ForEach(frasesDetectadas, id: \.self) { frase in
                                Button(action: {
                                    irAlDestino(frase: frase)
                                }) {
                                    Text("Ir a \(frase.capitalized)")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                            }
                        }
                    }
                    .padding()
                } else {
                    Text(estaEscuchando ? "Escuchando... suelta para procesar" : "Presiona el micro o escribe una frase")
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }

                Spacer()
                
                // Botón de micrófono más grande, centrado horizontalmente
                Button {
                    if estaEscuchando {
                        detenerYTranscribir()
                    } else {
                        iniciarGrabacion()
                    }
                } label: {
                    Image(systemName: estaEscuchando ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(estaEscuchando ? .red : .blue)
                        .padding(18)
                        .background(
                            Circle()
                                .fill((estaEscuchando ? Color.red : Color.blue).opacity(0.1))
                                .frame(width: 90, height: 90)
                        )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)

                // Botón "Validar" abajo, de ancho completo
                Button(action: {
                    validarConGroq()
                    textFieldIsFocused = true
                }) {
                    Text("Validar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.5) : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Asistencia por Voz")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.azulPastel, Color.verdePastel]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
    }

    // MARK: - Navegación según frase
    func irAlDestino(frase: String) {
        let destino = frase.lowercased()
        switch destino {
        case "acatlan", "cafeteria":
            navModel.selectedTab = 1  // UniversityMap
        case "metro":
            navModel.selectedTab = 0  // CDMXMap
        case "asistencia":
            navModel.selectedTab = 3  // Interpreter
        case "accesibilidad":
            navModel.selectedTab = 4  // Informacion
        default:
            break
        }
        // Limpiar UI
        frasesDetectadas = []
        texto = ""
        error = nil
    }

    // MARK: - Lógica de Grabación
    func iniciarGrabacion() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try? AVAudioRecorder(url: url, settings: settings)
        audioRecorder?.record()
        estaEscuchando = true
    }

    func detenerYTranscribir() {
        audioRecorder?.stop()
        estaEscuchando = false
        isLoading = true

        guard let url = audioRecorder?.url else { return }

        Task {
            do {
                let transcripcion = try await transcribirAudio(url: url)
                await MainActor.run { self.texto = transcripcion }
                validarConGroq()
            } catch {
                await MainActor.run {
                    self.error = "Error al procesar audio"
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - API Groq (Whisper)
    func transcribirAudio(url: URL) async throws -> String {
        var request = URLRequest(url: URL(string: "https://api.groq.com/openai/v1/audio/transcriptions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-large-v3-turbo\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/mpeg\r\n\r\n".data(using: .utf8)!)
        body.append(try Data(contentsOf: url))
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body
        let (data, _) = try await URLSession.shared.data(for: request)
        let res = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return res?["text"] as? String ?? ""
    }

    // MARK: - API Groq (Llama 3 Extraction)
    func validarConGroq() {
        let textoParaEnviar = texto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textoParaEnviar.isEmpty else { return }

        isLoading = true
        frasesDetectadas = []
        error = nil

        Task {
            do {
                let matches = try await analizarTextoConGroq(textoParaEnviar)
                await MainActor.run {
                    self.frasesDetectadas = matches
                    self.isLoading = false
                    if matches.isEmpty { self.error = "No se detectaron destinos." }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.error = "Error de conexión."
                }
            }
        }
    }

    func analizarTextoConGroq(_ texto: String) async throws -> [String] {
        let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
        let prompt = "Extrae de este texto palabras que coincidan con: \(frasesClave.joined(separator: ", ")). Responde SOLO un JSON: {\"matches\": []}"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": "llama-3.3-70b-versatile",
            "messages": [["role": "user", "content": "\(prompt)\nTexto: \(texto)"]],
            "response_format": ["type": "json_object"]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: request)

        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String,
           let contentData = content.data(using: .utf8) {

            let innerJson = try JSONSerialization.jsonObject(with: contentData) as? [String: Any]
            let matches = innerJson?["matches"] as? [String] ?? []
            return matches.map { $0.lowercased() }.filter { frasesClave.contains($0) }
        }
        return []
    }
}

#Preview {
    AsistenceVoice().environmentObject(NavModel())
}
