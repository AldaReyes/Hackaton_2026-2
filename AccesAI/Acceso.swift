import Foundation

enum Acceso: String, CaseIterable, Codable, Hashable {
    case sillaRuedas
    case ayudaInvidentes
    case policia
    case botonPanico

    var nombre: String {
        switch self {
        case .sillaRuedas: return "Silla de ruedas"
        case .ayudaInvidentes: return "Ayuda a invidentes"
        case .policia: return "Policía"
        case .botonPanico: return "Botón de pánico"
        }
    }

    var icono: String {
        switch self {
        case .sillaRuedas: return "figure.roll"
        case .ayudaInvidentes: return "eye.slash"
        case .policia: return "shield.lefthalf.filled.badge.checkmark"
        case .botonPanico: return "bell.and.waves.left.and.right"
        }
    }
}
