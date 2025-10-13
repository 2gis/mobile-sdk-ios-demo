import Foundation
import class UIKit.UIApplication

protocol IApplicationIdleTimerService {
	@MainActor
	var isIdleTimerDisabled: Bool { get set }
}

extension UIApplication: IApplicationIdleTimerService {}
