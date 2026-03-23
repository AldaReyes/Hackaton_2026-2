//
//  NAV.swift
//  AccesAI
//
//  Created by DEVELOP02 on 23/03/26.
//


import SwiftUI

struct Nav: View {

    var body: some View {

        
        TabView
        {
            CDMXMap()
                .tabItem{
                    Image(systemName: "map")
                    Text("Mapa CDMX")
                }
                .tag(0)
            UniversityMap()
                .tabItem
                {
                    Image(systemName: "book")
                    Text("Mapa Acatlan")
                }
                .tag(1)
            UniversityMap()
                .tabItem
                {
                    Image(systemName: "mic.fill")
                    Text("Asistencia Voz")
                }
                .tag(2)
            UniversityMap()
                .tabItem
                {
                    Image(systemName: "text.page.badge.magnifyingglass")
                    Text("Interprete")
                }
                .tag(3)
        }
        
    }
}

struct Nav_Previews: PreviewProvider {
    static var previews: some View {
        Nav()
    }
}
