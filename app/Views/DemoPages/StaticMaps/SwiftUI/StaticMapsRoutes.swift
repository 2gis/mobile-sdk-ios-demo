import DGis
import SwiftUI

class StaticMapRouteFactory: @unchecked Sendable {
	struct StaticMapRoute {
		let startPoint: String
		let finishPoint: String
		let routeObjects: [SimpleMapObject]
	}

	private enum Constants {
		static let greenRouteColor = DGis.Color(UIColor(red: 0.53, green: 0.82, blue: 0.45, alpha: 1.00))!
		static let yellowRouteColor = DGis.Color(UIColor(red: 1.00, green: 0.77, blue: 0.02, alpha: 1.00))!
		static let redRouteColor = DGis.Color(UIColor(red: 0.97, green: 0.13, blue: 0.00, alpha: 1.00))!
		static let greyRouteColor = DGis.Color(UIColor(red: 0.38, green: 0.38, blue: 0.38, alpha: 1.00))!
	}

	private let imageFactory: IImageFactory

	init(imageFactory: IImageFactory) {
		self.imageFactory = imageFactory
	}

	private lazy var startPointMarker: DGis.Image = self.imageFactory.make(
		image: (
			createMarkerImage(
				systemName: "a.circle.fill",
				backgroundColor: .secondarySystemBackground,
				iconColor: .systemBlue,
				size: CGSize(width: 20, height: 20)
			)!
		)
	)
	private lazy var finishPointMarker: DGis.Image = self.imageFactory.make(
		image: (
			createMarkerImage(
				systemName: "b.circle.fill",
				backgroundColor: .secondarySystemBackground,
				iconColor: .systemBlue,
				size: CGSize(width: 20, height: 20)
			)!
		)
	)

