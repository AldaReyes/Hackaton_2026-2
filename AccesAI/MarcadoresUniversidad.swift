//
//  MarcadoresUniversidad.swift
//  AccesAI
//
//  Created by DEVELOP02 on 23/03/26.
//

import Foundation
import CoreLocation

enum CategoriaMarcador: String, Codable, Hashable {
    case edificio
    case cafeteria
    case enfermeria
    case teatro
}

struct MarcadorUniversidad: Identifiable, Hashable {
    let id: UUID
    let titulo: String
    let coordenada: CLLocationCoordinate2D
    let descripcion: String?
    let categoria: CategoriaMarcador

    init(id: UUID = UUID(),
         titulo: String,
         coordenada: CLLocationCoordinate2D,
         descripcion: String? = nil,
         categoria: CategoriaMarcador) {
        self.id = id
        self.titulo = titulo
        self.coordenada = coordenada
        self.descripcion = descripcion
        self.categoria = categoria
    }

    static func == (lhs: MarcadorUniversidad, rhs: MarcadorUniversidad) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum MarcadoresUniversidad {
    // Lista estática de marcadores. Puedes añadir más elementos aquí.
    static let todos: [MarcadorUniversidad] = [
        // Entrada principal existente (la dejamos como edificio por defecto)
        MarcadorUniversidad(
            titulo: "Entrada principal",
            coordenada: CLLocationCoordinate2D(latitude: 19.482051941580036, longitude: -99.24465910512978),
            descripcion: "Acceso principal a la universidad",
            categoria: .edificio
        ),

        // Edificios
        MarcadorUniversidad(
            titulo: "Teatro Javier Barros Sierra",
            coordenada: CLLocationCoordinate2D(latitude: 19.48559610597107, longitude: -99.2482658392308),
            descripcion: "Edificio - Teatro",
            categoria: .teatro
        ),
        MarcadorUniversidad(
            titulo: "Edificio de gobierno",
            coordenada: CLLocationCoordinate2D(latitude: 19.48328615909903, longitude: -99.24756576246592),
            descripcion: "Edificio - Gobierno",
            categoria: .edificio
        ),
        MarcadorUniversidad(
            titulo: "UNAM, Centro de Desarrollo Tecnológico",
            coordenada: CLLocationCoordinate2D(latitude: 19.481999592138457, longitude: -99.24670617452631),
            descripcion: "Edificio - Centro de Desarrollo Tecnológico",
            categoria: .edificio
        ),
        MarcadorUniversidad(
            titulo: "iOS Lab FES Acatlán (CEDAM)",
            coordenada: CLLocationCoordinate2D(latitude: 19.48351172498062, longitude: -99.24519524933349),
            descripcion: "Edificio - Laboratorio iOS (CEDAM)",
            categoria: .edificio
        ),
        MarcadorUniversidad(
            titulo: "Enfermería",
            coordenada: CLLocationCoordinate2D(latitude: 19.48379589688257, longitude: -99.24802649748565),
            descripcion: "Edificio - Enfermería",
            categoria: .enfermeria
        ),
        MarcadorUniversidad(
            titulo: "Centro de Enseñanza de Idiomas FES Acatlán",
            coordenada: CLLocationCoordinate2D(latitude: 19.48576354866672, longitude: -99.24710276807411),
            descripcion: "Edificio - Centro de Enseñanza de Idiomas",
            categoria: .edificio
        ),

        // Cafeterías
        MarcadorUniversidad(
            titulo: "Tienda a4",
            coordenada: CLLocationCoordinate2D(latitude: 19.482438224787643, longitude: -99.24619272391921),
            descripcion: "Cafetería / Tienda",
            categoria: .cafeteria
        ),
        MarcadorUniversidad(
            titulo: "Cafe 8",
            coordenada: CLLocationCoordinate2D(latitude: 19.4839845322501, longitude: -99.2464076016313),
            descripcion: "Cafetería",
            categoria: .cafeteria
        ),
        MarcadorUniversidad(
            titulo: "Cuais",
            coordenada: CLLocationCoordinate2D(latitude: 19.482521306830048, longitude: -99.24561453783447),
            descripcion: "Cafetería",
            categoria: .cafeteria
        ),
        MarcadorUniversidad(
            titulo: "Cafeteria canchas",
            coordenada: CLLocationCoordinate2D(latitude: 19.483732979274553, longitude: -99.24492421192096),
            descripcion: "Cafetería",
            categoria: .cafeteria
        ),
        MarcadorUniversidad(
            titulo: "Cafe-Libreria",
            coordenada: CLLocationCoordinate2D(latitude: 19.485332707343705, longitude: -99.24614438378933),
            descripcion: "Cafetería / Librería",
            categoria: .cafeteria
        ),
        MarcadorUniversidad(
            titulo: "Cafeteria derecho",
            coordenada: CLLocationCoordinate2D(latitude: 19.484148255811416, longitude: -99.24770327596849),
            descripcion: "Cafetería",
            categoria: .cafeteria
        )
    ]
}
