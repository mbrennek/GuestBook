//
//  EventListGridViewController.h
//  GuestBook
//
//  Created by Matt Brenneke on 3/8/12.
//  Copyright 2013 Matt Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

@import UIKit;
@import CoreData;

@interface EventListGridViewController : UIViewController<NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak, readwrite) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong, readwrite) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;

@end
