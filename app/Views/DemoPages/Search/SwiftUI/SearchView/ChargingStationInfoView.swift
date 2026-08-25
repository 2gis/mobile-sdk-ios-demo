import DGis
import SwiftUI

struct ChargingStationInfoView: View {
	@SwiftUI.State private var isExpanded = false
	let station: ChargingStation

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Button(action: {
				self.isExpanded.toggle()
			}) {
				HStack {
					Text("Charging station")
						.font(.headline)
						.foregroundColor(.primary)
					Spacer()
					Text("\(self.station.aggregate.connectorsFree)/\(self.station.aggregate.connectorsTotal) free")
						.font(.subheadline)
						.foregroundColor(self.station.aggregate.isBusy ? .red : .green)
					Image(systemName: self.isExpanded ? "chevron.up" : "chevron.down")
						.foregroundColor(.primary)
				}
			}
			if self.isExpanded {
				HStack {
					Text("Status:")
					Text(self.station.aggregate.isActive ? "Active" : "Inactive")
						.foregroundColor(self.station.aggregate.isActive ? .green : .gray)
				}

				HStack {
					Text("Max power:")
					Spacer()
					Text("\(self.station.aggregate.power) kW")
						.font(.subheadline)
				}
				VStack(alignment: .leading) {
					Text("Connectors:")
						.font(.headline)
					ForEach(self.station.connectors, id: \.self) { connector in
						VStack(alignment: .leading) {
							Divider()
							Text("Type: \(connector.type)")
							Text("Power: \(connector.power) kW")
							Text("Price: \(connector.price)₽ per kWh")
							Text("Status:") + Text(connector.status.name).foregroundColor(connector.status.color)
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
