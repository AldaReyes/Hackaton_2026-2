//
//  CDMXMap.swift
//  AccesAI
//
//  Created by DEVELOP02 on 23/03/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct CDMXMap: View {
    // Coordenada objetivo del botón de regreso: "Metro Cuatro Caminos"
    private var cuatroCaminosCoordinate: CLLocationCoordinate2D {
        MarcadoresCDMX.todos.first(where: { $0.titulo.localizedCaseInsensitiveContains("Metro Cuatro Caminos") })?.coordenada
        ?? CLLocationCoordinate2D(latitude: 19.4746, longitude: -99.2150)
    }

    // Región de mapa controlada por estado para permitir zoom y panning
    @State private var region: MKCoordinateRegion

    // Estado para búsqueda (origen/destino)
    @State private var originText: String = ""
    @State private var destinationText: String = ""
    @State private var activeField: ActiveField? = nil
    @State private var filteredMarkers: [MarcadorCDMX] = []
    @State private var showSuggestions: Bool = false

    enum ActiveField {
        case origin
        case destination
    }

    // Selección de marcadores para rutas
    @State private var selectedOrigin: MarcadorCDMX?
    @State private var selectedDestination: MarcadorCDMX?
    @State private var selectedMarker: MarcadorCDMX?

    // Ruta calculada
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    @State private var isCalculatingRoute: Bool = false
    @State private var routeError: String?

    init() {
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        _region = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332), span: span))
    }

    var body: some View {
        ZStack {
            Map(position: .constant(.region(region))) {
                // Marcadores
                ForEach(MarcadoresCDMX.todos) { marcador in
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

                        // Lista de sugerencias
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

                        // Botones de acciones de ruta
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

                    // Botón para regresar a "Metro Cuatro Caminos"
                    Button {
                        returnToCuatroCaminos()
                    } label: {
                        Image(systemName: "location.north.line")
                            .font(.title2)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.20), in: Capsule())
                            .overlay(Capsule().stroke(Color.blue.opacity(0.6), lineWidth: 1))
                            .foregroundStyle(.blue)
                            .accessibilityLabel("Regresar a Metro Cuatro Caminos")
                    }
                    .buttonStyle(.plain)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            // Centrar por defecto a "Metro Cuatro Caminos"
            withAnimation {
                region = MKCoordinateRegion(center: cuatroCaminosCoordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            }
            if let cuatro = MarcadoresCDMX.todos.first(where: { $0.titulo.localizedCaseInsensitiveContains("Metro Cuatro Caminos") }) {
                selectedMarker = cuatro
                selectedOrigin = cuatro
                originText = cuatro.titulo
            }
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
            switch activeField {
            case .origin: selectedOrigin = nil
            case .destination: selectedDestination = nil
            }
            return
        }

        filteredMarkers = MarcadoresCDMX.todos.filter { $0.titulo.localizedCaseInsensitiveContains(trimmed) }
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

        if let match = MarcadoresCDMX.todos.first(where: { $0.titulo.compare(trimmed, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }) {
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

    private func applySuggestion(_ marcador: MarcadorCDMX) {
        guard let activeField else { return }
        switch activeField {
        case .origin:
            selectedOrigin = marcador
            originText = marcador.titulo
            focus(on: marcador.coordenada, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        case .destination:
            selectedDestination = marcador
            destinationText = marcador.titulo
            focus(on: marcador.coordenada, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        }
        hideSuggestions()
    }

    private func hideSuggestions() {
        showSuggestions = false
        filteredMarkers = []
    }

    // MARK: - Helpers de selección y enfoque
    private func selectMarker(_ marcador: MarcadorCDMX) {
        selectedMarker = marcador
        withAnimation {
            region = MKCoordinateRegion(center: marcador.coordenada,
                                        span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
        }
    }

    private func focus(on coordinate: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        withAnimation {
            region = MKCoordinateRegion(center: coordinate, span: span)
        }
    }

    private func returnToCuatroCaminos() {
        clearRoute()
        if let cuatro = MarcadoresCDMX.todos.first(where: { $0.titulo.localizedCaseInsensitiveContains("Metro Cuatro Caminos") }) {
            selectedMarker = cuatro
            withAnimation {
                region = MKCoordinateRegion(center: cuatro.coordenada,
                                            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
            }
            selectedOrigin = cuatro
            originText = cuatro.titulo
            hideSuggestions()
        } else {
            withAnimation {
                region = MKCoordinateRegion(center: cuatroCaminosCoordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
            }
        }
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
                routeCoordinates = [origin.coordenada, destination.coordenada]
                routeError = "No se encontró una ruta. Se muestra línea directa."
                focusToFit(coordinates: routeCoordinates)
                return
            }
            routeCoordinates = route.polyline.coordinates
            let rect = route.polyline.boundingMapRect
            let span = rect.span
            let center = rect.center
            withAnimation {
                region = MKCoordinateRegion(center: center, span: span)
            }
        } catch {
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
    private func symbolName(for categoria: CategoriaMarcadorCDMX) -> String {
        switch categoria {
        case .edificio:
            return "building.2.fill"
        case .tren:
            return "tram.fill.tunnel"
        case .autobus:
            return "bus.fill"
        case .universidad:
            return "graduationcap.fill"
        }
    }

    private func color(for categoria: CategoriaMarcadorCDMX) -> Color {
        switch categoria {
        case .edificio:
            return Color.blue
        case .tren:
            return Color.orange
        case .autobus:
            return Color.red
        case .universidad:
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
        let topLeft = MKMapPoint(x: minX, y: minY).coordinate
        let bottomRight = MKMapPoint(x: maxX, y: maxY).coordinate
        let latitudeDelta = abs(topLeft.latitude - bottomRight.latitude)
        let longitudeDelta = abs(topLeft.longitude - bottomRight.longitude)
        let minDelta = 0.0008
        return MKCoordinateSpan(latitudeDelta: max(minDelta, latitudeDelta),
                                longitudeDelta: max(minDelta, longitudeDelta))
    }
}

#Preview {
    CDMXMap()
}
