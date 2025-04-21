import DGis
import SwiftUI

struct CustomZoomView: View {
	typealias Color = SwiftUI.Color

	private enum Constants {
		static let buttonWidth: CGFloat = 48
		static let buttonHeight: CGFloat = 48
		static let dividerHeight: CGFloat = 1
		static let iconSize: CGSize = .init(width: 14, height: 14)
	}

	@ObservedObject private var viewModel: CustomZoomViewModel

	init(map: Map) {
		self.viewModel = CustomZoomViewModel(map: map)
	}

	public var body: some View {
		VStack(spacing: 0) {
			self.zoomInButton
			Divider()
				.frame(width: Constants.buttonWidth, height: Constants.dividerHeight)
				.background(Color(UIColor.secondarySystemBackground))
			self.zoomOutButton
		}
		.frame(width: Constants.buttonWidth, height: Constants.buttonHeight * 2 + Constants.dividerHeight)
		.clipShape(RoundedRectangle(cornerRadius: 8))
		.shadow(radius: 2)
	}

	private var zoomInIconColor: Color {
		self.viewModel.zoomInEnabled ? .primary : .secondary
	}

	private var zoomOutIconColor: Color {
		self.viewModel.zoomOutEnabled ? .primary : .secondary
	}

	private var zoomInButton: some View {
		Button(action: {}) {
			ZStack {
				Color(UIColor.systemBackground)
				Image(systemName: "plus")
					.renderingMode(.template)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: Constants.iconSize.width, height: Constants.iconSize.height)
					.foregroundColor(self.zoomInIconColor)
			}
		}
		.contentShape(Rectangle())
		.frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
		.buttonStyle(HighlightedButtonStyle(highlighted: self.$viewModel.zoomInHighlighted, applyOverlay: true))
	}

	private var zoomOutButton: some View {
		Button(action: {}) {
			ZStack {
				Color(UIColor.systemBackground)
				Image(systemName: "minus")
					.renderingMode(.template)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: Constants.iconSize.width, height: Constants.iconSize.height)
					.foregroundColor(self.zoomOutIconColor)
			}
		}
		.contentShape(Rectangle())
		.frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
		.buttonStyle(HighlightedButtonStyle(highlighted: self.$viewModel.zoomOutHighlighted, applyOverlay: true))
	}
}
