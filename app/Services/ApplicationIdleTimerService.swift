import Foundation
import class UIKit.UIApplication

protocol IApplicationIdleTimerService {
	var isIdleTimerDisabled: Bool { get set }
}

extension UIApplication: IApplicationIdleTimerService {}
