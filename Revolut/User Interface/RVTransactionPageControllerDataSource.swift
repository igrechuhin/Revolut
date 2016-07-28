//
//  RVTransactionPageControllerDataSource.swift
//  Revolut
//
//  Created by Ilya Grechuhin on 25.07.16.
//
//

import UIKit

final class RVTransactionPageControllerDataSource: NSObject {

  //MARK: - Private var
  private var controllers: [RVTransactionItemViewController]

  //MARK: - Public functions
  init(transactionSide: RVTransaction.Side, transaction: RVTransaction) {
    controllers = RVCurrencyList.get().map {
      RVTransactionItemViewController.controller($0, side: transactionSide, transaction: transaction)
    }

    super.init()
  }

  func controller(currencyShortName: String) -> RVTransactionItemViewController? {
    if let index = controllers.indexOf({ $0.currency.shortName == currencyShortName }) {
      return controllers[index]
    } else {
      return nil
    }
  }

}

extension RVTransactionPageControllerDataSource: UIPageViewControllerDataSource {

  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    guard let exchangeViewController = viewController as? RVTransactionItemViewController else { return nil }
    guard let index = controllers.indexOf(exchangeViewController) else { return nil }

    let newIndex = index.advancedBy(-1)
    return newIndex < controllers.startIndex ? controllers.last : controllers[newIndex]
  }

  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    guard let exchangeViewController = viewController as? RVTransactionItemViewController else { return nil }
    guard let index = controllers.indexOf(exchangeViewController) else { return nil }

    let newIndex = index.advancedBy(1)
    return newIndex == controllers.endIndex ? controllers.first : controllers[newIndex]
  }

  func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    return controllers.count
  }

  func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    guard let exchangeViewController = pageViewController.viewControllers?.first as? RVTransactionItemViewController else { return 0 }
    if let index = controllers.indexOf(exchangeViewController) {
      return index
    } else {
      return 0
    }
  }

}