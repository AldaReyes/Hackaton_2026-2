import Foundation
import CoreLocation

enum CategoriaMarcadorCDMX: String, Codable, Hashable {
    case edificio       // Alcaldías
    case tren           // Metro
    case autobus        // Metrobús
    case universidad    // Universidades
}

struct MarcadorCDMX: Identifiable, Hashable, Codable {
    let id: UUID
    let titulo: String
    let coordenada: CLLocationCoordinate2D
    let descripcion: String?
    let categoria: CategoriaMarcadorCDMX
    let accesos: [Acceso]

    init(id: UUID = UUID(),
         titulo: String,
         coordenada: CLLocationCoordinate2D,
         descripcion: String? = nil,
         categoria: CategoriaMarcadorCDMX,
         accesos: [Acceso] = []) {
        self.id = id
        self.titulo = titulo
        self.coordenada = coordenada
        self.descripcion = descripcion
        self.categoria = categoria
        self.accesos = accesos
    }

    static func == (lhs: MarcadorCDMX, rhs: MarcadorCDMX) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    private enum CodingKeys: String, CodingKey {
        case id, titulo, latitude, longitude, descripcion, categoria, accesos
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        titulo = try container.decode(String.self, forKey: .titulo)
        let lat = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let lon = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        coordenada = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        descripcion = try container.decodeIfPresent(String.self, forKey: .descripcion)
        categoria = try container.decode(CategoriaMarcadorCDMX.self, forKey: .categoria)
        accesos = try container.decodeIfPresent([Acceso].self, forKey: .accesos) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(titulo, forKey: .titulo)
        try container.encode(coordenada.latitude, forKey: .latitude)
        try container.encode(coordenada.longitude, forKey: .longitude)
        try container.encodeIfPresent(descripcion, forKey: .descripcion)
        try container.encode(categoria, forKey: .categoria)
        try container.encode(accesos, forKey: .accesos)
    }
}

