//
//  EventListController.h
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2013 Matt Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

@import UIKit;
@import CoreData;

@interface EventListController : UITableViewController<NSFetchedResultsControllerDelegate> {
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)insertNewEvent;
@end
