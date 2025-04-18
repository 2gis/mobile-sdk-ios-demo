import DGis

enum AnchorPoint {
	case topLeading, top, topTrailing
	case leading, center, trailing
	case bottomLeading, bottom, bottomTrailing

	var value: DGis.Anchor {
		switch self {
		case .bottom: Anchor(x: 0, y: 0.5)
		case .bottomLeading: Anchor(x: -0.5, y: 0.5)
		case .bottomTrailing: Anchor(x: 0.5, y: -0.5)
		case .center: Anchor(x: 0, y: 0)
		case .leading: Anchor(x: -0.5, y: 0)
		case .top: Anchor(x: 0, y: -0.5)
		case .topLeading: Anchor(x: -0.5, y: -0.5)
		case .topTrailing: Anchor(x: 0.5, y: -0.5)
		case .trailing: Anchor(x: 0.5, y: 0)
		}
	}
}