enum MarcadoresCDMX {
    static let todos: [MarcadorCDMX] = [
        // Estaciones del Metro (categoría: tren)
        MarcadorCDMX(
            titulo: "Metro Cuatro Caminos",
            coordenada: CLLocationCoordinate2D(latitude: 19.4746, longitude: -99.2150),
            descripcion: "Línea 2",
            categoria: .tren,
            accesos: [.policia, .sillaRuedas]
        ),
        MarcadorCDMX(
            titulo: "Metro Bellas Artes",
            coordenada: CLLocationCoordinate2D(latitude: 19.4353, longitude: -99.1412),
            descripcion: "Líneas 2 y 8",
            categoria: .tren,
            accesos: [.policia, .sillaRuedas]
        ),
        MarcadorCDMX(
            titulo: "Metro El Rosario",
            coordenada: CLLocationCoordinate2D(latitude: 19.5042, longitude: -99.2016),
            descripcion: "Líneas 6 y 7",
            categoria: .tren,
            accesos: [.policia, .sillaRuedas]
        ),
        MarcadorCDMX(
            titulo: "Metro Hidalgo",
            coordenada: CLLocationCoordinate2D(latitude: 19.4366, longitude: -99.1470),
            descripcion: "Líneas 2 y 3",
            categoria: .tren,
            accesos: [.policia, .sillaRuedas]
        ),
        MarcadorCDMX(
            titulo: "Metro Universidad",
            coordenada: CLLocationCoordinate2D(latitude: 19.3130, longitude: -99.1824),
            descripcion: "Terminal sur de Línea 3",
            categoria: .tren,
            accesos: [.policia, .sillaRuedas]
        ),
        MarcadorCDMX(
            titulo: "Metro Nezahualcóyotl (cercana a FES Aragón)",
            coordenada: CLLocationCoordinate2D(latitude: 19.4809, longitude: -99.0206),
            descripcion: "Línea B; estación más cercana a FES Aragón",
            categoria: .tren,
            accesos: [.policia, .sillaRuedas]
        ),

        // Estaciones de Metrobús (categoría: autobus)
        MarcadorCDMX(
            titulo: "Metrobús Indios Verdes",
            coordenada: CLLocationCoordinate2D(latitude: 19.4955, longitude: -99.1199),
            descripcion: "Terminal norte (varias líneas)",
            categoria: .autobus,
            accesos: [.sillaRuedas, .policia, .botonPanico]
        ),
        MarcadorCDMX(
            titulo: "Metrobús La Raza",
            coordenada: CLLocationCoordinate2D(latitude: 19.4639, longitude: -99.1342),
            descripcion: "Conexión con Línea 1 del Metro",
            categoria: .autobus,
            accesos: [.sillaRuedas, .policia, .botonPanico]
        ),
        MarcadorCDMX(
            titulo: "Metrobús Buenavista",
            coordenada: CLLocationCoordinate2D(latitude: 19.4470, longitude: -99.1524),
            descripcion: "Conexión con tren suburbano",
            categoria: .autobus,
            accesos: [.sillaRuedas, .policia, .botonPanico]
        ),
        MarcadorCDMX(
            titulo: "Metrobús Reforma",
            coordenada: CLLocationCoordinate2D(latitude: 19.4296, longitude: -99.1731),
            descripcion: "Corredor Paseo de la Reforma",
            categoria: .autobus,
            accesos: [.sillaRuedas, .policia, .botonPanico]
        ),
        MarcadorCDMX(
            titulo: "Metrobús Insurgentes",
            coordenada: CLLocationCoordinate2D(latitude: 19.4263, longitude: -99.1620),
            descripcion: "Línea 1 sobre Av. Insurgentes",
            categoria: .autobus,
            accesos: [.sillaRuedas, .policia, .botonPanico]
        ),
        MarcadorCDMX(
            titulo: "Metrobús Doctor Gálvez",
            coordenada: CLLocationCoordinate2D(latitude: 19.3457, longitude: -99.1860),
            descripcion: "Línea 1 al sur de la ciudad",
            categoria: .autobus,
            accesos: [.sillaRuedas, .policia, .botonPanico]
        ),

        // Alcaldías (categoría: edificio)
        MarcadorCDMX(
            titulo: "Alcaldía Miguel Hidalgo",
            coordenada: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.2009),
            descripcion: "Sede de la Alcaldía Miguel Hidalgo",
            categoria: .edificio,
            accesos: [.sillaRuedas, .ayudaInvidentes, .policia, .botonPanico]
        ),
        MarcadorCDMX(
            titulo: "Alcaldía Cuauhtémoc",
            coordenada: CLLocationCoordinate2D(latitude: 19.4436, longitude: -99.1508),
            descripcion: "Sede de la Alcaldía Cuauhtémoc",
            categoria: .edificio,
            accesos: [.sillaRuedas, .ayudaInvidentes, .policia, .botonPanico]
        ),
        MarcadorCDMX(
            titulo: "Alcaldía Benito Juárez",
            coordenada: CLLocationCoordinate2D(latitude: 19.3834, longitude: -99.1620),
            descripcion: "Sede de la Alcaldía Benito Juárez",
            categoria: .edificio,
            accesos: [.sillaRuedas, .ayudaInvidentes, .policia, .botonPanico]
        ),
        MarcadorCDMX(
            titulo: "Alcaldía Azcapotzalco",
            coordenada: CLLocationCoordinate2D(latitude: 19.4870, longitude: -99.1872),
            descripcion: "Sede de la Alcaldía Azcapotzalco",
            categoria: .edificio,
            accesos: [.sillaRuedas, .ayudaInvidentes, .policia, .botonPanico]
        ),
        MarcadorCDMX(
            titulo: "Alcaldía Iztacalco",
            coordenada: CLLocationCoordinate2D(latitude: 19.3959, longitude: -99.0979),
            descripcion: "Sede de la Alcaldía Iztacalco",
            categoria: .edificio,
            accesos: [.sillaRuedas, .ayudaInvidentes, .policia, .botonPanico]
        ),

        // Universidades (categoría: universidad)
        MarcadorCDMX(
            titulo: "FES Acatlán",
            coordenada: CLLocationCoordinate2D(latitude: 19.4827, longitude: -99.2474),
            descripcion: "UNAM FES Acatlán",
            categoria: .universidad,
            accesos: [.sillaRuedas, .ayudaInvidentes, .policia, .botonPanico]

        ),
        MarcadorCDMX(
            titulo: "FES Aragón",
            coordenada: CLLocationCoordinate2D(latitude: 19.4879, longitude: -99.0208),
            descripcion: "UNAM FES Aragón",
            categoria: .universidad,
            accesos: [.sillaRuedas, .ayudaInvidentes, .policia, .botonPanico]

        ),
        MarcadorCDMX(
            titulo: "Ciudad Universitaria (CU)",
            coordenada: CLLocationCoordinate2D(latitude: 19.3324, longitude: -99.1860),
            descripcion: "UNAM, Rectoría / Las Islas",
            categoria: .universidad,
            accesos: [.sillaRuedas, .ayudaInvidentes, .policia, .botonPanico]

        ),
        MarcadorCDMX(
            titulo: "FES Iztacala",
            coordenada: CLLocationCoordinate2D(latitude: 19.5577, longitude: -99.2367),
            descripcion: "UNAM FES Iztacala",
            categoria: .universidad,
            accesos: [.sillaRuedas, .ayudaInvidentes, .policia, .botonPanico]

        ),
        MarcadorCDMX(
            titulo: "UAM Azcapotzalco",
            coordenada: CLLocationCoordinate2D(latitude: 19.5048, longitude: -99.1869),
            descripcion: "Universidad Autónoma Metropolitana Azcapotzalco",
            categoria: .universidad,
            accesos: [.sillaRuedas, .ayudaInvidentes, .policia, .botonPanico]

        ),
    ]
}
