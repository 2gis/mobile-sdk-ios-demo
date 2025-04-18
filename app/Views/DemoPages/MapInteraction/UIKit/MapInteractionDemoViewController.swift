import UIKit
import DGis

/// Демо для проверки отключения интерактивности карты.
/// Не переносить в демо-проект.
class MapInteractionDemoViewController: UIViewController {
	private let mapFactory: () throws -> IMapFactory
	private let tableView = UITableView()
	private var coordinator: MapInteractionDemoViewCoordinator

	init(mapFactoryProvider: @escaping () throws -> IMapFactory) {
		self.mapFactory = mapFactoryProvider
		self.coordinator = MapInteractionDemoViewCoordinator(mapFactoryProvider: mapFactory)
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupTableView()
		tableView.delegate = coordinator
		tableView.dataSource = coordinator
	}
	
	private func setupTableView() {
		tableView.register(MapTableViewCell.self, forCellReuseIdentifier: "mapTableCell")
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
}

class MapInteractionDemoViewCoordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
	private let mapFactoryProvider: () throws -> IMapFactory
	private lazy var mapHolders: [MapHolder] = {
		return (0..<3).compactMap { _ in try? MapHolder(mapFactory: mapFactoryProvider()) }	}()

	init(mapFactoryProvider: @escaping () throws -> IMapFactory) {
		self.mapFactoryProvider = mapFactoryProvider
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return mapHolders.count
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return tableView.bounds.width
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "mapTableCell", for: indexPath) as! MapTableViewCell
		cell.mapHolder = mapHolders[indexPath.row]
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let mapId = mapHolders[indexPath.row].mapFactory.map.id.value
		print("Тач в ячейку карты \(mapId)")
	}
}

private class MapHolder {
	let mapFactory: IMapFactory

	init(mapFactory: IMapFactory) {
		self.mapFactory = mapFactory
	}
}

private class MapTableViewCell: UITableViewCell {
	var mapHolder: MapHolder? {
		didSet {
			self.setupMap()
		}
	}

	private lazy var mapInteractionButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Interaction On", for: .normal)
		button.setTitle("Interaction Off", for: .selected)
		button.setTitleColor(.green, for: .normal)
		button.setTitleColor(.red, for: .selected)
		button.addTarget(self, action: #selector(self.mapInteractionButtonTapped), for: .touchUpInside)
		return button
	}()

	private func setupMap() {
		guard let mapFactory = self.mapHolder?.mapFactory else { return }
		mapFactory.mapView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(mapFactory.mapView)
		NSLayoutConstraint.activate([
			mapFactory.mapView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			mapFactory.mapView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
			mapFactory.mapView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
			mapFactory.mapView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor)
		])

		self.contentView.addSubview(self.mapInteractionButton)
		NSLayoutConstraint.activate([
			self.mapInteractionButton.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 20),
			self.mapInteractionButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20)
		])
	}

	@objc private func mapInteractionButtonTapped() {
		let map = self.mapHolder?.mapFactory.map
		map?.interactive.toggle()
		self.mapInteractionButton.isSelected = map?.interactive == false
	}
}
