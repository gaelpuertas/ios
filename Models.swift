import Foundation

struct Account: Codable {
    var authenticated: Bool?
    var email: String?
    var name: String?
    var premium: Bool?
    var webQuota: WebQuota?
    var credits: Int?

    enum CodingKeys: String, CodingKey {
        case authenticated, email, name, premium, credits
        case webQuota = "web_quota"
    }
}

struct WebQuota: Codable {
    var remaining: Int?
    var dailyRemaining: Int?
    var dailyLimit: Int?
    var resetsAt: String?
}

struct LiveStartResponse: Codable {
    let id: String
    let status: String?
    let result: QueryResult?
}

struct LiveStatusResponse: Codable {
    let id: String?
    let status: String?
    let result: QueryResult?
}

struct QueryResult: Codable {
    var placa: String?
    var vehiculo: Vehicle?
    var soat: Coverage?
    var rtm: Coverage?
    var fiscalia: Fiscalia?
    var progress: [String: String]?
    var vehicleNotice: String?
    var buscandoCoberturas: Bool?

    enum CodingKeys: String, CodingKey {
        case placa, vehiculo, soat, rtm, fiscalia, progress
        case vehicleNotice = "vehicle_notice"
        case buscandoCoberturas = "buscando_coberturas"
    }
}

struct Vehicle: Codable {
    var marca: String?
    var linea: String?
    var modelo: String?
    var vin: String?
    var cilindraje: String?
    var clase: String?
    var placa: String?

    enum CodingKeys: String, CodingKey {
        case marca, linea, modelo, vin, cilindraje, clase
        case placa
    }
}

struct Coverage: Codable {
    var disponible: Bool?
    var estado: String?
    var fechaVencimiento: String?
    var diasRestantes: Int?

    enum CodingKeys: String, CodingKey {
        case disponible, estado
        case fechaVencimiento = "fecha_vencimiento"
        case diasRestantes = "dias_restantes"
    }
}

struct Fiscalia: Codable {
    var disponible: Bool?
    var vinculado: Bool?
    var estado: String?
    var mensaje: String?
    var noticiaCriminal: String?
    var etapa: String?
    var ultimoActo: String?

    enum CodingKeys: String, CodingKey {
        case disponible, vinculado, estado, mensaje
        case noticiaCriminal = "noticia_criminal"
        case etapa
        case ultimoActo = "ultimo_acto"
    }
}
