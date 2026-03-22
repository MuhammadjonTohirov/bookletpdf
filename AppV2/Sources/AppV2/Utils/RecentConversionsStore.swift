import Foundation

final class RecentConversionsStore: @unchecked Sendable {
    static let shared = RecentConversionsStore()

    private let key = "com.bookletPdf.recentConversions"
    private let maxItems = 20

    private init() {}

    func load() -> [RecentConversion] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([RecentConversion].self, from: data)) ?? []
    }

    func add(_ item: RecentConversion) {
        var items = load()
        items.insert(item, at: 0)
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
        save(items)
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func save(_ items: [RecentConversion]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