	lazy var StaticMapsRoutes: [StaticMapRoute] = [
		StaticMapRoute(
			startPoint: "Al Sufouh 2",
			finishPoint: "BVLGARI Resort",
			routeObjects: [
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.101819, longitude: 55.159073),
					icon: self.startPointMarker
				)),
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.209467, longitude: 55.238063),
					icon: self.finishPointMarker
				)),
				self.createPolyline(
					options: PolylineOptions(
						points: [GeoPoint(latitude: 25.101819, longitude: 55.159073),
						         GeoPoint(latitude: 25.132091, longitude: 55.188241),
						         GeoPoint(latitude: 25.136747, longitude: 55.188367),
						         GeoPoint(latitude: 25.140787, longitude: 55.191474),
						         GeoPoint(latitude: 25.202803, longitude: 55.241353),
						         GeoPoint(latitude: 25.203331, longitude: 55.2405),
						         GeoPoint(latitude: 25.203496, longitude: 55.240393),
						         GeoPoint(latitude: 25.203507, longitude: 55.240228),
						         GeoPoint(latitude: 25.203861, longitude: 55.239651),
						         GeoPoint(latitude: 25.204181, longitude: 55.239322),
						         GeoPoint(latitude: 25.204559, longitude: 55.239051),
						         GeoPoint(latitude: 25.204923, longitude: 55.238891),
						         GeoPoint(latitude: 25.205302, longitude: 55.238812),
						         GeoPoint(latitude: 25.205532, longitude: 55.238803),
						         GeoPoint(latitude: 25.205865, longitude: 55.238852),
						         GeoPoint(latitude: 25.206398, longitude: 55.238976),
						         GeoPoint(latitude: 25.207151, longitude: 55.239069),
						         GeoPoint(latitude: 25.207874, longitude: 55.239033),
						         GeoPoint(latitude: 25.208737, longitude: 55.238829),
						         GeoPoint(latitude: 25.210189, longitude: 55.23817),
						         GeoPoint(latitude: 25.210358, longitude: 55.238104),
						         GeoPoint(latitude: 25.210587, longitude: 55.238122),
						         GeoPoint(latitude: 25.210691, longitude: 55.23805),
						         GeoPoint(latitude: 25.210713, longitude: 55.237931),
						         GeoPoint(latitude: 25.210595, longitude: 55.237828),
						         GeoPoint(latitude: 25.21051, longitude: 55.237839),
						         GeoPoint(latitude: 25.210394, longitude: 55.237972),
						         GeoPoint(latitude: 25.209557, longitude: 55.2384),
						         GeoPoint(latitude: 25.209467, longitude: 55.238063)],
						width: 6.0,
						gradientPolylineOptions: GradientPolylineOptions(
							gradientLength: 50.0,
							colors: [
								Constants.greenRouteColor,
								Constants.yellowRouteColor,
								Constants.redRouteColor,
							],
							colorIndices: Data([0, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2])
						)
					)
				),
			]
		),
		StaticMapRoute(
			startPoint: "Al Maktoum International Airport",
			finishPoint: "Dubai Creek Harbour Views Tower",
			routeObjects: [
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 24.886429, longitude: 55.159089),
					icon: self.startPointMarker
				)),
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.204753, longitude: 55.345443),
					icon: self.finishPointMarker
				)),
				self.createPolyline(options: PolylineOptions(
					points: [GeoPoint(latitude: 24.886429, longitude: 55.159089),
					         GeoPoint(latitude: 24.866477, longitude: 55.145875),
					         GeoPoint(latitude: 24.856451, longitude: 55.166556),
					         GeoPoint(latitude: 24.881184, longitude: 55.193608),
					         GeoPoint(latitude: 24.889269, longitude: 55.198222),
					         GeoPoint(latitude: 24.894786, longitude: 55.204408),
					         GeoPoint(latitude: 24.907149, longitude: 55.212796),
					         GeoPoint(latitude: 24.915047, longitude: 55.215808),
					         GeoPoint(latitude: 24.913385, longitude: 55.21957),
					         GeoPoint(latitude: 24.918241, longitude: 55.221671),
					         GeoPoint(latitude: 24.977114, longitude: 55.240596),
					         GeoPoint(latitude: 24.988396, longitude: 55.246549),
					         GeoPoint(latitude: 25.001371, longitude: 55.259726),
					         GeoPoint(latitude: 25.056841, longitude: 55.317775),
					         GeoPoint(latitude: 25.065054, longitude: 55.33836),
					         GeoPoint(latitude: 25.071267, longitude: 55.365115),
					         GeoPoint(latitude: 25.087251, longitude: 55.392783),
					         GeoPoint(latitude: 25.178816, longitude: 55.317742),
					         GeoPoint(latitude: 25.180989, longitude: 55.317974),
					         GeoPoint(latitude: 25.184642, longitude: 55.327005),
					         GeoPoint(latitude: 25.185823, longitude: 55.34914),
					         GeoPoint(latitude: 25.189181, longitude: 55.34924),
					         GeoPoint(latitude: 25.190051, longitude: 55.34824),
					         GeoPoint(latitude: 25.191182, longitude: 55.346304),
					         GeoPoint(latitude: 25.197322, longitude: 55.346134),
					         GeoPoint(latitude: 25.198334, longitude: 55.347058),
					         GeoPoint(latitude: 25.198469, longitude: 55.348474),
					         GeoPoint(latitude: 25.199089, longitude: 55.348847),
					         GeoPoint(latitude: 25.199750, longitude: 55.348638),
					         GeoPoint(latitude: 25.202837, longitude: 55.345515),
					         GeoPoint(latitude: 25.202219, longitude: 55.344223),
					         GeoPoint(latitude: 25.202444, longitude: 55.343676),
					         GeoPoint(latitude: 25.202801, longitude: 55.343521),
					         GeoPoint(latitude: 25.203684, longitude: 55.343805),
					         GeoPoint(latitude: 25.204783, longitude: 55.344554),
					         GeoPoint(latitude: 25.204676, longitude: 55.34542),
					         GeoPoint(latitude: 25.204753, longitude: 55.345443)],
					width: 6.0,
					gradientPolylineOptions: GradientPolylineOptions(
						gradientLength: 50.0,
						colors: [
							Constants.greenRouteColor,
							Constants.yellowRouteColor,
							Constants.redRouteColor,
						],
						colorIndices: Data([0, 1, 2, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2])
					)
				)),
			]
		),
		StaticMapRoute(
			startPoint: "EB-03, 388c, S220 street",
			finishPoint: "Parking lot",
			routeObjects: [
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 24.9476880, longitude: 55.0777674),
					icon: self.startPointMarker
				)),
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 24.9472648, longitude: 55.0804549),
					icon: self.finishPointMarker
				)),
				self.createPolyline(
					options: PolylineOptions(
						points: [GeoPoint(latitude: 24.9476880, longitude: 55.0777674),
						         GeoPoint(latitude: 24.9483884, longitude: 55.0780463),
						         GeoPoint(latitude: 24.9484954, longitude: 55.0782073),
						         GeoPoint(latitude: 24.9486121, longitude: 55.0783253),
						         GeoPoint(latitude: 24.9486121, longitude: 55.0785828),
						         GeoPoint(latitude: 24.9485051, longitude: 55.0789797),
						         GeoPoint(latitude: 24.9484394, longitude: 55.0793928),
						         GeoPoint(latitude: 24.9484103, longitude: 55.0797549),
						         GeoPoint(latitude: 24.9484078, longitude: 55.0800741),
						         GeoPoint(latitude: 24.9484638, longitude: 55.0804844),
						         GeoPoint(latitude: 24.9485270, longitude: 55.0807232),
						         GeoPoint(latitude: 24.9486243, longitude: 55.0810048),
						         GeoPoint(latitude: 24.9486437, longitude: 55.0811309),
						         GeoPoint(latitude: 24.9485537, longitude: 55.0813025),
						         GeoPoint(latitude: 24.9484078, longitude: 55.0813776),
						         GeoPoint(latitude: 24.9482546, longitude: 55.0814527),
						         GeoPoint(latitude: 24.9481063, longitude: 55.0814366),
						         GeoPoint(latitude: 24.9479822, longitude: 55.0813213),
						         GeoPoint(latitude: 24.9476855, longitude: 55.0810397),
						         GeoPoint(latitude: 24.9474910, longitude: 55.0809485),
						         GeoPoint(latitude: 24.9473232, longitude: 55.0809592),
						         GeoPoint(latitude: 24.9472040, longitude: 55.0808895),
						         GeoPoint(latitude: 24.9471870, longitude: 55.0806668),
						         GeoPoint(latitude: 24.9472089, longitude: 55.0804925),
						         GeoPoint(latitude: 24.9472648, longitude: 55.0804549)],
						width: 6.0,
						gradientPolylineOptions: GradientPolylineOptions(
							gradientLength: 50.0,
							colors: [
								Constants.greenRouteColor,
								Constants.yellowRouteColor,
								Constants.redRouteColor,
							],
							colorIndices: Data([0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0])
						)
					)
				),
			]
		),
		StaticMapRoute(
			startPoint: "Hessyan 2",
			finishPoint: "Nakhlat Jabal Ali",
			routeObjects: [
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 24.9695929, longitude: 54.9851561),
					icon: self.startPointMarker
				)),
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.0340110, longitude: 54.9717665),
					icon: self.finishPointMarker
				)),
				self.createPolyline(options: PolylineOptions(
					points: [GeoPoint(latitude: 24.9695929, longitude: 54.9851561),
					         GeoPoint(latitude: 24.9710227, longitude: 54.9884391),
					         GeoPoint(latitude: 24.9713533, longitude: 54.9894691),
					         GeoPoint(latitude: 24.9705655, longitude: 54.9900377),
					         GeoPoint(latitude: 24.9704488, longitude: 54.9905741),
					         GeoPoint(latitude: 24.9709643, longitude: 54.9905634),
					         GeoPoint(latitude: 24.9718202, longitude: 54.9901772),
					         GeoPoint(latitude: 24.9735125, longitude: 54.9889863),
					         GeoPoint(latitude: 24.9752728, longitude: 54.9876344),
					         GeoPoint(latitude: 24.9768581, longitude: 54.9858642),
					         GeoPoint(latitude: 24.9781905, longitude: 54.9834073),
					         GeoPoint(latitude: 24.9787837, longitude: 54.9818194),
					         GeoPoint(latitude: 24.9795131, longitude: 54.9768305),
					         GeoPoint(latitude: 24.9800772, longitude: 54.9741375),
					         GeoPoint(latitude: 24.9807677, longitude: 54.9716163),
					         GeoPoint(latitude: 24.9817304, longitude: 54.9693954),
					         GeoPoint(latitude: 24.9837630, longitude: 54.9652433),
					         GeoPoint(latitude: 24.9861942, longitude: 54.9620783),
					         GeoPoint(latitude: 24.9889462, longitude: 54.9593747),
					         GeoPoint(latitude: 24.9906577, longitude: 54.9580550),
					         GeoPoint(latitude: 24.9921067, longitude: 54.9571216),
					         GeoPoint(latitude: 24.9942460, longitude: 54.9562418),
					         GeoPoint(latitude: 24.9983495, longitude: 54.9551797),
					         GeoPoint(latitude: 25.0012082, longitude: 54.9548149),
					         GeoPoint(latitude: 25.0048350, longitude: 54.9549866),
					         GeoPoint(latitude: 25.0078103, longitude: 54.9558234),
					         GeoPoint(latitude: 25.0118161, longitude: 54.9571753),
					         GeoPoint(latitude: 25.0141107, longitude: 54.9582160),
					         GeoPoint(latitude: 25.0170079, longitude: 54.9593961),
					         GeoPoint(latitude: 25.0187579, longitude: 54.9603403),
					         GeoPoint(latitude: 25.0224037, longitude: 54.9630332),
					         GeoPoint(latitude: 25.0252813, longitude: 54.9659514),
					         GeoPoint(latitude: 25.0288005, longitude: 54.9716377),
					         GeoPoint(latitude: 25.0306670, longitude: 54.9742985),
					         GeoPoint(latitude: 25.0323390, longitude: 54.9733973),
					         GeoPoint(latitude: 25.0340110, longitude: 54.9717665)],
					width: 6.0,
					gradientPolylineOptions: GradientPolylineOptions(
						gradientLength: 50.0,
						colors: [
							Constants.greenRouteColor,
							Constants.yellowRouteColor,
							Constants.redRouteColor,
						],
						colorIndices: Data([0, 0, 2, 2, 0, 0, 0, 2, 1, 2, 2, 2, 1, 0, 2, 0, 0, 2, 0, 0, 2, 0, 2, 0, 2, 0, 1, 1, 2, 1, 0, 2, 2, 0, 1])
					)
				)),
			]
		),
		StaticMapRoute(
			startPoint: "P43, G10 street",
			finishPoint: "K26, G10 street",
			routeObjects: [
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.0408835, longitude: 55.1592073),
					icon: self.startPointMarker
				)),
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.0392456, longitude: 55.1606208),
					icon: self.finishPointMarker
				)),
				self.createPolyline(options: PolylineOptions(
					points: [GeoPoint(latitude: 25.0408835, longitude: 55.1592073),
					         GeoPoint(latitude: 25.0408179, longitude: 55.1591456),
					         GeoPoint(latitude: 25.0410536, longitude: 55.1588559),
					         GeoPoint(latitude: 25.0411411, longitude: 55.1588184),
					         GeoPoint(latitude: 25.0412383, longitude: 55.1588666),
					         GeoPoint(latitude: 25.0414522, longitude: 55.1596069),
					         GeoPoint(latitude: 25.0414327, longitude: 55.1597303),
					         GeoPoint(latitude: 25.0407377, longitude: 55.1606798),
					         GeoPoint(latitude: 25.0406065, longitude: 55.1607496),
					         GeoPoint(latitude: 25.0401302, longitude: 55.1605457),
					         GeoPoint(latitude: 25.0399407, longitude: 55.1603526),
					         GeoPoint(latitude: 25.0398969, longitude: 55.1602560),
					         GeoPoint(latitude: 25.0398046, longitude: 55.1602292),
					         GeoPoint(latitude: 25.0397025, longitude: 55.1602721),
					         GeoPoint(latitude: 25.0396782, longitude: 55.1603955),
					         GeoPoint(latitude: 25.0396296, longitude: 55.1605189),
					         GeoPoint(latitude: 25.0394303, longitude: 55.1607764),
					         GeoPoint(latitude: 25.0391266, longitude: 55.1612270),
					         GeoPoint(latitude: 25.0390464, longitude: 55.1611519),
					         GeoPoint(latitude: 25.0391849, longitude: 55.1609212),
					         GeoPoint(latitude: 25.0392335, longitude: 55.1608300),
					         GeoPoint(latitude: 25.0392942, longitude: 55.1607683),
					         GeoPoint(latitude: 25.0393161, longitude: 55.1606986),
					         GeoPoint(latitude: 25.0392456, longitude: 55.1606208)],
					width: 6.0,
					gradientPolylineOptions: GradientPolylineOptions(
						gradientLength: 50.0,
						colors: [
							Constants.greenRouteColor,
							Constants.yellowRouteColor,
							Constants.redRouteColor,
						],
						colorIndices: Data([0, 0, 2, 1, 1, 0, 1, 2, 1, 1, 0, 0, 0, 2, 1, 2, 2, 0, 1, 1, 2, 1, 1])
					)
				)),
			]
		),
		StaticMapRoute(
			startPoint: "Y2, 12 street",
			finishPoint: "3, Cluster 23 street",
			routeObjects: [
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.0492890, longitude: 55.1661140),
					icon: self.startPointMarker
				)),
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.0547781, longitude: 55.1646924),
					icon: self.finishPointMarker
				)),
				self.createPolyline(options: PolylineOptions(
					points: [GeoPoint(latitude: 25.0492890, longitude: 55.1661140),
					         GeoPoint(latitude: 25.0492331, longitude: 55.1661730),
					         GeoPoint(latitude: 25.0491748, longitude: 55.1661381),
					         GeoPoint(latitude: 25.0491116, longitude: 55.1660657),
					         GeoPoint(latitude: 25.0490605, longitude: 55.1659718),
					         GeoPoint(latitude: 25.0490727, longitude: 55.1658350),
					         GeoPoint(latitude: 25.0492234, longitude: 55.1655158),
					         GeoPoint(latitude: 25.0493303, longitude: 55.1652288),
					         GeoPoint(latitude: 25.0494105, longitude: 55.1650921),
					         GeoPoint(latitude: 25.0495295, longitude: 55.1650438),
					         GeoPoint(latitude: 25.0496875, longitude: 55.1650572),
					         GeoPoint(latitude: 25.0499620, longitude: 55.1650572),
					         GeoPoint(latitude: 25.0501540, longitude: 55.1649928),
					         GeoPoint(latitude: 25.0503484, longitude: 55.1649204),
					         GeoPoint(latitude: 25.0506084, longitude: 55.1648426),
					         GeoPoint(latitude: 25.0508198, longitude: 55.1648292),
					         GeoPoint(latitude: 25.0510701, longitude: 55.1648507),
					         GeoPoint(latitude: 25.0512183, longitude: 55.1649123),
					         GeoPoint(latitude: 25.0512475, longitude: 55.1649928),
					         GeoPoint(latitude: 25.0512086, longitude: 55.1651752),
					         GeoPoint(latitude: 25.0511478, longitude: 55.1654568),
					         GeoPoint(latitude: 25.0511041, longitude: 55.1656178),
					         GeoPoint(latitude: 25.0510506, longitude: 55.1657197),
					         GeoPoint(latitude: 25.0509510, longitude: 55.1657304),
					         GeoPoint(latitude: 25.0508806, longitude: 55.1658672),
					         GeoPoint(latitude: 25.0508733, longitude: 55.1660201),
					         GeoPoint(latitude: 25.0509267, longitude: 55.1661086),
					         GeoPoint(latitude: 25.0510677, longitude: 55.1661327),
					         GeoPoint(latitude: 25.0511649, longitude: 55.1661515),
					         GeoPoint(latitude: 25.0512110, longitude: 55.1660603),
					         GeoPoint(latitude: 25.0512377, longitude: 55.1658565),
					         GeoPoint(latitude: 25.0511867, longitude: 55.1657706),
					         GeoPoint(latitude: 25.0511284, longitude: 55.1657492),
					         GeoPoint(latitude: 25.0511308, longitude: 55.1656392),
					         GeoPoint(latitude: 25.0512596, longitude: 55.1650625),
					         GeoPoint(latitude: 25.0513787, longitude: 55.1649740),
					         GeoPoint(latitude: 25.0514856, longitude: 55.1649955),
					         GeoPoint(latitude: 25.0521174, longitude: 55.1653308),
					         GeoPoint(latitude: 25.0524090, longitude: 55.1653844),
					         GeoPoint(latitude: 25.0529046, longitude: 55.1653978),
					         GeoPoint(latitude: 25.0534028, longitude: 55.1652288),
					         GeoPoint(latitude: 25.0537697, longitude: 55.1649982),
					         GeoPoint(latitude: 25.0540005, longitude: 55.1647514),
					         GeoPoint(latitude: 25.0542702, longitude: 55.1643544),
					         GeoPoint(latitude: 25.0544087, longitude: 55.1640353),
					         GeoPoint(latitude: 25.0545472, longitude: 55.1639628),
					         GeoPoint(latitude: 25.0547683, longitude: 55.1640058),
					         GeoPoint(latitude: 25.0549992, longitude: 55.1641640),
					         GeoPoint(latitude: 25.0551036, longitude: 55.1642740),
					         GeoPoint(latitude: 25.0550502, longitude: 55.1644135),
					         GeoPoint(latitude: 25.0547781, longitude: 55.1646924)],
					width: 6.0,
					gradientPolylineOptions: GradientPolylineOptions(
						gradientLength: 50.0,
						colors: [
							Constants.greenRouteColor,
							Constants.yellowRouteColor,
							Constants.redRouteColor,
						],
						colorIndices: Data([1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0])
					)
				)),
			]
		),
		StaticMapRoute(
			startPoint: "3060, Street Al Daya",
			finishPoint: "2548, Street Fahad Ibn Jabir",
			routeObjects: [
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 24.7428364, longitude: 46.7491235),
					icon: self.startPointMarker
				)),
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 24.7525799, longitude: 46.7442501),
					icon: self.finishPointMarker
				)),
				self.createPolyline(options: PolylineOptions(
					points: [GeoPoint(latitude: 24.7428364, longitude: 46.7491235),
					         GeoPoint(latitude: 24.7423833, longitude: 46.7480877),
					         GeoPoint(latitude: 24.7462028, longitude: 46.7461984),
					         GeoPoint(latitude: 24.7484536, longitude: 46.7450713),
					         GeoPoint(latitude: 24.7517907, longitude: 46.7433699),
					         GeoPoint(latitude: 24.7527699, longitude: 46.7428707),
					         GeoPoint(latitude: 24.7530427, longitude: 46.7435577),
					         GeoPoint(latitude: 24.7524435, longitude: 46.7438798),
					         GeoPoint(latitude: 24.7525799, longitude: 46.7442501)],
					width: 6.0,
					gradientPolylineOptions: GradientPolylineOptions(
						gradientLength: 50.0,
						colors: [
							Constants.greenRouteColor,
							Constants.yellowRouteColor,
							Constants.redRouteColor,
						],
						colorIndices: Data([1, 1, 0, 0, 1, 1, 2, 1])
					)
				)),
			]
		),
		StaticMapRoute(
			startPoint: "Al Dhait Girls School For Basic Education C2",
			finishPoint: "Vila at 13A Street",
			routeObjects: [
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.7304682, longitude: 55.9127610),
					icon: self.startPointMarker
				)),
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.7276847, longitude: 55.8989438),
					icon: self.finishPointMarker
				)),
				self.createPolyline(options: PolylineOptions(
					points: [GeoPoint(latitude: 25.7304682, longitude: 55.9127610),
					         GeoPoint(latitude: 25.7306567, longitude: 55.9123045),
					         GeoPoint(latitude: 25.7304199, longitude: 55.9121921),
					         GeoPoint(latitude: 25.7312269, longitude: 55.9103467),
					         GeoPoint(latitude: 25.7312221, longitude: 55.9101910),
					         GeoPoint(latitude: 25.7311593, longitude: 55.9100570),
					         GeoPoint(latitude: 25.7309273, longitude: 55.9099120),
					         GeoPoint(latitude: 25.7314299, longitude: 55.9089679),
					         GeoPoint(latitude: 25.7303522, longitude: 55.9081578),
					         GeoPoint(latitude: 25.7302604, longitude: 55.9081310),
					         GeoPoint(latitude: 25.7301734, longitude: 55.9081471),
					         GeoPoint(latitude: 25.7300913, longitude: 55.9082544),
					         GeoPoint(latitude: 25.7299850, longitude: 55.9084366),
					         GeoPoint(latitude: 25.7296274, longitude: 55.9092726),
					         GeoPoint(latitude: 25.7277716, longitude: 55.9136499),
					         GeoPoint(latitude: 25.7274527, longitude: 55.9141437),
					         GeoPoint(latitude: 25.7271917, longitude: 55.9144228),
					         GeoPoint(latitude: 25.7267955, longitude: 55.9146590),
					         GeoPoint(latitude: 25.7262735, longitude: 55.9147663),
					         GeoPoint(latitude: 25.7257129, longitude: 55.9147449),
					         GeoPoint(latitude: 25.7253070, longitude: 55.9145302),
					         GeoPoint(latitude: 25.7248914, longitude: 55.9142296),
					         GeoPoint(latitude: 25.7245241, longitude: 55.9137573),
					         GeoPoint(latitude: 25.7243404, longitude: 55.9133708),
					         GeoPoint(latitude: 25.7242631, longitude: 55.9128985),
					         GeoPoint(latitude: 25.7242728, longitude: 55.9125228),
					         GeoPoint(latitude: 25.7243501, longitude: 55.9121149),
					         GeoPoint(latitude: 25.7244564, longitude: 55.9117607),
					         GeoPoint(latitude: 25.7246401, longitude: 55.9114494),
					         GeoPoint(latitude: 25.7249397, longitude: 55.9111596),
					         GeoPoint(latitude: 25.7268631, longitude: 55.9094206),
					         GeoPoint(latitude: 25.7292698, longitude: 55.9072630),
					         GeoPoint(latitude: 25.7292311, longitude: 55.9071127),
					         GeoPoint(latitude: 25.7287962, longitude: 55.9065760),
					         GeoPoint(latitude: 25.7283709, longitude: 55.9060178),
					         GeoPoint(latitude: 25.7280519, longitude: 55.9055562),
					         GeoPoint(latitude: 25.7277233, longitude: 55.9051053),
					         GeoPoint(latitude: 25.7276750, longitude: 55.9049765),
					         GeoPoint(latitude: 25.7297723, longitude: 55.9030980),
					         GeoPoint(latitude: 25.7297820, longitude: 55.9029155),
					         GeoPoint(latitude: 25.7288348, longitude: 55.9016166),
					         GeoPoint(latitude: 25.7268728, longitude: 55.8988686),
					         GeoPoint(latitude: 25.7273947, longitude: 55.8984178),
					         GeoPoint(latitude: 25.7275493, longitude: 55.8982890),
					         GeoPoint(latitude: 25.7278780, longitude: 55.8987720),
					         GeoPoint(latitude: 25.7276847, longitude: 55.8989438)],
					width: 6.0,
					gradientPolylineOptions: GradientPolylineOptions(
						gradientLength: 50.0,
						colors: [
							Constants.greenRouteColor,
							Constants.yellowRouteColor,
							Constants.redRouteColor,
						],
						colorIndices: Data([1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0])
					)
				)),
			]
		),
		StaticMapRoute(
			startPoint: "Vila at Al Tawaya Street",
			finishPoint: "44, Al Tawaya Street",
			routeObjects: [
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.7032484, longitude: 55.8310116),
					icon: self.startPointMarker
				)),
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.7005705, longitude: 55.8216082),
					icon: self.finishPointMarker
				)),
				self.createPolyline(options: PolylineOptions(
					points: [GeoPoint(latitude: 25.7032484, longitude: 55.8310116),
					         GeoPoint(latitude: 25.7030937, longitude: 55.8310653),
					         GeoPoint(latitude: 25.7023590, longitude: 55.8283173),
					         GeoPoint(latitude: 25.7014889, longitude: 55.8250540),
					         GeoPoint(latitude: 25.7008702, longitude: 55.8228105),
					         GeoPoint(latitude: 25.7005705, longitude: 55.8216082)],
					width: 6.0,
					gradientPolylineOptions: GradientPolylineOptions(
						gradientLength: 50.0,
						colors: [
							Constants.greenRouteColor,
							Constants.yellowRouteColor,
							Constants.redRouteColor,
						],
						colorIndices: Data([0, 1, 2, 1, 0])
					)
				)),
			]
		),
		StaticMapRoute(
			startPoint: "6-26, Al Ghubb street",
			finishPoint: "6-91, Al Jeer street",
			routeObjects: [
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.7174898, longitude: 55.8317605),
					icon: self.startPointMarker
				)),
				self.createMarker(options: MarkerOptions(
					position: .init(latitude: 25.7179513, longitude: 55.8319868),
					icon: self.finishPointMarker
				)),
				self.createPolyline(options: PolylineOptions(
					points: [GeoPoint(latitude: 25.7174898, longitude: 55.8317605),
					         GeoPoint(latitude: 25.7174173, longitude: 55.8316943),
					         GeoPoint(latitude: 25.7173641, longitude: 55.8317399),
					         GeoPoint(latitude: 25.7173182, longitude: 55.8317990),
					         GeoPoint(latitude: 25.7172578, longitude: 55.8319251),
					         GeoPoint(latitude: 25.7173182, longitude: 55.8319466),
					         GeoPoint(latitude: 25.7173690, longitude: 55.8319680),
					         GeoPoint(latitude: 25.7174173, longitude: 55.8320136),
					         GeoPoint(latitude: 25.7174584, longitude: 55.8320620),
					         GeoPoint(latitude: 25.7175091, longitude: 55.8320807),
					         GeoPoint(latitude: 25.7175623, longitude: 55.8321022),
					         GeoPoint(latitude: 25.7176058, longitude: 55.8321103),
					         GeoPoint(latitude: 25.7176420, longitude: 55.8321425),
					         GeoPoint(latitude: 25.7176783, longitude: 55.8321237),
					         GeoPoint(latitude: 25.7176952, longitude: 55.8320593),
					         GeoPoint(latitude: 25.7177387, longitude: 55.8319734),
					         GeoPoint(latitude: 25.7177846, longitude: 55.8319170),
					         GeoPoint(latitude: 25.7178160, longitude: 55.8318822),
					         GeoPoint(latitude: 25.7178450, longitude: 55.8319036),
					         GeoPoint(latitude: 25.7178668, longitude: 55.8319466),
					         GeoPoint(latitude: 25.7179006, longitude: 55.8319627),
					         GeoPoint(latitude: 25.7179513, longitude: 55.8319868)],
					width: 4.0,
					color: Constants.greyRouteColor,
					dashedPolylineOptions: DashedPolylineOptions(
						dashLength: 4.0,
						dashSpaceLength: 2.0
					)
				)),
			]
		),
	]

	private func createMarkerImage(systemName: String, backgroundColor: UIColor, iconColor: UIColor, size: CGSize) -> UIImage? {
		let offsetValue: CGFloat = 2
		let outerSize = CGSize(width: size.width + offsetValue, height: size.height + offsetValue)
		UIGraphicsBeginImageContextWithOptions(outerSize, false, 0.0)

		let primaryCirclePath = UIBezierPath(
			ovalIn: CGRect(
				x: 0,
				y: 0,
				width: outerSize.width,
				height: outerSize.height
			)
		)
		backgroundColor.setFill()
		primaryCirclePath.fill()

		let secondaryCirclePath = UIBezierPath(
			ovalIn: CGRect(
				x: offsetValue * 2.5,
				y: offsetValue * 2.5,
				width: size.width - offsetValue * 4,
				height: size.height - offsetValue * 4
			)
		)
		UIColor.white.setFill()
		secondaryCirclePath.fill()

		let icon = UIImage(systemName: systemName)?.withTintColor(iconColor, renderingMode: .alwaysOriginal)
		let iconRect = CGRect(
			x: (outerSize.width - size.width) / 2,
			y: (outerSize.height - size.height) / 2, width: size.width, height: size.height
		)
		icon?.draw(in: iconRect)
		let finalImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return finalImage
	}

	private func createMarker(options: MarkerOptions) -> Marker {
		do {
			return try Marker(options: options)
		} catch {
			fatalError("Failed to create marker: \(error.localizedDescription)")
		}
	}

	private func createPolyline(options: PolylineOptions) -> Polyline {
		do {
			return try Polyline(options: options)
		} catch {
			fatalError("Failed to create polyline: \(error.localizedDescription)")
		}
	}
}
