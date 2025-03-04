//
//  taigApp.swift
//  taig
//
//  Created by MINJE JO on 3/4/25.
//

import SwiftUI

@main
struct taigApp: App {
    // CoreData 영속성 컨트롤러
    let persistenceController = PersistenceController.shared
    
    // 앱이 종료될 때 변경사항 저장
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                persistenceController.saveContext()
            }
        }
    }
}
