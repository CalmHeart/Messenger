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
class AdvertCustomView: UIViewController, MFMailComposeViewControllerDelegate {

	@IBOutlet private var viewBox: UIView!
	@IBOutlet private var imageIcon: UIImageView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()

		imageIcon.layer.cornerRadius = 20
		imageIcon.layer.masksToBounds = true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		let rand = Int(arc4random_uniform(11) + 1)
		let image = String(format: "advert%02d", rand)
		imageIcon.image = UIImage(named: image)
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionContact(_ sender: Any) {

		if (MFMailComposeViewController.canSendMail()) {
			let mailCompose = MFMailComposeViewController()
			mailCompose.setToRecipients(["info@relatedcode.com"])
			mailCompose.setSubject("Custom development")
			mailCompose.mailComposeDelegate = self
			present(mailCompose, animated: true)
		} else {
			ProgressHUD.showError("Please configure your mail first.")
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@IBAction func actionCancel(_ sender: Any) {

		dismiss(animated: true)
	}

	// MARK: - MFMailComposeViewControllerDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

		if (result == MFMailComposeResult.sent) {
			ProgressHUD.showSuccess("Mail sent successfully.")
		}
		controller.dismiss(animated: true)
	}
}
