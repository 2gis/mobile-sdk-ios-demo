/// Source of positioning services.
enum PositioningServicesSource: String, CaseIterable {
	/// Use the default positioning source (SDK).
	case `default`
	/// Use DgisNMEAGenerator as the positioning source.
	case generator
}
