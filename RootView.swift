import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        NavigationStack {
            HomeView()
                .navigationTitle("VinSOAT")
                .task { await session.refresh() }
        }
        .tint(Color(red: 0.02, green: 0.45, blue: 0.43))
    }
}

struct HomeView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var plate = ""
    @State private var result: QueryResult?
    @State private var loading = false
    @State private var error: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                hero
                TextField("Digite la placa", text: $plate)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                Button(action: consult) {
                    Label(loading ? "Consultando…" : "Consultar vehículo", systemImage: "magnifyingglass")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(loading)
                if let error { Text(error).foregroundStyle(.red).font(.subheadline) }
                if let result { ResultView(result: result) }
            }
            .padding()
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tu vehículo siempre bajo control")
                .font(.largeTitle.bold())
            Text("Consulta SOAT, RTM, datos del vehículo y Fiscalía desde un solo lugar.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func consult() {
        loading = true; error = nil; result = nil
        Task {
            do {
                let start = try await APIClient.shared.startQuery(plate: plate)
                var status = try await APIClient.shared.queryStatus(id: start.id)
                for _ in 0..<60 where status.status != "complete" && status.status != "partial" && status.status != "failed" {
                    try await Task.sleep(for: .milliseconds(700))
                    status = try await APIClient.shared.queryStatus(id: start.id)
                }
                result = status.result
            } catch { self.error = error.localizedDescription }
            loading = false
        }
    }
}

struct ResultView: View {
    let result: QueryResult
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let vehicle = result.vehiculo {
                SectionCard(title: "Vehículo", icon: "car.fill") {
                    value("Placa", vehicle.placa)
                    value("Marca", vehicle.marca)
                    value("Línea", vehicle.linea)
                    value("Modelo", vehicle.modelo)
                    value("VIN", vehicle.vin)
                }
            }
            if let soat = result.soat { SectionCard(title: "SOAT", icon: "checkmark.shield.fill") { value("Estado", soat.estado); value("Vencimiento", soat.fechaVencimiento); value("Días restantes", soat.diasRestantes.map(String.init)) } }
            if let rtm = result.rtm { SectionCard(title: "RTM", icon: "wrench.and.screwdriver.fill") { value("Estado", rtm.estado); value("Vencimiento", rtm.fechaVencimiento); value("Días restantes", rtm.diasRestantes.map(String.init)) } }
            if let fiscalia = result.fiscalia { SectionCard(title: "Fiscalía", icon: "doc.text.magnifyingglass") { value("Estado", fiscalia.estado); value("Resultado", fiscalia.mensaje); value("Noticia criminal", fiscalia.noticiaCriminal); value("Etapa", fiscalia.etapa); value("Última actuación", fiscalia.ultimoActo) } }
        }
    }

    private func value(_ label: String, _ text: String?) -> some View {
        if let text, !text.isEmpty { return AnyView(HStack { Text(label).foregroundStyle(.secondary); Spacer(); Text(text).multilineTextAlignment(.trailing) }) }
        return AnyView(EmptyView())
    }
}

struct SectionCard<Content: View>: View {
    let title: String; let icon: String; @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { Label(title, systemImage: icon).font(.headline); content }
            .padding().frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
