import Foundation

enum APIError: LocalizedError {
    case invalidPlate
    case unauthorized
    case noCredits
    case server(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidPlate: return "Escribe una placa válida."
        case .unauthorized: return "Inicia sesión para continuar."
        case .noCredits: return "No tienes consultas disponibles."
        case .server(let message): return message
        case .invalidResponse: return "El servidor devolvió una respuesta inválida."
        }
    }
}

final class APIClient {
    static let shared = APIClient()
    private let baseURL = URL(string: "https://vinsoat.com/api/v1/mobile")!
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    func account() async throws -> Account {
        try await request(path: "/account/", method: "GET", body: nil)
    }

    func startQuery(plate: String) async throws -> LiveStartResponse {
        let normalized = plate.uppercased().filter { $0.isLetter || $0.isNumber }
        guard normalized.count >= 5 && normalized.count <= 6 else { throw APIError.invalidPlate }
        let body = try encoder.encode(["placa": normalized, "tipo_consulta": "placas", "nivel": "advanced"])
        return try await request(path: "/live/consultations/", method: "POST", body: body)
    }

    func queryStatus(id: String) async throws -> LiveStatusResponse {
        try await request(path: "/live/consultations/\(id)/", method: "GET", body: nil)
    }

    private func request<T: Decodable>(path: String, method: String, body: Data?) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(path.trimmingCharacters(in: "/")))
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if body != nil { request.setValue("application/json", forHTTPHeaderField: "Content-Type") }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if http.statusCode == 401 { throw APIError.unauthorized }
        if http.statusCode == 402 { throw APIError.noCredits }
        guard (200..<300).contains(http.statusCode) else {
            let message = (try? JSONDecoder().decode([String: String].self, from: data))["detail"]
            throw APIError.server(message ?? "No fue posible completar la consulta.")
        }
        do { return try decoder.decode(T.self, from: data) }
        catch { throw APIError.invalidResponse }
    }
}
