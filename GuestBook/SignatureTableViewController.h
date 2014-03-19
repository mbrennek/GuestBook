//
//  SignatureTableViewController.h
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2013 Matt Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SignatureTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

- (void)updatePredicate;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
