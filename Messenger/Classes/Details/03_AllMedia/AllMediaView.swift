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
class AllMediaView: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NYTPhotosViewControllerDelegate {

	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var viewFooter: UIView!
	@IBOutlet var labelFooter: UILabel!
	@IBOutlet var buttonShare: UIBarButtonItem!
	@IBOutlet var buttonDelete: UIBarButtonItem!

	private var chatId = ""
	private var selection: [String] = []
	private var dbmessages_media: [DBMessage] = []

	private var months: [String] = []
	private var dictionary: [String: [DBMessage]] = [:]

	private var isSelecting = false
	private var buttonDone: UIBarButtonItem?
	private var buttonSelect: UIBarButtonItem?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func myInit(chatId chatId_: String) {

		chatId = chatId_
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "All Media"

		buttonDone = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionCancel))
		buttonSelect = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(actionSelect))

		collectionView.register(UINib(nibName: "AllMediaHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "AllMediaHeader")
		collectionView.register(UINib(nibName: "AllMediaCell", bundle: nil), forCellWithReuseIdentifier: "AllMediaCell")

		updateDetails()
		loadMedia()
	}

	// MARK: - Load methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadMedia() {

		months.removeAll()
		dictionary.removeAll()
		dbmessages_media.removeAll()

		var pictures: Int = 0
		var videos: Int = 0

		let predicate = NSPredicate(format: "chatId == %@ AND isDeleted == NO", chatId)
		let dbmessages = DBMessage.objects(with: predicate).sortedResults(usingKeyPath: FMESSAGE_CREATEDAT, ascending: true)

		for i in 0..<dbmessages.count {
			let dbmessage = dbmessages[i] as! DBMessage
			
			if (dbmessage.type == MESSAGE_PICTURE) {
				if (DownloadManager.pathImage(link: dbmessage.picture) != nil) {
					dbmessages_media.append(dbmessage)
					pictures += 1
				}
			}

			if (dbmessage.type == MESSAGE_VIDEO) {
				if (DownloadManager.pathVideo(link: dbmessage.video) != nil) {
					dbmessages_media.append(dbmessage)
					videos += 1
				}
			}
		}

		labelFooter.text = "Pictures: \(pictures), Videos: \(videos)"

		for dbmessage in dbmessages_media {
			let created = Date.date(timestamp: dbmessage.createdAt)
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy MMM"
			let month = formatter.string(from: created)

			if (months.contains(month) == false) {
				months.append(month)
			}

			if (dictionary[month] == nil) {
				dictionary[month] = [DBMessage]()
			}

			dictionary[month]!.append(dbmessage)
		}

		collectionView.reloadData()
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCancel() {

		isSelecting = false
		updateDetails()

		selection.removeAll()
		collectionView.reloadData()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionSelect() {

		isSelecting = true
		updateDetails()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionShare(_ sender: Any) {

		AdvertPremium(target: self);
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionDelete(_ sender: Any) {

		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
			self.actionDelete()
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		present(alert, animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionDelete() {

		AdvertPremium(target: self);
	}

	// MARK: - Helper methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func updateDetails() {

		navigationItem.rightBarButtonItem = (isSelecting) ? buttonDone : buttonSelect

		buttonShare.tintColor = isSelecting ? nil : UIColor.clear
		buttonDelete.tintColor = isSelecting ? nil : UIColor.clear

		buttonShare.isEnabled = isSelecting
		buttonDelete.isEnabled = isSelecting
	}

	// MARK: - UICollectionViewDataSource
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in collectionView: UICollectionView) -> Int {

		return months.count
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		let month = months[section]
		let dbmessages_section = dictionary[month] as! [DBMessage]
		return dbmessages_section.count
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

		if (kind == UICollectionElementKindSectionHeader) {
			let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "AllMediaHeader", for: indexPath) as! AllMediaHeader
			header.label.text = months[indexPath.section]
			return header
		}
		return UICollectionReusableView()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllMediaCell", for: indexPath) as! AllMediaCell

		let month = months[indexPath.section]
		let dbmessages_section = dictionary[month] as! [DBMessage]
		let dbmessage = dbmessages_section[indexPath.item]

		var selected = selection.contains(dbmessage.objectId)

		cell.bindData(dbmessage: dbmessage, selected: selected)

		return cell
	}

	// MARK: - UICollectionViewDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		collectionView.deselectItem(at: indexPath, animated: true)

		let month = months[indexPath.section]
		let dbmessages_section = dictionary[month] as! [DBMessage]
		let dbmessage = dbmessages_section[indexPath.item]

		if (isSelecting == false) {
			if (dbmessage.type == MESSAGE_PICTURE) {
				showPicture(dbmessage: dbmessage)
			}
			if (dbmessage.type == MESSAGE_VIDEO) {
				showVideo(dbmessage: dbmessage)
			}
		}

		if (isSelecting == true) {
			if selection.contains(dbmessage.objectId) {
				if let index = selection.index(of: dbmessage.objectId) {
					selection.remove(at: index)
				}
			} else {
				selection.append(dbmessage.objectId)
			}
			collectionView.reloadItems(at: [indexPath])
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func showPicture(dbmessage: DBMessage) {

		if let path = DownloadManager.pathImage(link: dbmessage.picture) {

			let dictionary = PictureView.photos(messageId: dbmessage.objectId, chatId: chatId)
			let photoItems = dictionary["photoItems"] as! [NYTPhoto]
			let initialPhoto = dictionary["initialPhoto"] as! NYTPhoto

			let pictureView = PictureView(photos: photoItems, initialPhoto: initialPhoto)
			pictureView.delegate = self
			pictureView.setMessages(messages: true)
			present(pictureView, animated: true)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func showVideo(dbmessage: DBMessage) {

		if let path = DownloadManager.pathVideo(link: dbmessage.video) {
			let url = URL(fileURLWithPath: path)
			let videoView = VideoView()
			videoView.myInit(url: url)
			present(videoView, animated: true)
		}
	}

	// MARK: - NYTPhotosViewControllerDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func photosViewControllerWillDismiss(_ photosViewController: NYTPhotosViewController?) {

		loadMedia()
	}
}
