//
//  MarcadoresUniversidad.swift
//  AccesAI
//
//  Created by DEVELOP02 on 23/03/26.
//

import Foundation
import CoreLocation

struct MarcadorUniversidad: Identifiable, Hashable {
    let id: UUID
    let titulo: String
    let coordenada: CLLocationCoordinate2D
    let descripcion: String?

    init(id: UUID = UUID(),
         titulo: String,
         coordenada: CLLocationCoordinate2D,
         descripcion: String? = nil) {
        self.id = id
        self.titulo = titulo
        self.coordenada = coordenada
        self.descripcion = descripcion
    }
}

enum MarcadoresUniversidad {
    // Lista estática de marcadores. Puedes añadir más elementos aquí.
    static let todos: [MarcadorUniversidad] = [
        MarcadorUniversidad(
            titulo: "Entrada principal",
            coordenada: CLLocationCoordinate2D(latitude: 19.482051941580036, longitude: -99.24465910512978),
            descripcion: "Acceso principal a la universidad"
        )
    ]
}
