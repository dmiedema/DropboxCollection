//
//  DropboxCollectionTableViewController.m
//  DropboxCollection
//
//  Created by Daniel Miedema on 8/15/12.
//  Copyright (c) 2012 com.apple.cocoacamp. All rights reserved.
//

#import "DropboxCollectionTableViewController.h"
#import "DropboxModel.h"
#import "DropboxCollectionViewController.h"
#import "DropboxQuicklookPreviewController.h"

@interface DropboxCollectionTableViewController ()

- (NSArray *) dropboxDirectoryContents;

@end

@implementation DropboxCollectionTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    [[self tableView] registerNib:[UINib nibWithNibName:@"DBCTableView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DBMetadataCell"];
}

- (NSArray *) dropboxDirectoryContents {
    return [[[DropboxModel sharedInstance] metaDataForItemAtIndex:[self indexOfCellContainingView]] contents];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self dropboxDirectoryContents] count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[DropboxModel sharedInstance] metaDataForItemAtIndex:[self indexOfCellContainingView]] path];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DBMetadataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell...
    DBMetadata *currentItemMetadata = [[self dropboxDirectoryContents] objectAtIndex:[indexPath row]];
    [[cell textLabel] setText: [currentItemMetadata filename]];
    
    if (![currentItemMetadata isDirectory]) {
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@, %@", [currentItemMetadata humanReadableSize], [currentItemMetadata lastModifiedDate]]];
    } else {
        [[cell detailTextLabel] setText:@"Directory"];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBMetadata * selectionMetadata = [[self dropboxDirectoryContents] objectAtIndex:[indexPath row]];
    
    if ([self indexOfCellContainingView] < ([[[DropboxModel sharedInstance] activeDirectories] count] - 1)) {
        [[DropboxModel sharedInstance] jumpBackToDirectoryAtIndex:[self indexOfCellContainingView]];
    }
    
    if (selectionMetadata.isDirectory) {
        [[DropboxModel sharedInstance] loadMetadataForPath:[selectionMetadata path]];
    } else {
//        NSArray * searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString * documentsDirectory = [searchPaths objectAtIndex:0];
//        NSString * destPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [selectionMetadata filename]];
//        [[DropboxModel sharedInstance] loadFile:[selectionMetadata path] intoPath:destPath];
    }
}

@end
