import UIKit

class DeviceInfoIE {
    static let shared = DeviceInfoIE()
    
    var deviceType: UIUserInterfaceIdiom
    
    private init() {
        self.deviceType = UIDevice.current.userInterfaceIdiom
    }
}
