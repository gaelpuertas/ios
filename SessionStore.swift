import Foundation

@MainActor
final class SessionStore: ObservableObject {
    @Published var account: Account?
    @Published var error: String?

    func refresh() async {
        do { account = try await APIClient.shared.account() }
        catch APIError.unauthorized { account = nil }
        catch { error = error.localizedDescription }
    }
}
