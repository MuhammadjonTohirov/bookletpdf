import BookletPDFKit

extension BookletType {
    /// Localized string keys for the manual print workflow, in display order.
    var printingSteps: [String] {
        let prefix: String
        let stepCount: Int
        switch self {
        case .type2:
            prefix = "str.help_print2_step"
            stepCount = 9
        case .type4:
            prefix = "str.help_print4_step"
            stepCount = 11
        }
        return (1...stepCount).map { "\(prefix)\($0)" }
    }
}
