//
//  DropboxCollectionTableViewController.h
//  DropboxCollection
//
//  Created by Daniel Miedema on 8/15/12.
//  Copyright (c) 2012 com.apple.cocoacamp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropboxCollectionTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (readwrite) NSUInteger indexOfCellContainingView;

@end
