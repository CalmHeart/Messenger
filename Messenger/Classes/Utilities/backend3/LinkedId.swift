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
class LinkedId: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func createItem() {

		let currentId = FUser.currentId()

		let firebase = Database.database().reference(withPath: FLINKEDID_PATH).child(currentId)
		firebase.updateChildValues([currentId: true])
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func createItem(userId: String) {

		let currentId = FUser.currentId()

		let firebase1 = Database.database().reference(withPath: FLINKEDID_PATH).child(currentId)
		firebase1.updateChildValues([userId: true])

		let firebase2 = Database.database().reference(withPath: FLINKEDID_PATH).child(userId)
		firebase2.updateChildValues([currentId: true])
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func createItem(userId1: String, userId2: String) {

		let firebase1 = Database.database().reference(withPath: FLINKEDID_PATH).child(userId1)
		firebase1.updateChildValues([userId2: true])

		let firebase2 = Database.database().reference(withPath: FLINKEDID_PATH).child(userId2)
		firebase2.updateChildValues([userId1: true])
	}
}
