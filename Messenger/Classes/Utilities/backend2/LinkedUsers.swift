//
// Copyright (c) 2018 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//-------------------------------------------------------------------------------------------------------------------------------------------------
class LinkedUsers: NSObject {

	private var timer: Timer?
	private var refreshUILinkedUsers = false
	private var firebase: DatabaseReference?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: LinkedUsers = {
		let instance = LinkedUsers()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		NotificationCenterX.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_APP_STARTED)
		NotificationCenterX.addObserver(target: self, selector: #selector(initObservers), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenterX.addObserver(target: self, selector: #selector(actionCleanup), name: NOTIFICATION_USER_LOGGED_OUT)

		timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(refreshUserInterface), userInfo: nil, repeats: true)
	}

	// MARK: - Backend methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func initObservers() {

		if (FUser.currentId() != "") {
			if (firebase == nil) {
				createObservers()
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func createObservers() {

		firebase = Database.database().reference(withPath: FLINKEDUSER_PATH).child(FUser.currentId())
		let query = firebase?.queryOrdered(byChild: FUSER_UPDATEDAT)

		query?.observe(DataEventType.childAdded, with: { snapshot in
			let user = snapshot.value as! [String: Any]
			if (user[FUSER_CREATEDAT] as? Int64 != nil) && (user[FUSER_FULLNAME] as? String != nil) {
				DispatchQueue(label: "LinkedUsers").async {
					self.updateRealm(user: user)
					self.refreshUILinkedUsers = true
				}
			}
		})

		query?.observe(DataEventType.childChanged, with: { snapshot in
			let user = snapshot.value as! [String: Any]
			if (user[FUSER_CREATEDAT] as? Int64 != nil) && (user[FUSER_FULLNAME] as? String != nil) && (FUser.currentId() != "") {
				DispatchQueue(label: "LinkedUsers").async {
					self.updateRealm(user: user)
					self.refreshUILinkedUsers = true
				}
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateRealm(user: [String: Any]) {

		do {
			let realm = RLMRealm.default()
			realm.beginWriteTransaction()
			DBUser.createOrUpdate(in: realm, withValue: user)
			try realm.commitWriteTransaction()
		} catch {
			ProgressHUD.showError("Realm commit error.")
		}
	}

	// MARK: - Cleanup methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCleanup() {

		firebase?.removeAllObservers()
		firebase = nil
	}

	// MARK: - Notification methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func refreshUserInterface() {

		if (refreshUILinkedUsers) {
			NotificationCenterX.post(notification: NOTIFICATION_REFRESH_USERS)
			refreshUILinkedUsers = false
		}
	}
}
