//
//  LeftCollectionViewLayout.swift
//  WeatherApp
//
//  Created by Anastasia Romanova on 22.08.2020.
//  Copyright © 2020 Anastasia Romanova. All rights reserved.
//

import UIKit

class LeftCollectionViewLayout: UICollectionViewFlowLayout {
  let customOffset: CGFloat = 20
  var recentOffset: CGPoint = .zero

  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    guard let collectionView = collectionView else {
      return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }

    let cvBounds = CGRect(
      x: proposedContentOffset.x,
      y: proposedContentOffset.y,
      width: collectionView.frame.width,
      height: collectionView.frame.height
    )

    guard let visibleAttributes = self.layoutAttributesForElements(in: cvBounds) else {
      return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }

    var candidate: UICollectionViewLayoutAttributes?
    for attributes in visibleAttributes {
      if attributes.center.x < proposedContentOffset.x {
          continue
      }

      candidate = attributes
      break
    }

    if proposedContentOffset.x + collectionView.frame.width > collectionView.contentSize.width - self.customOffset {
      candidate = visibleAttributes.last
    }

    if let candidate = candidate {
      self.recentOffset = CGPoint(x: candidate.frame.origin.x - self.customOffset, y: proposedContentOffset.y)
      return recentOffset
    } else {
      return recentOffset
    }
  }
}
