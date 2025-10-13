import SwiftUI

struct TerritoryView: View {
	private enum Constants {
		static let imageSize: CGSize = .init(width: 24, height: 24)
		static let actionButtonMinWidth: CGFloat = 44
		static let loadingArcSize: CGSize = .init(width: 18, height: 18)
		static let loagingArcStrokeWidth: CGFloat = 2
		static let loagingArcBackgroungStrokeWidth: CGFloat = 1
		static let stopIconSize: CGSize = .init(width: 4, height: 4)
		static let font: Font = .system(size: 8, weight: .semibold)
		static let accentColor: Color = .init("colors/dgis_green")
		static let secondaryColor: Color = .gray
	}

	@ObservedObject private var viewModel: TerritoryViewModel

	init(viewModel: TerritoryViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text(self.viewModel.title)

				Text(self.viewModel.status.description)
					.font(.footnote)
					.foregroundColor(Constants.secondaryColor)
			}
			Spacer()
			self.makeActionButton()
				.frame(minWidth: Constants.actionButtonMinWidth)
		}
	}

	@ViewBuilder
	private func makeActionButton() -> some View {
		switch self.viewModel.package.status {
		case .notInstalled, .paused, .hasUpdate:
			self.downloadButton
		case let .installing(progress: progress):
			self.makePauseButton(progress: progress)
		case .installed, .notCompatible:
			self.uninstallButton
		default:
			EmptyView()
		}
	}

	private var downloadButton: some View {
		VStack {
			Button(action: {
				self.viewModel.install()
			}, label: {
				Image(systemName: "icloud.and.arrow.down")
					.renderingMode(.template)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(
						width: Constants.imageSize.width,
						height: Constants.imageSize.height
					)
			})
			Text(self.viewModel.dataToLoad)
				.font(Constants.font)
				.foregroundColor(.accentColor)
		}
	}

	private var uninstallButton: some View {
		Button(action: {
			self.viewModel.isUninstallRequestShown = true
		}, label: {
			Image(systemName: "trash")
				.renderingMode(.template)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(
					width: Constants.imageSize.width,
					height: Constants.imageSize.height
				)
		})
		.actionSheet(isPresented: self.$viewModel.isUninstallRequestShown, content: {
			ActionSheet(
				title: Text("Delete \"\(self.viewModel.title)\"?"),
				buttons: [
					.destructive(Text("Delete"), action: { self.viewModel.uninstall() }),
					.cancel(),
				]
			)
		})
	}

	private func makePauseButton(progress: UInt8) -> some View {
		VStack {
			Button(action: {
				self.viewModel.pause()
			}, label: {
				ZStack(alignment: .center) {
					Circle()
						.stroke(Constants.secondaryColor, lineWidth: Constants.loagingArcBackgroungStrokeWidth)
						.frame(width: Constants.loadingArcSize.width, height: Constants.loadingArcSize.height)
						.background(Color.clear)
						.overlay(
							Circle()
								.trim(from: 0, to: CGFloat(progress) / 100)
								.stroke(Constants.accentColor, style: StrokeStyle(lineWidth: Constants.loagingArcStrokeWidth, lineCap: .round))
								.rotationEffect(.degrees(-90))
								.frame(width: Constants.loadingArcSize.width, height: Constants.loadingArcSize.height)
						)
					Image(systemName: "stop.fill")
						.renderingMode(.template)
						.resizable()
						.scaledToFit()
						.frame(width: Constants.stopIconSize.width, height: Constants.stopIconSize.height)
						.foregroundColor(Constants.accentColor)
				}
			})
			Text("\(progress)%")
				.font(Constants.font)
				.foregroundColor(Constants.accentColor)
		}
	}
}
