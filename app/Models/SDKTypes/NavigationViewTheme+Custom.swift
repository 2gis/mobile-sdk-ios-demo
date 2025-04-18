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

		theme.dashboardTheme.finishButtonTheme.backgroundColor = UIColor(rgb: 0xFF4D00)
		theme.dashboardTheme.finishButtonTheme.textColor = UIColor(rgb: 0xF6EECD)
		theme.dashboardTheme.finishButtonTheme.textFont = UIFont(name: "AmericanTypewriter-Semibold", size: 16)!

		theme.dashboardTheme.contentControlTheme.voiceInstructionsTitleFont = UIFont(name: "AmericanTypewriter", size: 16)!
		theme.dashboardTheme.contentControlTheme.voiceInstructionsSubtitleFont = UIFont(name: "AmericanTypewriter-Light", size: 14)!
		theme.dashboardTheme.contentControlTheme.actionTitleFont = UIFont(name: "AmericanTypewriter-Light", size: 14)!

		theme.speedControlTheme.currentSpeedFont = UIFont(name: "AmericanTypewriter-Semibold", size: 28)!
		theme.speedControlTheme.speedLimitSmallFont = UIFont(name: "AmericanTypewriter-Semibold", size: 22)!
		theme.speedControlTheme.speedLimitNormalFont = UIFont(name: "AmericanTypewriter-Semibold", size: 24)!

		
		theme.remainingRouteInfoControlTheme.titleColor = .purple
		theme.remainingRouteInfoControlTheme.subtitleColor = .systemPink
		theme.remainingRouteInfoControlTheme.titleFont = UIFont(name: "AmericanTypewriter-Semibold", size: 22)!
		theme.remainingRouteInfoControlTheme.subtitleFont = UIFont(name: "AmericanTypewriter-Light", size: 13)!
		theme.remainingRouteInfoControlTheme.arrivedMessageFont = UIFont(name: "AmericanTypewriter-Semibold", size: 18)!

		theme.betterRouteControlTheme.labelFont = UIFont(name: "AmericanTypewriter-Semibold", size: 16)!

		theme.dashboardTheme.contentControlTheme.rightIconBackgroundColor = .white
		theme.dashboardTheme.contentControlTheme.backgroundColor = UIColor(rgb: 0xF1E9E9)
		theme.dashboardTheme.contentControlTheme.disclosureIndicatorColor = .red

		theme.dashboardTheme.parkingButtonTheme.textColor = .brown
		theme.dashboardTheme.parkingButtonTheme.icon = UIImage(named: "svg/parking")?.withRenderingMode(.alwaysTemplate)
		theme.dashboardTheme.parkingButtonTheme.activeIconColor = .darkGray
		theme.dashboardTheme.parkingButtonTheme.iconColor = .magenta
		theme.dashboardTheme.parkingButtonTheme.textFont = UIFont(name: "AmericanTypewriter-Semibold", size: 13)!
		
		theme.dashboardTheme.indoorNavigationControlTheme.textFont = UIFont(name: "AmericanTypewriter-Semibold", size: 13)!
		theme.dashboardTheme.indoorNavigationControlTheme.textColor = .green
		
		theme.dashboardTheme.navigatorFinishRouteDashboardTheme.titleColor = .blue
		theme.dashboardTheme.navigatorFinishRouteDashboardTheme.titleFont = UIFont(name: "AmericanTypewriter-Semibold", size: 18)!
		theme.dashboardTheme.navigatorFinishRouteDashboardTheme.subtitleColor = .green
		theme.dashboardTheme.navigatorFinishRouteDashboardTheme.subtitleFont = UIFont(name: "AmericanTypewriter", size: 15)!

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
