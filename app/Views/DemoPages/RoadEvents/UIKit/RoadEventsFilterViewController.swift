import DGis
import UIKit

protocol RoadEventsFilterViewControllerDelegate: AnyObject {
	@MainActor
	func didUpdateVisibleEvents(_ visibleEvents: RoadEventDisplayCategoryOptionSet)
}

class RoadEventsFilterViewController: UITableViewController {
	private var visibleEvents: RoadEventDisplayCategoryOptionSet
	weak var delegate: RoadEventsFilterViewControllerDelegate?

	init(visibleEvents: RoadEventDisplayCategoryOptionSet) {
		self.visibleEvents = visibleEvents
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Road events to show"
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(
			title: "Close",
			style: .done,
			target: self,
			action: #selector(self.dismissView)
		)
	}

	@objc private func dismissView() {
		self.delegate?.didUpdateVisibleEvents(self.visibleEvents)
		dismiss(animated: true)
	}

	// MARK: - Table View Data Source

	override func numberOfSections(in _: UITableView) -> Int {
		1
	}

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		RoadEventDisplayCategoryOptionSet.allValues.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell") ?? UITableViewCell(style: .default, reuseIdentifier: "filterCell")

		let event = RoadEventDisplayCategoryOptionSet.allValues[indexPath.row]
		cell.textLabel?.text = event.name
		cell.accessoryType = self.visibleEvents.contains(event) ? .checkmark : .none

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let event = RoadEventDisplayCategoryOptionSet.allValues[indexPath.row]

		if self.visibleEvents.contains(event) {
			self.visibleEvents.remove(event)
		} else {
			self.visibleEvents.insert(event)
		}

		tableView.reloadRows(at: [indexPath], with: .automatic)
	}
}
