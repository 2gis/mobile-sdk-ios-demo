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

		theme.dashboardControlTheme.backgroundColor = UIColor(rgb: 0xD7C1C1)

		theme.dashboardControlTheme.finishButtonTheme.backgroundColor = UIColor(rgb: 0xFF4D00)
		theme.dashboardControlTheme.finishButtonTheme.textColor = UIColor(rgb: 0xF6EECD)
		theme.dashboardControlTheme.finishButtonTheme.textFont = UIFont(name: "AmericanTypewriter-Semibold", size: 16)!

		theme.dashboardControlTheme.contentControlTheme.voiceInstructionsTitleFont = UIFont(name: "AmericanTypewriter", size: 16)!
		theme.dashboardControlTheme.contentControlTheme.voiceInstructionsSubtitleFont = UIFont(name: "AmericanTypewriter-Light", size: 14)!
		theme.dashboardControlTheme.contentControlTheme.actionTitleFont = UIFont(name: "AmericanTypewriter-Light", size: 14)!

		theme.speedControlTheme.currentSpeedFont = UIFont(name: "AmericanTypewriter-Semibold", size: 28)!
		theme.speedControlTheme.speedLimitSmallFont = UIFont(name: "AmericanTypewriter-Semibold", size: 22)!
		theme.speedControlTheme.speedLimitNormalFont = UIFont(name: "AmericanTypewriter-Semibold", size: 24)!

		
		theme.remainingRouteInfoControlTheme.titleColor = .purple
		theme.remainingRouteInfoControlTheme.subtitleColor = .systemPink
		theme.remainingRouteInfoControlTheme.titleFont = UIFont(name: "AmericanTypewriter-Semibold", size: 22)!
		theme.remainingRouteInfoControlTheme.subtitleFont = UIFont(name: "AmericanTypewriter-Light", size: 13)!
		theme.remainingRouteInfoControlTheme.arrivedMessageFont = UIFont(name: "AmericanTypewriter-Semibold", size: 18)!

		theme.betterRouteControlTheme.labelFont = UIFont(name: "AmericanTypewriter-Semibold", size: 16)!

		theme.dashboardControlTheme.contentControlTheme.rightIconBackgroundColor = .white
		theme.dashboardControlTheme.contentControlTheme.backgroundColor = UIColor(rgb: 0xF1E9E9)
		theme.dashboardControlTheme.contentControlTheme.disclosureIndicatorColor = .red

		theme.dashboardControlTheme.parkingButtonTheme.textColor = .brown
		theme.dashboardControlTheme.parkingButtonTheme.icon = UIImage(named: "svg/parking")?.withRenderingMode(.alwaysTemplate)
		theme.dashboardControlTheme.parkingButtonTheme.activeIconColor = .darkGray
		theme.dashboardControlTheme.parkingButtonTheme.iconColor = .magenta
		theme.dashboardControlTheme.parkingButtonTheme.textFont = UIFont(name: "AmericanTypewriter-Semibold", size: 13)!
		
		theme.dashboardControlTheme.indoorNavigationControlTheme.textFont = UIFont(name: "AmericanTypewriter-Semibold", size: 13)!
		theme.dashboardControlTheme.indoorNavigationControlTheme.textColor = .green
		
		theme.dashboardControlTheme.finishRouteControlTheme.titleColor = .blue
		theme.dashboardControlTheme.finishRouteControlTheme.titleFont = UIFont(name: "AmericanTypewriter-Semibold", size: 18)!
		theme.dashboardControlTheme.finishRouteControlTheme.subtitleColor = .green
		theme.dashboardControlTheme.finishRouteControlTheme.subtitleFont = UIFont(name: "AmericanTypewriter", size: 15)!

		theme.cameraControlTheme.trackColor = .black
		theme.cameraControlTheme.progressColor = .white

		theme.messageBarControlTheme.activityIndicatorColor = .purple
		theme.messageBarControlTheme.textFont = UIFont(name: "AmericanTypewriter", size: 16)!

		theme.mapControlsTheme.trafficControlTheme.lowJamsColor = .green
		theme.mapControlsTheme.trafficControlTheme.mediumJamsColor = .yellow
		theme.mapControlsTheme.trafficControlTheme.hightJamsColor = .purple
		theme.mapControlsTheme.trafficControlTheme.textFont = UIFont(name: "AmericanTypewriter-Semibold", size: 16)!
		theme.mapControlsTheme.parkingControlTheme.icon = UIImage(named: "svg/parking")?.withRenderingMode(.alwaysTemplate)

		theme.betterRouteControlTheme.progressBarColor = .purple

		theme.thermometerControlTheme.progressColor = .black
		theme.thermometerControlTheme.startPositionColor = .black
		theme.thermometerControlTheme.trafficLineDeepRedColor = .purple
		theme.thermometerControlTheme.trafficLineRedColor = .red
		theme.thermometerControlTheme.trafficLineOrangeColor = .orange
		theme.thermometerControlTheme.trafficLineYellowColor = .yellow
		theme.thermometerControlTheme.trafficLineGreenColor = .green
		theme.thermometerControlTheme.trafficLineDeepGreenColor = .green
		theme.thermometerControlTheme.trafficLineNoDataColor = .blue
		theme.thermometerControlTheme.trafficLineUndefinedColor = .gray

		theme.thermometerControlTheme.cursorTheme.iconColor = .black
		theme.thermometerControlTheme.cursorTheme.iconBackgroundColor = .orange

		theme.thermometerControlTheme.crashPointTheme.backgroundColor = .black
		theme.thermometerControlTheme.crashPointTheme.contentColor = .blue
		theme.thermometerControlTheme.crashPointTheme.foregroundColor = .red

		theme.thermometerControlTheme.roadWorksPointTheme.backgroundColor = .black
		theme.thermometerControlTheme.roadWorksPointTheme.contentColor = .red
		theme.thermometerControlTheme.roadWorksPointTheme.foregroundColor = .yellow

		theme.thermometerControlTheme.intermediatePointTheme.backgroundColor = .black
		theme.thermometerControlTheme.intermediatePointTheme.contentColor = .white
		theme.thermometerControlTheme.intermediatePointTheme.foregroundColor = .blue

		theme.nextManeuverControlTheme.iconColor = .red
		theme.nextManeuverControlTheme.additionalManeuverIconColor = .brown
		theme.nextManeuverControlTheme.titleFont = UIFont(name: "AmericanTypewriter", size: 16)!
		theme.nextManeuverControlTheme.additionalManeuverFont = UIFont(name: "AmericanTypewriter", size: 20)!
		theme.nextManeuverControlTheme.maneuverDistanceFont = UIFont(name: "AmericanTypewriter-Semibold", size: 28)!
		theme.nextManeuverControlTheme.maneuverDistanceUnitFont = UIFont(name: "AmericanTypewriter", size: 20)!
		
		theme.routeOverviewControlTheme.backgroundColor = .darkGray
		theme.routeOverviewControlTheme.textColor = .white
		theme.routeOverviewControlTheme.textFont = UIFont(name: "AmericanTypewriter", size: 16)!
		return theme
	}
}
