//
//  DropboxCollectionViewController.h
//  DropboxCollection
//
//  Created by Daniel Miedema on 8/15/12.
//  Copyright (c) 2012 com.apple.cocoacamp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropboxCollectionViewController : UICollectionViewController

- (void) addDropboxTableViewController:(UITableViewController *)viewController;
- (NSInteger) numberOfCells;

@end
