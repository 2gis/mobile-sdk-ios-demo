import SwiftUI
import DGis

struct ChargingStationInfoView: View {
	@SwiftUI.State private var isExpanded = false
	let station: ChargingStation

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Button(action: {
				self.isExpanded.toggle()
			}) {
				HStack {
					Text("Charging Station")
					.font(.headline)
					.foregroundColor(.primary)
					Spacer()
					Text("\(station.aggregate.connectorsFree)/\(station.aggregate.connectorsTotal) free")
					.font(.subheadline)
					.foregroundColor(station.aggregate.isBusy ? .red : .green)
					Image(systemName: self.isExpanded ? "chevron.up" : "chevron.down")
					.foregroundColor(.primary)
				}
			}
			if isExpanded {
				HStack {
					Text("Status:")
					Text(station.aggregate.isActive ? "Active" : "Inactive")
					.foregroundColor(station.aggregate.isActive ? .green : .gray)
				}

				HStack {
					Text("Max Power:")
					Spacer()
					Text("\(station.aggregate.power) kW")
						.font(.subheadline)
				}
				VStack(alignment: .leading) {
					Text("Connectors:")
					.font(.headline)
					ForEach(station.connectors, id: \.self) { connector in
						VStack(alignment: .leading) {
							Divider()
							Text("Type: \(connector.type)")
							Text("Power: \(connector.power) kW")
							Text("Price: \(connector.price)₽ per kWh")
							Text("Status: ") + Text(connector.status.name).foregroundColor(connector.status.color)
						}
					}
				}
			}
		}
		.padding()
		.cornerRadius(10)
		.overlay(
			RoundedRectangle(cornerRadius: 10)
			.stroke(Color.secondary, lineWidth: 1)
		)
	}
}
