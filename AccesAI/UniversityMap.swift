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

    // Estado para búsqueda
    @State private var searchText: String = ""

    // Estado para mostrar hoja de emergencia
    @State private var isEmergencySheetPresented: Bool = false

    init() {
        let span = MKCoordinateSpan(latitudeDelta: 0.009, longitudeDelta: 0.009)
        _region = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 19.482051941580036, longitude: -99.24465910512978), span: span))
    }

    var body: some View {
        ZStack {
            Map(position: .constant(.region(region))) {
                // Usamos el repositorio de marcadores para pintar todos
                ForEach(MarcadoresUniversidad.todos) { marcador in
                    Annotation(marcador.titulo, coordinate: marcador.coordenada) {
                        ZStack {
                            Circle()
                                .fill(color(for: marcador.categoria))
                                .frame(width: 28, height: 28)
                            Image(systemName: symbolName(for: marcador.categoria))
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .bold))
                        }
                        .accessibilityLabel(marcador.titulo)
                        .accessibilityHint(marcador.descripcion ?? "")
                    }
                }
            }
            .mapStyle(.standard)

            // Panel superior de búsqueda con menú en caja redondeada
            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    // Panel de búsqueda
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField("Buscar lugares o direcciones", text: $searchText)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .submitLabel(.search)
                            .onSubmit {
                                // Acción de búsqueda
                                // Aquí puedes integrar MKLocalSearch con searchText
                            }

                        Button {
                            // Limpiar búsqueda
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .opacity(searchText.isEmpty ? 0 : 1)

                        Divider().frame(height: 20)

                        // Botón de instrucciones por voz (sin funcionalidad)
                        Button {
                            // Sin acción: placeholder
                        } label: {
                            Image(systemName: "mic.circle")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.primary)
                                .accessibilityLabel("Instrucciones por voz")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)

                    // Menú tipo sándwich en cuadro redondeado más grande
                    Menu {
                        Button {
                            // Acción 1
                        } label: {
                            Label("Lugares cercanos", systemImage: "mappin.and.ellipse")
                        }
                        Button {
                            // Acción 2
                        } label: {
                            Label("Mapa", systemImage: "map")
                        }
                        Button {
                            // Acción 3
                        } label: {
                            Label("Ajustes", systemImage: "gearshape")
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 22, weight: .bold))
                            Text("Menú")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

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

                    // Botón para centrar el mapa en la entrada principal (flecha)
                    Button {
                        withAnimation {
                            region = MKCoordinateRegion(center: mainEntranceCoordinate,
                                                        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
                        }
                    } label: {
                        Image(systemName: "location.north.line")
                            .font(.title2)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.20), in: Capsule())
                            .overlay(Capsule().stroke(Color.blue.opacity(0.6), lineWidth: 1))
                            .foregroundStyle(.blue)
                            .accessibilityLabel("Centrar mapa")
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
        }
        .sheet(isPresented: $isEmergencySheetPresented) {
            EmergencyInfoSheet()
                .presentationDetents([.medium, .large])
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

// Hoja de información de emergencia
private struct EmergencyInfoSheet: View {
    // Puedes conectar estos valores a un modelo o almacenamiento real si lo deseas
    private let nombre = "Juan Pérez"
    private let afeccionesMedicas = "Asma"
    private let grupoSanguineo = "O+"
    private let alergias = "Penicilina"
    private let peso = "72 kg"
    private let altura = "1.75 m"
    private let edad = "28 años"
    private let direccion = "Av. Principal #123, Ciudad"

    var body: some View {
        NavigationStack {
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
            .navigationTitle("Emergencia")
        }
    }
}

#Preview {
    UniversityMap()
}
