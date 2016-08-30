import KsApi
import Library
import Prelude
import ReactiveCocoa
import SafariServices
import UIKit

internal final class CheckoutViewController: DeprecatedWebViewController {
  private weak var loginToutViewController: UIViewController? = nil
  private let viewModel: CheckoutViewModelType = CheckoutViewModel()

  internal static func configuredWith(project project: Project,
                                              reward: Reward?,
                                              intent: CheckoutIntent) -> CheckoutViewController {
    let vc = Storyboard.Checkout.instantiate(CheckoutViewController)
    vc.viewModel.inputs.configureWith(project: project, reward: reward, intent: intent)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.closeLoginTout
      .observeForControllerAction()
      .observeNext { [weak self] _ in self?.closeLoginTout() }

    self.viewModel.outputs.goToSafariBrowser
      .observeForControllerAction()
      .observeNext { [weak self] url in self?.goToSafariBrowser(url: url) }

    self.viewModel.outputs.goToThanks
      .observeForControllerAction()
      .observeNext { [weak self] project in self?.goToThanks(project: project) }

    self.viewModel.outputs.goToWebModal
      .observeForControllerAction()
      .observeNext { [weak self] request in self?.goToWebModal(request: request) }

    self.viewModel.outputs.openLoginTout
      .observeForControllerAction()
      .observeNext { [weak self] _ in self?.openLoginTout() }

    self.viewModel.outputs.popViewController
      .observeForControllerAction()
      .observeNext { [weak self] _ in self?.popViewController() }

    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeNext { [weak self] request in
        self?.webView.loadRequest(request)
    }

    NSNotificationCenter.defaultCenter()
      .addObserverForName(CurrentUserNotifications.sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }
  }

  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest,
               navigationType: UIWebViewNavigationType) -> Bool {
    return self.viewModel.inputs.shouldStartLoad(withRequest: request, navigationType: navigationType)
  }

  private func closeLoginTout() {
    self.loginToutViewController?.dismissViewControllerAnimated(true, completion: nil)
  }

  private func goToSafariBrowser(url url: NSURL) {
    let controller = SFSafariViewController(URL: url)
    controller.modalPresentationStyle = .OverFullScreen
    self.presentViewController(controller, animated: true, completion: nil)
  }

  private func goToThanks(project project: Project) {
    let vc = ThanksViewController.configuredWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goToWebModal(request request: NSURLRequest) {
    let vc = WebModalViewController.configuredWith(request: request)
    let nav = UINavigationController(rootViewController: vc)
    self.presentViewController(nav, animated: true, completion: nil)
  }

  private func openLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .backProject)
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func popViewController() {
    self.navigationController?.popToRootViewControllerAnimated(true)
  }
}