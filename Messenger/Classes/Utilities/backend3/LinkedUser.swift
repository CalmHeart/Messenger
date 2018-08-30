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
class LinkedUser: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func createItem(user: FUser) {

		let userId = user.objectId()

		let currentId = FUser.currentId()
		let currentUser = FUser.currentUser()

		let firebase1 = Database.database().reference(withPath: FLINKEDUSER_PATH).child(currentId)
		firebase1.updateChildValues([userId: user.values])

		let firebase2 = Database.database().reference(withPath: FLINKEDUSER_PATH).child(userId)
		firebase2.updateChildValues([currentId: currentUser.values])
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func createItem(userId1: String, userId2: String) {

		let user1 = user(userId: userId1)
		let user2 = user(userId: userId2)

		let firebase1 = Database.database().reference(withPath: FLINKEDUSER_PATH).child(userId1)
		firebase1.updateChildValues([userId2: user2])

		let firebase2 = Database.database().reference(withPath: FLINKEDUSER_PATH).child(userId2)
		firebase2.updateChildValues([userId1: user1])
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func updateItems() {

		if let linkedUserIds = UserDefaultsX.object(key: LINKEDUSERIDS) {
			let currentId = FUser.currentId()
			let currentUser = FUser.currentUser()

			var multiple: [String: Any] = [:]

			for userId in linkedUserIds as! [String] {
				let path = "\(userId)/\(currentId)"
				multiple[path] = currentUser.values
			}

			let firebase = Database.database().reference(withPath: FLINKEDUSER_PATH)
			firebase.updateChildValues(multiple, withCompletionBlock: { error, ref in
				if (error != nil) {
					ProgressHUD.showError("Network error.")
				}
			})
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func user(userId: String) -> [String: Any] {

		var user:[String: Any] = [:]

		let predicate = NSPredicate(format: "objectId == %@", userId)
		let dbuser = DBUser.objects(with: predicate).firstObject() as! DBUser

		if (dbuser.objectId != nil)		{ user[FUSER_OBJECTID] = dbuser.objectId 		}

		if (dbuser.email != nil)		{ user[FUSER_EMAIL] = dbuser.email 				}
		if (dbuser.phone != nil)		{ user[FUSER_PHONE] = dbuser.phone				}

		if (dbuser.firstname != nil)	{ user[FUSER_FIRSTNAME] = dbuser.firstname		}
		if (dbuser.lastname != nil)		{ user[FUSER_LASTNAME] = dbuser.lastname		}
		if (dbuser.fullname != nil)		{ user[FUSER_FULLNAME] = dbuser.fullname		}
		if (dbuser.country != nil)		{ user[FUSER_COUNTRY] = dbuser.country			}
		if (dbuser.location != nil)		{ user[FUSER_LOCATION] = dbuser.location		}
		if (dbuser.status != nil)		{ user[FUSER_STATUS] = dbuser.status			}

		if (dbuser.picture != nil)		{ user[FUSER_PICTURE] = dbuser.picture			}
		if (dbuser.thumbnail != nil)	{ user[FUSER_THUMBNAIL] = dbuser.thumbnail		}

		user[FUSER_KEEPMEDIA]		= dbuser.keepMedia
		user[FUSER_NETWORKIMAGE]	= dbuser.networkImage
		user[FUSER_NETWORKVIDEO]	= dbuser.networkVideo
		user[FUSER_NETWORKAUDIO]	= dbuser.networkAudio

		if (dbuser.wallpaper != nil)	{ user[FUSER_WALLPAPER] = dbuser.wallpaper		}

		if (dbuser.loginMethod != nil)	{ user[FUSER_LOGINMETHOD] = dbuser.loginMethod	}
		if (dbuser.oneSignalId != nil)	{ user[FUSER_ONESIGNALID] = dbuser.oneSignalId	}

		user[FUSER_LASTACTIVE]		= dbuser.lastActive
		user[FUSER_LASTTERMINATE]	= dbuser.lastTerminate

		user[FUSER_CREATEDAT]		= dbuser.createdAt
		user[FUSER_UPDATEDAT]		= dbuser.updatedAt

		return user
	}
}
