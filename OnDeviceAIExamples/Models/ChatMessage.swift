import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var isUser: Bool
    var text: String
}
