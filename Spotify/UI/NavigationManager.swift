import SwiftUI

class NavigationManager: ObservableObject {
    @Published var currentPage: Page?
    
    func goTo(_ page: Page) {
        // Se sei già sulla stessa pagina, reimposti forzatamente per riattivare
        currentPage = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.currentPage = page
        }
    }
}
