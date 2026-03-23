//
//  UniversityMap.swift
//  AccesAI
//
//  Created by DEVELOP02 on 23/03/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct UniversityMap: View {
    // Coordenadas de la entrada principal solicitadas (actualizadas)
    private let mainEntranceCoordinate = CLLocationCoordinate2D(latitude: 19.482051941580036, longitude: -99.24465910512978)

    // Región de mapa controlada por estado para permitir zoom y panning
    @State private var region: MKCoordinateRegion

    // Estado para búsqueda (ahora para origen/destino)
    @State private var originText: String = ""
    @State private var destinationText: String = ""
    @State private var activeField: ActiveField? = nil
    @State private var filteredMarkers: [MarcadorUniversidad] = []
    @State private var showSuggestions: Bool = false

    enum ActiveField {
        case origin
        case destination
    }

    // Selección de marcadores para rutas
    @State private var selectedOrigin: MarcadorUniversidad?
    @State private var selectedDestination: MarcadorUniversidad?
    @State private var selectedMarker: MarcadorUniversidad?

    // Ruta calculada
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    @State private var isCalculatingRoute: Bool = false
    @State private var routeError: String?

    // Estado para mostrar hoja de emergencia
    @State private var isEmergencySheetPresented: Bool = false

    init() {
        let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
        _region = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 19.482051941580036, longitude: -99.24465910512978), span: span))
    }

    var body: some View {
        ZStack {
            Map(position: .constant(.region(region))) {
                // Marcadores
                ForEach(MarcadoresUniversidad.todos) { marcador in
                    Annotation(marcador.titulo, coordinate: marcador.coordenada) {
                        ZStack {
                            Circle()
                                .fill(color(for: marcador.categoria))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Circle()
                                        .stroke(selectedMarker?.id == marcador.id ? Color.yellow : Color.clear, lineWidth: 3)
                                )
                            Image(systemName: symbolName(for: marcador.categoria))
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .bold))
                        }
                        .onTapGesture {
                            selectMarker(marcador)
                        }
                        .accessibilityLabel(marcador.titulo)
                        .accessibilityHint(marcador.descripcion ?? "")
                    }
                }

                // Polyline de la ruta
                if routeCoordinates.count > 1 {
                    MapPolyline(coordinates: routeCoordinates)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .mapStyle(.standard)

            // Panel superior con selector de Origen/Destino y acciones
            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 12) {

                    // Contenedor de origen/destino + sugerencias
                    VStack(spacing: 8) {
                        // Campos Origen / Destino
                        VStack(spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.system(size: 8))
                                TextField("Origen", text: $originText)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .onTapGesture {
                                        activeField = .origin
                                        updateSuggestions(for: originText)
                                    }
                                    .onChange(of: originText) { _, newValue in
                                        activeField = .origin
                                        updateSuggestions(for: newValue)
                                        // Resolver automáticamente si hay coincidencia exacta
                                        resolveSelectionFromText(for: .origin, text: newValue)
                                    }
                                    .submitLabel(.done)
                                if !originText.isEmpty {
                                    Button {
                                        originText = ""
                                        selectedOrigin = nil
                                        updateSuggestions(for: "")
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                            HStack(spacing: 8) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 8))
                                TextField("Destino", text: $destinationText)
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                                    .onTapGesture {
                                        activeField = .destination
                                        updateSuggestions(for: destinationText)
                                    }
                                    .onChange(of: destinationText) { _, newValue in
                                        activeField = .destination
                                        updateSuggestions(for: newValue)
                                        // Resolver automáticamente si hay coincidencia exacta
                                        resolveSelectionFromText(for: .destination, text: newValue)
                                    }
                                    .submitLabel(.done)
                                if !destinationText.isEmpty {
                                    Button {
                                        destinationText = ""
                                        selectedDestination = nil
                                        updateSuggestions(for: "")
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }

                        // Lista de sugerencias bajo los campos
                        if showSuggestions && !filteredMarkers.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(filteredMarkers) { marcador in
                                    Button {
                                        applySuggestion(marcador)
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: symbolName(for: marcador.categoria))
                                                .foregroundStyle(.secondary)
                                            Text(marcador.titulo)
                                                .foregroundStyle(.primary)
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 10)
                                    }
                                    .buttonStyle(.plain)
                                    .background(Color(.systemBackground))
                                    .contentShape(Rectangle())

                                    if marcador.id != filteredMarkers.last?.id {
                                        Divider()
                                    }
                                }
                            }
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                            .transition(.opacity)
                        }

                        // Botones de acciones de ruta (solo Calcular y Limpiar)
                        HStack(spacing: 10) {
                            // Botón Calcular
                            Button {
                                Task { await calculateRouteIfPossible() }
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                                        .font(.headline)
                                    Text("Calcular")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                }
                                .frame(width: 84, height: 56)
                            }
                            .buttonStyle(.borderedProminent)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .disabled(selectedOrigin == nil || selectedDestination == nil)

                            // Botón Limpiar
                            Button(role: .destructive) {
                                clearAll()
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "xmark")
                                        .font(.headline)
                                    Text("Limpiar")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                }
                                .frame(width: 84, height: 56)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)

                    // Menú lateral eliminado por solicitud
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                if isCalculatingRoute {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Calculando ruta...")
                    }
                    .padding(.horizontal, 16)
                } else if let routeError {
                    Text(routeError)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
                }

                Spacer()
            }

            // Botones flotantes esquina inferior derecha
            VStack {
                Spacer()
                HStack(spacing: 10) {
                    Spacer()

                    // Botón de emergencia
                    Button {
                        // Mostrar hoja con información de emergencia
                        isEmergencySheetPresented = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title2)
                            Text("Emergencia")
                                .font(.caption2)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.25), in: Capsule())
                        .overlay(
                            Capsule().stroke(Color.red.opacity(0.6), lineWidth: 1)
                        )
                        .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)

                    // Botón para regresar al marcador de la entrada principal
                    Button {
                        returnToMainEntrance()
                    } label: {
                        Image(systemName: "location.north.line")
                            .font(.title2)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.20), in: Capsule())
                            .overlay(Capsule().stroke(Color.blue.opacity(0.6), lineWidth: 1))
                            .foregroundStyle(.blue)
                            .accessibilityLabel("Regresar a Entrada principal")
                    }
                    .buttonStyle(.plain)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            // Reajusta región con zoom más cercano al cargar
            withAnimation {
                region = MKCoordinateRegion(center: mainEntranceCoordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
            }
            // Selecciona por defecto la entrada principal
            if let entrada = MarcadoresUniversidad.todos.first(where: { $0.titulo.localizedCaseInsensitiveContains("Entrada principal") }) {
                selectedMarker = entrada
                selectedOrigin = entrada
                originText = entrada.titulo
            }
        }
        .sheet(isPresented: $isEmergencySheetPresented) {
            EmergencyInfoSheet()
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Helpers de búsqueda/sugerencias
    private func updateSuggestions(for text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let activeField else {
            filteredMarkers = []
            showSuggestions = false
            return
        }

        if trimmed.isEmpty {
            filteredMarkers = []
            showSuggestions = false
            // Si se borra el texto, también limpiamos la selección del campo activo
            switch activeField {
            case .origin: selectedOrigin = nil
            case .destination: selectedDestination = nil
            }
            return
        }

        filteredMarkers = MarcadoresUniversidad.todos.filter { $0.titulo.localizedCaseInsensitiveContains(trimmed) }
        // Si el otro campo ya está seleccionado, opcionalmente podríamos excluirlo de la lista
        switch activeField {
        case .origin:
            if let dest = selectedDestination {
                filteredMarkers.removeAll { $0.id == dest.id }
            }
        case .destination:
            if let orig = selectedOrigin {
                filteredMarkers.removeAll { $0.id == orig.id }
            }
        }

        showSuggestions = true
    }

    private func resolveSelectionFromText(for field: ActiveField, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            switch field {
            case .origin: selectedOrigin = nil
            case .destination: selectedDestination = nil
            }
            return
        }

        if let match = MarcadoresUniversidad.todos.first(where: { $0.titulo.compare(trimmed, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }) {
            switch field {
            case .origin:
                selectedOrigin = match
            case .destination:
                selectedDestination = match
            }
        } else {
            switch field {
            case .origin: selectedOrigin = nil
            case .destination: selectedDestination = nil
            }
        }
    }

    private func applySuggestion(_ marcador: MarcadorUniversidad) {
        guard let activeField else { return }
        switch activeField {
        case .origin:
            selectedOrigin = marcador
            originText = marcador.titulo
            focus(on: marcador.coordenada, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        case .destination:
            selectedDestination = marcador
            destinationText = marcador.titulo
            focus(on: marcador.coordenada, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        }
        hideSuggestions()
    }

    private func hideSuggestions() {
        showSuggestions = false
        filteredMarkers = []
    }

    // MARK: - Helpers de selección y enfoque
    private func selectMarker(_ marcador: MarcadorUniversidad) {
        selectedMarker = marcador
        withAnimation {
            region = MKCoordinateRegion(center: marcador.coordenada,
                                        span: MKCoordinateSpan(latitudeDelta: 0.0012, longitudeDelta: 0.0012))
        }
    }

    private func focus(on coordinate: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        withAnimation {
            region = MKCoordinateRegion(center: coordinate, span: span)
        }
    }

    private func returnToMainEntrance() {
        // Limpia ruta y vuelve a la entrada principal
        clearRoute()
        if let entrada = MarcadoresUniversidad.todos.first(where: { $0.titulo.localizedCaseInsensitiveContains("Entrada principal") }) {
            selectedMarker = entrada
            withAnimation {
                region = MKCoordinateRegion(center: entrada.coordenada,
                                            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
            }
            // Opcional: establecer como origen al volver
            selectedOrigin = entrada
            originText = entrada.titulo
            hideSuggestions()
        } else {
            withAnimation {
                region = MKCoordinateRegion(center: mainEntranceCoordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
            }
        }
    }

    private func swapOriginDestination() {
        let tempMarker = selectedOrigin
        selectedOrigin = selectedDestination
        selectedDestination = tempMarker

        let tempText = originText
        originText = destinationText
        destinationText = tempText
    }

    // MARK: - Ruta con MKDirections
    private func calculateRouteIfPossible() async {
        routeError = nil
        guard let origin = selectedOrigin, let destination = selectedDestination else { return }
        isCalculatingRoute = true
        defer { isCalculatingRoute = false }

        let request = MKDirections.Request()
        let sourceItem = MKMapItem(location: CLLocation(latitude: origin.coordenada.latitude,
                                                        longitude: origin.coordenada.longitude),
                                   address: nil)
        let destinationItem = MKMapItem(location: CLLocation(latitude: destination.coordenada.latitude,
                                                             longitude: destination.coordenada.longitude),
                                        address: nil)

        request.source = sourceItem
        request.destination = destinationItem
        request.transportType = .walking
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            guard let route = response.routes.first else {
                // Fallback: línea recta entre origen y destino
                routeCoordinates = [origin.coordenada, destination.coordenada]
                routeError = "No se encontró una ruta. Se muestra línea directa."
                // Enfocar a ambos puntos
                focusToFit(coordinates: routeCoordinates)
                return
            }
            routeCoordinates = route.polyline.coordinates
            // Enfocar la región a la ruta
            let rect = route.polyline.boundingMapRect
            let span = rect.span
            let center = rect.center
            withAnimation {
                region = MKCoordinateRegion(center: center, span: span)
            }
        } catch {
            // Fallback: línea recta entre origen y destino
            routeCoordinates = [origin.coordenada, destination.coordenada]
            routeError = "No se pudo calcular con Mapas. Se muestra línea directa."
            focusToFit(coordinates: routeCoordinates)
        }
    }

    private func clearRoute() {
        routeCoordinates = []
        routeError = nil
    }

    private func clearAll() {
        // Limpia ruta
        clearRoute()
        originText = ""
        destinationText = ""
        selectedOrigin = nil
        selectedDestination = nil
        hideSuggestions()
    }

    private func focusToFit(coordinates: [CLLocationCoordinate2D]) {
        guard coordinates.count >= 2 else { return }
        var minLat = coordinates.first!.latitude
        var maxLat = coordinates.first!.latitude
        var minLon = coordinates.first!.longitude
        var maxLon = coordinates.first!.longitude

        for c in coordinates {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLon = min(minLon, c.longitude)
            maxLon = max(maxLon, c.longitude)
        }

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2.0,
                                            longitude: (minLon + maxLon) / 2.0)
        let padding = 0.0008
        let span = MKCoordinateSpan(latitudeDelta: max((maxLat - minLat) + padding, 0.0008),
                                    longitudeDelta: max((maxLon - minLon) + padding, 0.0008))
        withAnimation {
            region = MKCoordinateRegion(center: center, span: span)
        }
    }

    // MARK: - Helpers de ícono/estilo
    private func symbolName(for categoria: CategoriaMarcador) -> String {
        switch categoria {
        case .edificio:
            return "building.2.fill"
        case .cafeteria:
            return "cup.and.saucer.fill"
        case .enfermeria:
            return "cross.case.fill" // Alternativa: "medical.cross"
        case .teatro:
            return "theatermasks.fill"
        }
    }

    private func color(for categoria: CategoriaMarcador) -> Color {
        switch categoria {
        case .edificio:
            return Color.blue
        case .cafeteria:
            return Color.brown
        case .enfermeria:
            return Color.red
        case .teatro:
            return Color.purple
        }
    }
}

// MARK: - Extensiones de utilidad
private extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: Int(pointCount))
        getCoordinates(&coords, range: NSRange(location: 0, length: Int(pointCount)))
        return coords
    }
}

