//
//  Informacion.swift
//  AccesAI
//
//  Created by DEVELOP02 on 24/03/26.
//

import SwiftUI
import Speech
import Combine
import CoreLocation

protocol MarcadorComun: Identifiable where ID == UUID {
    var titulo: String { get }
    var coordenada: CLLocationCoordinate2D { get }
    var descripcion: String? { get }
    var accesos: [Acceso] { get }
}

extension MarcadorUniversidad: MarcadorComun {}
extension MarcadorCDMX: MarcadorComun {}

enum Campus: String, CaseIterable, Identifiable {
    case acatlan = "Acatlán"
    case cdmx = "CDMX"
    var id: String { rawValue }
}

struct AnyMarcador: Identifiable {
    let id: UUID
    let titulo: String
    let descripcion: String?
    let accesos: [Acceso]
    let coordenada: CLLocationCoordinate2D
    let campus: Campus
    let original: any MarcadorComun

    init(universidad: MarcadorUniversidad) {
        self.id = universidad.id
        self.titulo = universidad.titulo
        self.descripcion = universidad.descripcion
        self.accesos = universidad.accesos
        self.coordenada = universidad.coordenada
        self.campus = .acatlan
        self.original = universidad
    }

    init(cdmx: MarcadorCDMX) {
        self.id = cdmx.id
        self.titulo = cdmx.titulo
        self.descripcion = cdmx.descripcion
        self.accesos = cdmx.accesos
        self.coordenada = cdmx.coordenada
        self.campus = .cdmx
        self.original = cdmx
    }
}

struct Informacion: View {
    @State private var textoBusqueda: String = ""
    @State private var estaEscuchando: Bool = false

    @StateObject private var speechRecognizer = SpeechRecognizer()

    @EnvironmentObject var navModel: NavModel

    // Combina todos los marcadores en un solo arreglo
    private var todosLosMarcadores: [AnyMarcador] {
        let univ = MarcadoresUniversidad.todos.map { AnyMarcador(universidad: $0) }
        let cdmx = MarcadoresCDMX.todos.map { AnyMarcador(cdmx: $0) }
        return univ + cdmx
    }

    // Filtrado sencillo (opcional)
    private var marcadoresFiltrados: [AnyMarcador] {
        let texto = textoBusqueda.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if texto.isEmpty { return todosLosMarcadores }
        return todosLosMarcadores.filter { $0.titulo.lowercased().contains(texto) }
    }

    var body: some View {

        ZStack {
            NavigationStack {
                VStack {
                    // Buscador con botón de micrófono
                    HStack {
                        TextField("Buscar marcador...", text: $textoBusqueda)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(10)
                            .background(Color.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                            )
                        Button {
                            if speechRecognizer.isAuthorized {
                                if estaEscuchando {
                                    speechRecognizer.stopRecording()
                                } else {
                                    speechRecognizer.startRecording { result in
                                        self.textoBusqueda = result
                                    }
                                }
                                estaEscuchando.toggle()
                            } else {
                                speechRecognizer.requestAuthorization()
                            }
                        } label: {
                            Image(systemName: estaEscuchando ? "mic.fill" : "mic")
                                .foregroundColor(estaEscuchando ? .red : .blue)
                                .font(.title2)
                                .padding(.horizontal, 6)
                        }
                    }
                    .padding([.horizontal, .bottom])

                    List {
                        Section(header: Text("Lugares importantes")) {
                            ForEach(marcadoresFiltrados) { marcador in
                                NavigationLink(value: marcador.id) {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(marcador.titulo)
                                                .font(.headline)
                                            Spacer()
                                            Text(marcador.campus.rawValue)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Capsule().fill(marcador.campus == .acatlan ? Color.blue.opacity(0.13) : Color.purple.opacity(0.13)))
                                        }
                                        if let descripcion = marcador.descripcion, !descripcion.isEmpty {
                                            Text(descripcion)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 8)
                                    .background(Color.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .navigationDestination(for: UUID.self) { markerID in
                        if let marcador = marcadoresFiltrados.first(where: { $0.id == markerID }) {
                            DetalleMarcadorView(
                                titulo: marcador.titulo,
                                descripcion: marcador.descripcion,
                                accesos: marcador.accesos,
                                campus: marcador.campus,
                                onAbrirMapa: {
                                    abrirMapa(campus: marcador.campus, marcador: marcador.original)
                                }
                            )
                        }
                    }
                }
                .navigationTitle("Accesibilidad")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.azulPastel, Color.verdePastel]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ).ignoresSafeArea()
                )
            }
        }
    }

    private func abrirMapa(campus: Campus, marcador: any MarcadorComun) {
        // Cambia el tab y comunica el marcador a centrar
        if campus == .acatlan {
            navModel.selectedTab = 1
        } else {
            navModel.selectedTab = 0
        }
        navModel.marcadorIDParaCentrar = marcador.id
        navModel.campusParaCentrar = campus
    }
}

struct DetalleMarcadorView: View {
    var titulo: String
    var descripcion: String?
    var accesos: [Acceso]
    var campus: Campus
    var onAbrirMapa: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(titulo)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(campus == .acatlan ? "Campus Acatlán" : "CDMX")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.vertical, 2)
                .padding(.horizontal, 8)
                .background(Capsule().fill(campus == .acatlan ? Color.blue.opacity(0.13) : Color.purple.opacity(0.13)))

            if let descripcion {
                Text(descripcion)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Divider().padding(.vertical)

            // Accesos y ayudas: SIEMPRE visible
            VStack(spacing: 12) {
                if accesos.isEmpty {
                    Text("Sin ayudas de accesibilidad registradas.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                } else {
                    HStack(spacing: 18) {
                        ForEach(accesos.prefix(2), id: \.self) { acceso in
                            AccesoIcono(nombre: acceso.icono, texto: acceso.nombre)
                        }
                    }
                    if accesos.count > 2 {
                        HStack(spacing: 18) {
                            ForEach(accesos.dropFirst(2), id: \.self) { acceso in
                                AccesoIcono(nombre: acceso.icono, texto: acceso.nombre)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 10)

            // Botón para abrir en el mapa correspondiente
            Button {
                onAbrirMapa()
            } label: {
                Label(
                    campus == .acatlan ? "Ver en mapa de Acatlán" : "Ver en mapa CDMX",
                    systemImage: "map"
                )
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.accentColor.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Detalle")
    }
}

struct AccesoIcono: View {
    var nombre: String
    var texto: String
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: nombre)
                .font(.system(size: 32))
                .foregroundColor(.accentColor)
            Text(texto)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(width: 90)
    }
}

// Reconocimiento de voz básico para búsqueda (se puede mejorar para producción)
class SpeechRecognizer: ObservableObject {
    @Published var isAuthorized: Bool = false
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-MX"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                self.isAuthorized = (authStatus == .authorized)
            }
        }
    }

    func startRecording(onResult: @escaping (String) -> Void) {
        stopRecording()

        let request = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        self.request = request

        recognitionTask = recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                onResult(result.bestTranscription.formattedString)
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopRecording()
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    func stopRecording() {
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request = nil
    }
}

#Preview {
    Informacion()
}
