//
//  RVTransactionItemViewController.swift
//  Revolut
//
//  Created by Ilya Grechuhin on 25.07.16.
//
//

import UIKit

final class RVTransactionItemViewController: UIViewController {

  //MARK: - Const
  private struct Const {
    static let storyboardname = "Main"
    static let controllerId = "RVTransactionItemViewController"

    static let intPartAttributes = [NSFontAttributeName : UIFont.systemFontOfSize(28)]
    static let fracPartAttributes = [NSFontAttributeName : UIFont.systemFontOfSize(24)]

    static let maxFractionDigits = 2
  }

  //MARK: - Static functions
  static func controller(currency: RVCurrency, side: RVTransaction.Side, transaction: RVTransaction) -> RVTransactionItemViewController {
    let storyboard = UIStoryboard(name: Const.storyboardname, bundle: NSBundle.mainBundle())
    let controller = storyboard.instantiateViewControllerWithIdentifier(Const.controllerId) as! RVTransactionItemViewController
    controller._currency = currency
    controller.side = side
    controller.transaction = transaction
    return controller
  }

  //MARK: - Public var
  var currency: RVCurrency {
    return _currency
  }

  var amount: Double? {
    get {
      return Double(amountString.doubleReady())
    }
    set(newValue) {
      amountString = newValue != nil ? String.fromCurrency(newValue!) : ""
      refresh()
    }
  }

  var rateString: String {
    get {
      return rateLabel.text ?? ""
    }
    set(newValue) {
      rateLabel.hidden = newValue.isEmpty
      rateLabel.text = newValue
    }
  }

  //MARK: - Private var
  private var _currency: RVCurrency!
  private var side: RVTransaction.Side!
  private weak var transaction: RVTransaction!
  private var isActiveItem = false
  private var amountString: String {
    get {
      return amountTextField.text ?? ""
    }
    set(newValue) {
      if isActiveItem {
        isActiveItem = false
      } else {
        guard let doubleValue = Double(newValue.doubleReady()) where !doubleValue.isZero else {
          amountTextField.text = ""
          return
        }
      }

      let (intPart, fracPart) = newValue.splitToIntegerAndFractional()
      let attrText = NSMutableAttributedString(string: intPart,
                                               attributes: Const.intPartAttributes)
      if let fracPart = fracPart {
        attrText.appendAttributedString(NSMutableAttributedString(string: "\(String.decimalSeparator())\(fracPart)",
          attributes: Const.fracPartAttributes))
      }
      amountTextField.attributedText = attrText
    }
  }

  //MARK: - IBOutlet
  @IBOutlet private weak var currencyShortName: UILabel! {
    didSet {
      currencyShortName.text = currency.shortName
    }
  }
  @IBOutlet private weak var amountSign: UILabel! {
    didSet {
      amountSign.text = side! == .From ? "-" : "+"
    }
  }
  @IBOutlet private weak var amountTextField: UITextField!
  @IBOutlet private weak var youHaveLabel: UILabel!
  @IBOutlet private weak var rateLabel: UILabel! {
    didSet {
      rateLabel.hidden = side! == .From
    }
  }

  //MARK: - IBAction
  @IBAction private func amountTextFieldEditingChanged() {
    isActiveItem = true
    let selectedRange = amountTextField.selectedTextRange
    amountString = amountTextField.text ?? ""
    amountTextField.selectedTextRange = selectedRange
    transaction.refresh(side)
    refresh()
  }

  //MARK: - Public functions
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    transaction[side] = self
    refresh()
  }

  func refresh() {
    let account = RVAccount.instance
    let accountAmount = account.amount(currency.shortName)
    youHaveLabel.text = "You have \(currency.symbol)\(String.fromCurrency(accountAmount))"

    if let amount = amount {
      let regularColor = side == .To || account.check(currency.shortName, amount: amount)
      youHaveLabel.textColor = regularColor ? UIColor.lightTextColor() : UIColor.redColor()
      amountSign.hidden = false
    } else {
      amountSign.hidden = true
    }
    amountTextField.invalidateIntrinsicContentSize();
  }

  func becomeResponder() {
    if !amountTextField.isFirstResponder() {
      amountTextField.becomeFirstResponder()
    }
  }

}
