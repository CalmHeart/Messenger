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
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SINServiceDelegate, SINCallClientDelegate {

	var window: UIWindow!
	var tabBarController: UITabBarController!

	var chatsView: ChatsView!
	var callsView: CallsView!
	var peopleView: PeopleView!
	var groupsView: GroupsView!
	var settingsView: SettingsView!

	@objc var sinchService: SINService?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Crashlytics initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		Fabric.with([Crashlytics.self])

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Dialogflow initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		let configuration = AIDefaultConfiguration() as? AIConfiguration
		configuration?.clientAccessToken = DIALOGFLOW_ACCESS_TOKEN
		if let apiAI = ApiAI.shared() {
			apiAI.configuration = configuration
		}

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Firebase initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		FirebaseApp.configure()
		Database.database().isPersistenceEnabled = false

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Google login initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Facebook login initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Push notification initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		let authorizationOptions: UNAuthorizationOptions = [.sound, .alert, .badge]
		let userNotificationCenter = UNUserNotificationCenter.current()
		userNotificationCenter.requestAuthorization(options: authorizationOptions, completionHandler: { granted, error in
			if (error == nil) {
				DispatchQueue.main.async {
					UIApplication.shared.registerForRemoteNotifications()
				}
			}
		})

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// OneSignal initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		OneSignal.initWithLaunchOptions(launchOptions, appId: ONESIGNAL_APPID, handleNotificationReceived: nil, handleNotificationAction: nil, settings: [kOSSettingsKeyAutoPrompt: false])
		OneSignal.setLogLevel(ONE_S_LOG_LEVEL.LL_NONE, visualLevel: ONE_S_LOG_LEVEL.LL_NONE)

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// This can be removed once Firebase auth issue is resolved
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (UserDefaultsX.bool(key: "Initialized") == false) {
			UserDefaultsX.setObject(value: true, key: "Initialized")
			FUser.logOut()
		}

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Shortcut items initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		Shortcut.create()

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Connection, Location initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		Connection.shared
		Location.shared

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// RelayManager initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		RelayManager.shared

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Realm initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		Blockeds.shared
		Blockers.shared
		CallHistories.shared
		Friends.shared
		Groups.shared
		LinkedIds.shared
		LinkedUsers.shared
		Messages.shared
		Statuses.shared
		UserStatuses.shared

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// UI initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		window = UIWindow(frame: UIScreen.main.bounds)

		chatsView = ChatsView(nibName: "ChatsView", bundle: nil)
		callsView = CallsView(nibName: "CallsView", bundle: nil)
		peopleView = PeopleView(nibName: "PeopleView", bundle: nil)
		groupsView = GroupsView(nibName: "GroupsView", bundle: nil)
		settingsView = SettingsView(nibName: "SettingsView", bundle: nil)

		let navController1 = NavigationController(rootViewController: chatsView)
		let navController2 = NavigationController(rootViewController: callsView)
		let navController3 = NavigationController(rootViewController: peopleView)
		let navController4 = NavigationController(rootViewController: groupsView)
		let navController5 = NavigationController(rootViewController: settingsView)

		tabBarController = UITabBarController()
		tabBarController.viewControllers = [navController1, navController2, navController3, navController4, navController5]
		tabBarController.tabBar.isTranslucent = false
		tabBarController.selectedIndex = Int(DEFAULT_TAB)

		window.rootViewController = tabBarController
		window.makeKeyAndVisible()

		_ = chatsView.view
		_ = callsView.view
		_ = peopleView.view
		_ = groupsView.view
		_ = settingsView.view


		return true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func applicationWillResignActive(_ application: UIApplication) {

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func applicationDidEnterBackground(_ application: UIApplication) {

		Location.stop()
		UpdateLastTerminate(fetch: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func applicationWillEnterForeground(_ application: UIApplication) {

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func applicationDidBecomeActive(_ application: UIApplication) {

		Location.start()
		UpdateLastActive()

		FBSDKAppEvents.activateApp()

		OneSignal.idsAvailable({ userId, pushToken in
			if (pushToken != nil) {
				UserDefaults.standard.set(userId, forKey: ONESIGNALID)
			} else {
				UserDefaults.standard.removeObject(forKey: ONESIGNALID)
			}
			UpdateOneSignalId()
		})

		CacheManager.cleanupExpired()

		NotificationCenterX.post(notification: NOTIFICATION_APP_STARTED)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func applicationWillTerminate(_ application: UIApplication) {

	}

	// MARK: - CoreSpotlight methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {

		return false
	}


	// MARK: - Push notification methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

	}

	// MARK: - Home screen dynamic quick action methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {

	}
}
