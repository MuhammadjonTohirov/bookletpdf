import SwiftUI
import Combine
import BookletCore

@MainActor
public class LanguageManager: ObservableObject {
    @Published public var currentLanguage: Language = UserSettings.language ?? .english
    private var cancellables = Set<AnyCancellable>()

    public init() {}

    public func onAppear() {
        guard cancellables.isEmpty else { return }

        UserSettings.languageDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newLanguage in
                guard let self, self.currentLanguage != newLanguage else { return }
                self.currentLanguage = newLanguage
            }
            .store(in: &cancellables)
    }

    func changeLanguage(_ language: Language) {
        DispatchQueue.main.async {
            UserSettings.language = language
        }
    }
}
