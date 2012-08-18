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

@interface DropboxCollectionTableViewController ()

@property (nonatomic, strong) DropboxModel *dropboxModel;
@property (nonatomic, strong) NSArray *currentDirectoryContents;

@end

@implementation DropboxCollectionTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    NSLog(@"DEBUG: TableViewController hit viewDidLoad");
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -

- (NSArray *)currentDirectoryContents {
    if (!_currentDirectoryContents) {
        _currentDirectoryContents = [[[self dropboxModel] metaDataForItemAtIndexPath:[self indexOfCellContainingView]] contents];
    }
    return _currentDirectoryContents;
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"DEBUG: TableViewController - hit numberOfRowsInSection, count %@", [[self currentDirectoryContents] count]);
    // Return the number of rows in the section.
    return [_currentDirectoryContents count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"DEBUG: TableViewController hit cellForRowAtIndexPath");
    static NSString *cellIdentifier = @"DBMetadataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell...
    
    NSLog(@"DEBUG: TableViewController: row in index path for cell = %d", [indexPath row]);
    DBMetadata *currentItemMetadata = [[self dropboxModel] metaDataForItemAtIndexPath:[indexPath row]];
    
    cell.textLabel.text = @"%@", [currentItemMetadata filename];
    
    if (![currentItemMetadata isDirectory]) {
         cell.detailTextLabel.text = @"%@, %@", [currentItemMetadata humanReadableSize], [currentItemMetadata lastModifiedDate]; // size and 
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBMetadata * selectionMetadata = [[self currentDirectoryContents] objectAtIndex:[indexPath row]];
    
    if (selectionMetadata.isDirectory) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"main" bundle:nil];
        DropboxCollectionViewController * collectionView = [storyboard instantiateInitialViewController];
        DropboxCollectionTableViewController * newTableViewController = [[DropboxCollectionTableViewController alloc] init];
        [newTableViewController setIndexOfCellContainingView:([collectionView numberOfCells] + 1)];
        [collectionView addDropboxTableViewController:newTableViewController];
        
        DBMetadata * newMetadata = [[self currentDirectoryContents] objectAtIndex:[indexPath row]];
        [[self dropboxModel] loadMetadataForPath:[newMetadata path]];
    } else {
        // Bring up the quicklook
    }
}

@end
