import DGis
import Foundation

typealias CameraPath = [(position: CameraPosition, time: TimeInterval, type: CameraAnimationType)]

enum BenchmarkPath: String, CaseIterable {
	case moscowDefault
	case dubaiImmersiveFlight
	case dubaiMallFlight
	case spbAnimatedMarkerFlight
	case spbStaticMarkerFlight
	case polygonsFlight
	case moscowGeoJson
	case moscowJsonPolygons

	var cameraPath: CameraPath {
		switch self {
		case .moscowDefault: .moscowDefault
		case .dubaiImmersiveFlight: .dubaiImmersiveFlight
		case .dubaiMallFlight: .dubaiMallFlight
		case .spbAnimatedMarkerFlight: .spbAnimatedMarkerFlight
		case .spbStaticMarkerFlight: .spbStaticMarkerFlight
		case .polygonsFlight: .polygonsFlight
		case .moscowGeoJson: .moscowPolygonFlight
		case .moscowJsonPolygons: .moscowPolygonFlight
		@unknown default: fatalError("Unknown type: \(self)")
		}
	}

	var name: String {
		switch self {
		case .moscowDefault:
			"Moscow"
		case .dubaiImmersiveFlight:
			"Dubai Immersive"
		case .dubaiMallFlight:
			"Dubai Indoor"
		case .spbAnimatedMarkerFlight:
			"Animated Markers"
		case .spbStaticMarkerFlight:
			"Static Markers"
		case .polygonsFlight:
			"Polygons"
		case .moscowJsonPolygons:
			"Moscow JSON Polygones"
		case .moscowGeoJson:
			"Moscow GeoJson"
		@unknown default:
			fatalError("Unknown type: \(self)")
		}
	}

	var reportName: String {
		switch self {
		case .moscowDefault:
			"moscow_default"
		case .dubaiImmersiveFlight:
			"dubai_immersive"
		case .dubaiMallFlight:
			"dubai_indoor"
		case .spbAnimatedMarkerFlight:
			"animated_markers"
		case .spbStaticMarkerFlight:
			"static_markers"
		case .polygonsFlight:
			"polygons"
		case .moscowGeoJson:
			"moscow_geojson"
		case .moscowJsonPolygons:
			"moscow_json_polygones"
		@unknown default:
			fatalError("Unknown type: \(self)")
		}
	}
}