private extension MKMapRect {
    var center: CLLocationCoordinate2D {
        MKMapPoint(x: midX, y: midY).coordinate
    }

    var span: MKCoordinateSpan {
        // Convertir esquinas a coordenadas y obtener deltas
        let topLeft = MKMapPoint(x: minX, y: minY).coordinate
        let bottomRight = MKMapPoint(x: maxX, y: maxY).coordinate

        // Deltas absolutos
        let latitudeDelta = abs(topLeft.latitude - bottomRight.latitude)
        let longitudeDelta = abs(topLeft.longitude - bottomRight.longitude)

        // Añadimos un mínimo para evitar valores demasiado pequeños
        let minDelta = 0.0008
        return MKCoordinateSpan(latitudeDelta: max(minDelta, latitudeDelta),
                                longitudeDelta: max(minDelta, longitudeDelta))
    }
}

// Hoja de información de emergencia
private struct EmergencyInfoSheet: View {
    // Estado editable de la información
    @State private var isEditing: Bool = false

    @State private var nombre: String = "Juan Pérez"
    @State private var afeccionesMedicas: String = "Asma"
    @State private var grupoSanguineo: String = "O+"
    @State private var alergias: String = "Penicilina"
    @State private var peso: String = "72 kg"
    @State private var altura: String = "1.75 m"
    @State private var edad: String = "28 años"
    @State private var direccion: String = "Av. Principal #123, Ciudad"

