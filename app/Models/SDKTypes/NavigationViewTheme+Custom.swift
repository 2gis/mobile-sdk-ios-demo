import UIKit
import DGis

extension NavigationViewTheme {
	static var custom: NavigationViewTheme {
		var theme = NavigationViewTheme(
			colors: .init(
				primaryContent: UIColor(rgb: 0x1d3557),
				secondaryContent: UIColor(rgb: 0xC3C2C2),
				slightlyDimmedContent: .yellow,
				background: UIColor(rgb: 0xF1E9E9),
				accent: .blue,
				success: .green,
				warning: UIColor(rgb: 0x3c1642),
				dimmedSuccess: .green.withAlphaComponent(0.91),
				dimmedWarning: UIColor(rgb: 0x3c1642).withAlphaComponent(0.91),
				contentOnAccent: .gray,
				contentOnSuccess: .yellow,
				contentOnWarning: UIColor(rgb: 0xB1AE25),
				lightOverlayColor: .red.withAlphaComponent(0.06),
				mediumOverlayColor: .red.withAlphaComponent(0.09),
				strongOverlayColor: .red.withAlphaComponent(0.17)
			)
		)

		theme.dashboardTheme.backgroundColor = UIColor(rgb: 0xD7C1C1)

		theme.dashboardTheme.contentControlTheme.rightIconBackgroundColor = .white
		theme.dashboardTheme.contentControlTheme.backgroundColor = UIColor(rgb: 0xF1E9E9)
		theme.dashboardTheme.contentControlTheme.disclosureIndicatorColor = .red

		theme.cameraControlTheme.trackColor = .black
		theme.cameraControlTheme.progressColor = .white

		theme.messageBarControlTheme.activityIndicatorColor = .purple

		theme.mapControlsTheme.trafficControlTheme.lowJamsColor = .green
		theme.mapControlsTheme.trafficControlTheme.mediumJamsColor = .yellow
		theme.mapControlsTheme.trafficControlTheme.hightJamsColor = .purple

		theme.betterRouteControlTheme.progressBarColor = .purple

		theme.thermometerTheme.progressColor = .black
		theme.thermometerTheme.startPositionColor = .black
		theme.thermometerTheme.trafficLineDeepRedColor = .purple
		theme.thermometerTheme.trafficLineRedColor = .red
		theme.thermometerTheme.trafficLineYellowColor = .yellow
		theme.thermometerTheme.trafficLineGreenColor = .green
		theme.thermometerTheme.trafficLineNoDataColor = .blue
		theme.thermometerTheme.trafficLineUndefinedColor = .gray

		theme.thermometerTheme.cursorTheme.iconColor = .black
		theme.thermometerTheme.cursorTheme.iconBackgroundColor = .orange

		theme.thermometerTheme.crashPointTheme.backgroundColor = .black
		theme.thermometerTheme.crashPointTheme.contentColor = .blue
		theme.thermometerTheme.crashPointTheme.foregroundColor = .red

		theme.thermometerTheme.roadWorksPointTheme.backgroundColor = .black
		theme.thermometerTheme.roadWorksPointTheme.contentColor = .red
		theme.thermometerTheme.roadWorksPointTheme.foregroundColor = .yellow

		theme.thermometerTheme.intermediatePointTheme.backgroundColor = .black
		theme.thermometerTheme.intermediatePointTheme.contentColor = .white
		theme.thermometerTheme.intermediatePointTheme.foregroundColor = .blue

		return theme
	}
}