extension CameraPath {
	static let moscowDefault: CameraPath = [
		(.init(
			point: .init(latitude: .init(value: 55.759909), longitude: .init(value: 37.618806)),
			zoom: .init(value: 15),
			tilt: .init(value: 15),
			bearing: .init(value: 115)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.759909), longitude: .init(value: 37.618806)),
			zoom: .init(value: 16),
			tilt: .init(value: 15),
			bearing: .init(value: 0)
		), 4, .default),
		(.init(
			point: .init(latitude: .init(value: 55.746962), longitude: .init(value: 37.643073)),
			zoom: .init(value: 16),
			tilt: .init(value: 55),
			bearing: .init(value: 0)
		), 9, .showBothPositions),
		(.init(
			point: .init(latitude: .init(value: 55.746962), longitude: .init(value: 37.643073)),
			zoom: .init(value: 16.5),
			tilt: .init(value: 45),
			bearing: .init(value: 40)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.752425), longitude: .init(value: 37.613983)),
			zoom: .init(value: 16),
			tilt: .init(value: 25),
			bearing: .init(value: 85)
		), 4, .default),
	]

	static let dubaiImmersiveFlight: CameraPath = [
		(.init(
			point: .init(latitude: .init(value: 25.236213145260663), longitude: .init(value: 55.29931968078017)),
			zoom: .init(value: 17.9),
			tilt: .init(value: 59.0),
			bearing: .init(value: 130.0)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.23503475822966), longitude: .init(value: 55.30102791264653)),
			zoom: .init(value: 18.396454),
			tilt: .init(value: 60.0),
			bearing: .init(value: 138.67406837919924)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.235042188578717), longitude: .init(value: 55.29939528554678)),
			zoom: .init(value: 18.240969),
			tilt: .init(value: 60.0),
			bearing: .init(value: 252.85139373504663)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.234766810440377), longitude: .init(value: 55.29980390332639)),
			zoom: .init(value: 17.9),
			tilt: .init(value: 57.0),
			bearing: .init(value: 330.0)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.234641403999944), longitude: .init(value: 55.299516236409545)),
			zoom: .init(value: 17.5),
			tilt: .init(value: 55.0),
			bearing: .init(value: 15.0)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.228974399135552), longitude: .init(value: 55.293875467032194)),
			zoom: .init(value: 18.048622),
			tilt: .init(value: 55.110836),
			bearing: .init(value: 32.35952383455281)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.228686041376136), longitude: .init(value: 55.29333248734474)),
			zoom: .init(value: 17.202654),
			tilt: .init(value: 52.78325),
			bearing: .init(value: 32.35952383455281)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.227277832681466), longitude: .init(value: 55.29350431635976)),
			zoom: .init(value: 17.03534),
			tilt: .init(value: 50.82511),
			bearing: .init(value: 99.4318722010513)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.227277832681466), longitude: .init(value: 55.29350431635976)),
			zoom: .init(value: 17.03534),
			tilt: .init(value: 50.82511),
			bearing: .init(value: 99.4318722010513)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.225995553946248), longitude: .init(value: 55.292065143585205)),
			zoom: .init(value: 17.157991),
			tilt: .init(value: 51.933483),
			bearing: .init(value: 173.8907969473518)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.216675784626034), longitude: .init(value: 55.28231372125447)),
			zoom: .init(value: 16.991346),
			tilt: .init(value: 58.743847),
			bearing: .init(value: 214.2997023612303)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.21855828300758), longitude: .init(value: 55.28217307291925)),
			zoom: .init(value: 16.948515),
			tilt: .init(value: 58.26355),
			bearing: .init(value: 326.7346701380984)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.217604411637197), longitude: .init(value: 55.28364091180265)),
			zoom: .init(value: 17.065231),
			tilt: .init(value: 56.600986),
			bearing: .init(value: 88.85091196908273)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.217908871751177), longitude: .init(value: 55.28248144313693)),
			zoom: .init(value: 17.963282),
			tilt: .init(value: 57.660046),
			bearing: .init(value: 153.648165304185)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.218712900613397), longitude: .init(value: 55.28143144212663)),
			zoom: .init(value: 18.30254),
			tilt: .init(value: 59.10093),
			bearing: .init(value: 221.5413694476013)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.218712900613397), longitude: .init(value: 55.28143144212663)),
			zoom: .init(value: 18.30254),
			tilt: .init(value: 59.10093),
			bearing: .init(value: 221.5413694476013)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.219328639203), longitude: .init(value: 55.281034307554364)),
			zoom: .init(value: 17.978739),
			tilt: .init(value: 60.0),
			bearing: .init(value: 291.26680917454286)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.19552087049614), longitude: .init(value: 55.27348338626325)),
			zoom: .init(value: 17.297209),
			tilt: .init(value: 47.36454),
			bearing: .init(value: 199.04663318978456)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.19777692060545), longitude: .init(value: 55.27235861867666)),
			zoom: .init(value: 17.009499),
			tilt: .init(value: 48.620678),
			bearing: .init(value: 288.28687960193633)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.198761815275702), longitude: .init(value: 55.27509866282344)),
			zoom: .init(value: 17.04467),
			tilt: .init(value: 52.019707),
			bearing: .init(value: 29.089324882599087)
		), 4, .linear),
	]

	static let dubaiMallFlight: CameraPath = [
		(.init(
			point: .init(latitude: .init(value: 25.194082319043517), longitude: .init(value: 55.280991056934)),
			zoom: .init(value: 19.093323),
			tilt: .init(value: 57.192116),
			bearing: .init(value: 342.34027269336525)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.196880830939435), longitude: .init(value: 55.27838478796184)),
			zoom: .init(value: 19.09329),
			tilt: .init(value: 57.192116),
			bearing: .init(value: 342.34027269336525)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.198081961220097), longitude: .init(value: 55.278184125199914)),
			zoom: .init(value: 19.81237),
			tilt: .init(value: 58.706905),
			bearing: .init(value: 109.13508482278154)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.19779565385268), longitude: .init(value: 55.28052309527993)),
			zoom: .init(value: 19.812374),
			tilt: .init(value: 58.706905),
			bearing: .init(value: 109.13508482278154)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.197723678729133), longitude: .init(value: 55.28058998286724)),
			zoom: .init(value: 20.000002),
			tilt: .init(value: 60.0),
			bearing: .init(value: 245.8197139845185)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 25.197278782026558), longitude: .init(value: 55.279244016855955)),
			zoom: .init(value: 19.993673),
			tilt: .init(value: 59.667492),
			bearing: .init(value: 267.18760563306654)
		), 4, .linear),
	]

	static let spbAnimatedMarkerFlight: CameraPath = [
		(.init(
			point: .init(latitude: .init(value: 59.94372913174669), longitude: .init(value: 30.335357738658786)),
			zoom: .init(value: 18.0),
			tilt: .init(value: 59.5),
			bearing: .init(value: 351.80518001495375)
		), 2, .linear),
		(.init(
			point: .init(latitude: .init(value: 59.94468535631333), longitude: .init(value: 30.335429068654776)),
			zoom: .init(value: 16.392374),
			tilt: .init(value: 0.110837445),
			bearing: .init(value: 172.33254392972674)
		), 8, .linear),
		(.init(
			point: .init(latitude: .init(value: 59.94372913174669), longitude: .init(value: 30.335357738658786)),
			zoom: .init(value: 18.0),
			tilt: .init(value: 59.5),
			bearing: .init(value: 351.80518001495375)
		), 8, .linear),
		(.init(
			point: .init(latitude: .init(value: 59.94468535631333), longitude: .init(value: 30.335429068654776)),
			zoom: .init(value: 16.392374),
			tilt: .init(value: 0.110837445),
			bearing: .init(value: 172.33254392972674)
		), 8, .linear),
	]

	static let spbStaticMarkerFlight: CameraPath = [
		(.init(
			point: .init(latitude: .init(value: 59.93696558914853), longitude: .init(value: 30.306325759738684)),
			zoom: .init(value: 16.232157),
			tilt: .init(value: 1.1453212),
			bearing: .init(value: 235.4006155755009)
		), 8, .linear),
		(.init(
			point: .init(latitude: .init(value: 59.93702764935021), longitude: .init(value: 30.30737517401576)),
			zoom: .init(value: 14.942206),
			tilt: .init(value: 0.0),
			bearing: .init(value: 235.4006155755009)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 59.937489696077556), longitude: .init(value: 30.307896193116903)),
			zoom: .init(value: 18.048784),
			tilt: .init(value: 60.0),
			bearing: .init(value: 237.52483172813155)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 59.93702764935021), longitude: .init(value: 30.30737517401576)),
			zoom: .init(value: 14.942206),
			tilt: .init(value: 0.0),
			bearing: .init(value: 235.4006155755009)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 59.937489696077556), longitude: .init(value: 30.307896193116903)),
			zoom: .init(value: 18.048784),
			tilt: .init(value: 60.0),
			bearing: .init(value: 237.52483172813155)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 59.93766184924627), longitude: .init(value: 30.30751003883779)),
			zoom: .init(value: 18.016462),
			tilt: .init(value: 60.0),
			bearing: .init(value: 143.71932421341256)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 59.93732455416152), longitude: .init(value: 30.3073869086802)),
			zoom: .init(value: 18.016478),
			tilt: .init(value: 60.0),
			bearing: .init(value: 45.36641699554817)
		), 4, .linear),
	]

	static let polygonsFlight: CameraPath = [
		(.init(
			point: .init(latitude: .init(value: 57.314785544219696), longitude: .init(value: 40.067282589152455)),
			zoom: .init(value: 8.674324),
			tilt: .init(value: 26.896542),
			bearing: .init(value: 332.9909731536684)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 57.589794514898976), longitude: .init(value: 39.91194723173976)),
			zoom: .init(value: 12.360521),
			tilt: .init(value: 20.948286),
			bearing: .init(value: 332.9909731536684)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 57.397910969166645), longitude: .init(value: 40.11585362255573)),
			zoom: .init(value: 8.523351),
			tilt: .init(value: 17.17982),
			bearing: .init(value: 332.9909731536684)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 57.52634636371139), longitude: .init(value: 39.938956908881664)),
			zoom: .init(value: 10.49659),
			tilt: .init(value: 28.81773),
			bearing: .init(value: 332.9909731536684)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 57.64800139263117), longitude: .init(value: 39.84729182906449)),
			zoom: .init(value: 11.320579),
			tilt: .init(value: 28.263542),
			bearing: .init(value: 332.9909731536684)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 57.7489827569871), longitude: .init(value: 39.775858987122774)),
			zoom: .init(value: 14.971335),
			tilt: .init(value: 43.161377),
			bearing: .init(value: 171.3057889125554)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 57.72653680666681), longitude: .init(value: 39.78192748501897)),
			zoom: .init(value: 14.972231),
			tilt: .init(value: 43.161377),
			bearing: .init(value: 171.3057889125554)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 57.617886055721506), longitude: .init(value: 39.91270562633872)),
			zoom: .init(value: 15.217519),
			tilt: .init(value: 28.706902),
			bearing: .init(value: 165.9114967513761)
		), 8, .linear),
		(.init(
			point: .init(latitude: .init(value: 57.61881994336016), longitude: .init(value: 39.890154115855694)),
			zoom: .init(value: 15.951988),
			tilt: .init(value: 43.965538),
			bearing: .init(value: 305.49698921588754)
		), 8, .linear),
		(.init(
			point: .init(latitude: .init(value: 57.62419202445006), longitude: .init(value: 39.90131906233728)),
			zoom: .init(value: 18.219717),
			tilt: .init(value: 59.852222),
			bearing: .init(value: 3.2874246890404972)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 57.624294132215994), longitude: .init(value: 39.90163723938167)),
			zoom: .init(value: 18.326157),
			tilt: .init(value: 57.007397),
			bearing: .init(value: 171.01849749568632)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 57.62419202445006), longitude: .init(value: 39.90131906233728)),
			zoom: .init(value: 18.219717),
			tilt: .init(value: 59.852222),
			bearing: .init(value: 340.2874246890404972)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 57.624294132215994), longitude: .init(value: 39.90163723938167)),
			zoom: .init(value: 18.326157),
			tilt: .init(value: 57.007397),
			bearing: .init(value: 150.01849749568632)
		), 4, .linear),
	]

	static let moscowPolygonFlight: CameraPath = [
		(.init(
			point: .init(latitude: .init(value: 55.861064234816034), longitude: .init(value: 37.477319184690714)),
			zoom: .init(value: 9.135463),
			tilt: .init(value: 25.102968),
			bearing: .init(value: 85.00001033389452)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.77195937179973), longitude: .init(value: 37.72410722449422)),
			zoom: .init(value: 9.464503),
			tilt: .init(value: 25.205942),
			bearing: .init(value: 196.61411595839786)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.66136007366556), longitude: .init(value: 37.86856823600829)),
			zoom: .init(value: 9.317101),
			tilt: .init(value: 23.043468),
			bearing: .init(value: 284.3648893578667)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.563076406731504), longitude: .init(value: 37.7226300816983)),
			zoom: .init(value: 10.972983),
			tilt: .init(value: 30.0),
			bearing: .init(value: 263.17395425033527)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.621818396123), longitude: .init(value: 37.43075570091605)),
			zoom: .init(value: 12.166465),
			tilt: .init(value: 30.0),
			bearing: .init(value: 311.93437420673285)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.79354205270647), longitude: .init(value: 37.37391768023372)),
			zoom: .init(value: 12.391051),
			tilt: .init(value: 30.0),
			bearing: .init(value: 359.6923682797826)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.852668022608036), longitude: .init(value: 37.39984408020973)),
			zoom: .init(value: 13.670622),
			tilt: .init(value: 30.0),
			bearing: .init(value: 16.634707157512615)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.86831862804825), longitude: .init(value: 37.53497410565615)),
			zoom: .init(value: 14.797172),
			tilt: .init(value: 29.176205),
			bearing: .init(value: 111.84492139484908)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.84166953081042), longitude: .init(value: 37.57578014396131)),
			zoom: .init(value: 14.798161),
			tilt: .init(value: 29.176205),
			bearing: .init(value: 111.84492139484908)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.83614089961442), longitude: .init(value: 37.60718487203121)),
			zoom: .init(value: 11.284859),
			tilt: .init(value: 26.25859),
			bearing: .init(value: 101.15870794777061)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.68093117094693), longitude: .init(value: 37.44317131116986)),
			zoom: .init(value: 10.287172),
			tilt: .init(value: 30.0),
			bearing: .init(value: 35.66980233655617)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.52392517533765), longitude: .init(value: 37.33199282549322)),
			zoom: .init(value: 9.250065),
			tilt: .init(value: 17.746012),
			bearing: .init(value: 35.66980233655617)
		), 4, .linear),
		(.init(
			point: .init(latitude: .init(value: 55.58099451422654), longitude: .init(value: 37.41593699902296)),
			zoom: .init(value: 8.413875),
			tilt: .init(value: 12.528627),
			bearing: .init(value: 35.66980233655617)
		), 4, .linear),
	]
}
