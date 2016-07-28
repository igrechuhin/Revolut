//
//  RVTransactionViewController.swift
//  Revolut
//
//  Created by Ilya Grechuhin on 22.07.16.
//
//

import UIKit

final class RVTransactionViewController: UIViewController {

  //MARK: - Const
  private struct Const {
    static let fromEmbedSegue = "ConverterFromEmbedSegue"
    static let toEmbedSegue = "ConverterToEmbedSegue"
  }

  //MARK: - Private var
  private var pageControllers: [RVTransaction.Side : RVTransactionPageController] = [:]

  private lazy var transaction: RVTransaction = {
    let transaction = RVTransaction()
    transaction.delegate = self
    return transaction
  }()

  private lazy var pageDatasources: [RVTransaction.Side : RVTransactionPageControllerDataSource] =
    [.From : RVTransactionPageControllerDataSource(transactionSide: .From, transaction: self.transaction),
     .To   : RVTransactionPageControllerDataSource(transactionSide: .To, transaction: self.transaction)]

  //MARK: - IBOutlet
  @IBOutlet private weak var exchangeButton: UIButton!
  @IBOutlet private weak var containerBottomOffset: NSLayoutConstraint!
  @IBAction private func exchangeButtonTouchUpInside() {
    transaction.perform()
  }

  //MARK: - Public functions
  override func viewDidLoad() {
    super.viewDidLoad()
    configKeyboardListener()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let segueIdentifier = segue.identifier else { return }
    if let dvc = segue.destinationViewController as? RVTransactionPageController {
      switch segueIdentifier {
      case Const.fromEmbedSegue:
        dvc.dataSource = pageDatasources[.From]
        dvc.activateController(RVCurrencyList.get().first!.shortName)
        pageControllers[.From] = dvc
      case Const.toEmbedSegue:
        dvc.dataSource = pageDatasources[.To]
        dvc.activateController(RVCurrencyList.get().last!.shortName)
        pageControllers[.To] = dvc
      default:
        break
      }
    }
  }

  //MARK: - Private functions
  private func configKeyboardListener() {
    let nc = NSNotificationCenter.defaultCenter()
    nc.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
  }

  @objc private func keyboardWillShow(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    guard let kbSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size else { return }

    containerBottomOffset.constant = min(kbSize.height, kbSize.width)
  }

}

extension RVTransactionViewController: RVTransactionDelegate {

  func onTransactionStatusUpdated() {
    exchangeButton.enabled = transaction.status == .Available
  }

  func onTransactionComplete(success: Bool, fromSymbol: String, toSymbol: String, fromAmount: Double, toAmount: Double) {
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    let info = "\(fromSymbol)\(String.fromCurrency(fromAmount)) to \(toSymbol)\(String.fromCurrency(toAmount))"
    if success {
      alert.title = "Complete"
      alert.message = "You've successfully exchanged \(info)"
    } else {
      alert.title = "Error"
      alert.message = "There was an error aonverting \(info)"
    }
    presentViewController(alert, animated: true, completion: nil)
  }

}