    var body: some View {
        NavigationStack {
            Group {
                if isEditing {
                    Form {
                        Section(header: Text("Información personal")) {
                            TextField("Nombre", text: $nombre)
                            TextField("Edad", text: $edad)
                            TextField("Dirección", text: $direccion)
                        }
                        Section(header: Text("Salud")) {
                            TextField("Afecciones médicas", text: $afeccionesMedicas)
                            TextField("Grupo sanguíneo", text: $grupoSanguineo)
                            TextField("Alergias", text: $alergias)
                            TextField("Peso", text: $peso)
                            TextField("Altura", text: $altura)
                        }
                    }
                } else {
                    List {
                        Section(header: Text("Información personal")) {
                            HStack {
                                Text("Nombre")
                                Spacer()
                                Text(nombre).foregroundStyle(.secondary)
                            }
                            HStack {
                                Text("Edad")
                                Spacer()
                                Text(edad).foregroundStyle(.secondary)
                            }
                            HStack {
                                Text("Dirección")
                                Spacer()
                                Text(direccion).foregroundStyle(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }
                        }

                        Section(header: Text("Salud")) {
                            HStack {
                                Text("Afecciones médicas")
                                Spacer()
                                Text(afeccionesMedicas).foregroundStyle(.secondary)
                            }
                            HStack {
                                Text("Grupo sanguíneo")
                                Spacer()
                                Text(grupoSanguineo).foregroundStyle(.secondary)
                            }
                            HStack {
                                Text("Alergias")
                                Spacer()
                                Text(alergias).foregroundStyle(.secondary)
                            }
                            HStack {
                                Text("Peso")
                                Spacer()
                                Text(peso).foregroundStyle(.secondary)
                            }
                            HStack {
                                Text("Altura")
                                Spacer()
                                Text(altura).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Emergencia")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Guardar" : "Editar") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    UniversityMap()
}
