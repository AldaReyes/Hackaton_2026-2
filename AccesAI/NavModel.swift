import Foundation
import SwiftUI
import Combine

@MainActor
class NavModel: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var marcadorIDParaCentrar: UUID?
    @Published var campusParaCentrar: Informacion.Campus = .acatlan
}
