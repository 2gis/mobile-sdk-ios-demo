import UIKit
import DGis

protocol RoadEventsFilterViewControllerDelegate: AnyObject {
	func didUpdateVisibleEvents(_ visibleEvents: RoadEventDisplayCategoryOptionSet)
}

class RoadEventsFilterViewController: UITableViewController {
	private var visibleEvents: RoadEventDisplayCategoryOptionSet
	weak var delegate: RoadEventsFilterViewControllerDelegate?

	init(visibleEvents: RoadEventDisplayCategoryOptionSet) {
		self.visibleEvents = visibleEvents
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Road events to show"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(
			title: "Close",
			style: .done,
			target: self,
			action: #selector(dismissView)
		)
	}

	@objc private func dismissView() {
		delegate?.didUpdateVisibleEvents(visibleEvents)
		dismiss(animated: true)
	}

	// MARK: - Table View Data Source

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return RoadEventDisplayCategoryOptionSet.allValues.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell") ?? UITableViewCell(style: .default, reuseIdentifier: "filterCell")

		let event = RoadEventDisplayCategoryOptionSet.allValues[indexPath.row]
		cell.textLabel?.text = event.name
		cell.accessoryType = visibleEvents.contains(event) ? .checkmark : .none

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let event = RoadEventDisplayCategoryOptionSet.allValues[indexPath.row]

		if visibleEvents.contains(event) {
			visibleEvents.remove(event)
		} else {
			visibleEvents.insert(event)
		}

		tableView.reloadRows(at: [indexPath], with: .automatic)
	}
}

extension RoadEventDisplayCategoryOptionSet {
	static var allValues: [RoadEventDisplayCategoryOptionSet] {
		[.camera, .comment, .accident, .roadRestriction, .roadWorks, .user, .other]
	}

	var name: String {
		var names: [String] = []
		if self.contains(.camera) { names.append("Cameras") }
		if self.contains(.comment) { names.append("Comments on roads") }
		if self.contains(.accident) { names.append("Road accidents") }
		if self.contains(.roadRestriction) { names.append("Road restrictions") }
		if self.contains(.roadWorks) { names.append("Road works") }
		if self.contains(.user) { names.append("Road events added by current user") }
		if self.contains(.other) { names.append("Other") }
		return names.joined(separator: ", ")
	}
}
