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

struct Informacion: View {
    enum Campus: String, CaseIterable, Identifiable {
        case acatlan = "Acatlán"
        case cdmx = "CDMX"
        var id: String { rawValue }
    }

    @State private var campusSeleccionado: Campus = .acatlan
    @State private var textoBusqueda: String = ""
    @State private var estaEscuchando: Bool = false

    // Reconocedor de voz
    @StateObject private var speechRecognizer = SpeechRecognizer()

    // Navegación
    @State private var marcadorSeleccionado: (any MarcadorComun)?

    // Control de detalle
    @State private var detalleMarcador: (campus: Campus, id: UUID)?

    // Modelo de navegación/tab
    @EnvironmentObject var navModel: NavModel

    // Filtra los marcadores según búsqueda
    private var marcadoresAcatlan: [MarcadorUniversidad] {
        let texto = textoBusqueda.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let todos: [MarcadorUniversidad] = MarcadoresUniversidad.todos
        if texto.isEmpty { return todos }
        return todos.filter { $0.titulo.lowercased().contains(texto) }
    }

    private var marcadoresCDMX: [MarcadorCDMX] {
        let texto = textoBusqueda.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let todos: [MarcadorCDMX] = MarcadoresCDMX.todos
        if texto.isEmpty { return todos }
        return todos.filter { $0.titulo.lowercased().contains(texto) }
    }

    // Búsqueda cruzada
    private var busquedaVaciaEnAcatlan: Bool {
        textoBusqueda.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && marcadoresAcatlan.isEmpty
    }
    private var busquedaVaciaEnCDMX: Bool {
        textoBusqueda.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && marcadoresCDMX.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Selector de campus
                Picker("Campus", selection: $campusSeleccionado) {
                    ForEach(Campus.allCases) { campus in
                        Text(campus.rawValue).tag(campus)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Buscador con botón de micrófono
                HStack {
                    TextField("Buscar marcador...", text: $textoBusqueda)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .padding(10)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                        .onChange(of: textoBusqueda) { _, nuevoValor in
                            // Cambia de campus si la búsqueda está vacía aquí pero hay en el otro
                            if campusSeleccionado == .acatlan && busquedaVaciaEnAcatlan && !marcadoresCDMX.isEmpty {
                                campusSeleccionado = .cdmx
                            } else if campusSeleccionado == .cdmx && busquedaVaciaEnCDMX && !marcadoresAcatlan.isEmpty {
                                campusSeleccionado = .acatlan
                            }
                        }
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

                // Lista de marcadores como menú
                List {
                    Section(header: Text("Lugares importantes")) {
                        if campusSeleccionado == .acatlan {
                            ForEach(marcadoresAcatlan) { marcador in
                                NavigationLink(value: marcador.id) {
                                    VStack(alignment: .leading) {
                                        Text(marcador.titulo)
                                            .font(.headline)
                                        if let descripcion = marcador.descripcion, !descripcion.isEmpty {
                                            Text(descripcion)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        } else {
                            ForEach(marcadoresCDMX) { marcador in
                                NavigationLink(value: marcador.id) {
                                    VStack(alignment: .leading) {
                                        Text(marcador.titulo)
                                            .font(.headline)
                                        if let descripcion = marcador.descripcion, !descripcion.isEmpty {
                                            Text(descripcion)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationDestination(for: MarcadorUniversidad.ID.self) { markerID in
                    if let marcador = marcadoresAcatlan.first(where: { $0.id == markerID }) {
                        DetalleMarcadorView(
                            titulo: marcador.titulo,
                            descripcion: marcador.descripcion,
                            accesos: marcador.accesos,
                            campus: .acatlan,
                            onAbrirMapa: {
                                abrirMapa(campus: .acatlan, marcador: marcador)
                            }
                        )
                    }
                }
                .navigationDestination(for: MarcadorCDMX.ID.self) { markerID in
                    if let marcador = marcadoresCDMX.first(where: { $0.id == markerID }) {
                        DetalleMarcadorView(
                            titulo: marcador.titulo,
                            descripcion: marcador.descripcion,
                            accesos: marcador.accesos,
                            campus: .cdmx,
                            onAbrirMapa: {
                                abrirMapa(campus: .cdmx, marcador: marcador)
                            }
                        )
                    }
                }
            }
            .navigationTitle("Accesibilidad")
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
        // Ya no es necesario usar openURL.
    }
}

struct DetalleMarcadorView: View {
    var titulo: String
    var descripcion: String?
    var accesos: [Acceso]
    var campus: Informacion.Campus
    var onAbrirMapa: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(titulo)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            if let descripcion {
                Text(descripcion)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Divider().padding(.vertical)

            // Accesos y ayudas
            if !accesos.isEmpty {
                VStack(spacing: 12) {
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
                .padding(.vertical, 10)
            }

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
