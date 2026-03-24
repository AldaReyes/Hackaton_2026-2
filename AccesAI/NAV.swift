//
//  NAV.swift
//  AccesAI
//
//  Created by DEVELOP02 on 23/03/26.
//

import SwiftUI

struct Nav: View {
    @StateObject var navModel = NavModel()
    private let initialSelectedTab: Int?

    init(index: Int? = nil) {
        _navModel = StateObject(wrappedValue: NavModel())
        self.initialSelectedTab = index
    }

    var body: some View {
        TabView(selection: $navModel.selectedTab) {
            CDMXMap()
                .environmentObject(navModel)
                .tabItem {
                    Image(systemName: "map")
                    Text("CDMX")
                }
                .tag(0)
            UniversityMap()
                .environmentObject(navModel)
                .tabItem {
                    Image(systemName: "book")
                    Text("Acatlan")
                }
                .tag(1)
            UniversityMap()
                .environmentObject(navModel)
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("Asistencia Voz")
                }
                .tag(2)
            UniversityMap()
                .environmentObject(navModel)
                .tabItem {
                    Image(systemName: "text.page.badge.magnifyingglass")
                    Text("Interprete")
                }
                .tag(3)
            Informacion()
                .environmentObject(navModel)
                .tabItem {
                    Image(systemName: "info")
                    Text("Informacion")
                }
                .tag(4)
        }
    }
}

struct Nav_Previews: PreviewProvider {
    static var previews: some View {
        Nav()
    }
}
