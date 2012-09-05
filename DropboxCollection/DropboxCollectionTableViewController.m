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

@interface DropboxCollectionTableViewController () <QLPreviewControllerDataSource>

@property (nonatomic, strong) DropboxQuicklookPreviewController *dropboxQuicklookController;
@property (nonatomic, strong) NSString *urlPathOfQuicklookItemAsString;
/* View Controller shit - Attempts and things to get this shit to work */
@property (nonatomic, strong) QLPreviewController *quicklookPreviewController;
@property (atomic, strong) NSURL *urlOfDropboxFile;

- (NSArray *) dropboxDirectoryContents;

@end

@implementation DropboxCollectionTableViewController

#define DEBUG 1

#pragma mark - view life cycle
- (void) viewDidLoad {
    [super viewDidLoad];
    [[self tableView] registerNib:[UINib nibWithNibName:@"DBCTableView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DBMetadataCell"];
    
    [[DropboxModel sharedInstance] addObserver:self
                                    forKeyPath:@"filePath"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[DropboxModel sharedInstance] removeObserver:self forKeyPath:@"filePath"];
}

#pragma mark -

- (NSArray *) dropboxDirectoryContents {
    return [[[DropboxModel sharedInstance] metaDataForItemAtIndex:[self indexOfCellContainingView]] contents];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - KeyValue Method
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"filePath"]) {
#if DEBUG
        NSLog(@"Change observed in [[DropboxModel sharedInstance] filePath]");
        NSLog(@"[[DropboxModel shareInstance] filePath] changed to : %@", [[DropboxModel sharedInstance] filePath]);
#endif
        // somehow make this work
        // set up quicklook controller
        //[_quicklookPreviewController setDataSource:[NSURL fileURLWithPath:[[DropboxModel sharedInstance] filePath]]];
        
        _urlOfDropboxFile = [NSURL fileURLWithPath:[[DropboxModel sharedInstance] filePath]];
        
        // set modal display property
        [_quicklookPreviewController setModalPresentationStyle:UIModalPresentationPageSheet];
        [_quicklookPreviewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        // PRESENT!
        [_quicklookPreviewController refreshCurrentPreviewItem];
#if DEBUG
        NSLog(@"currentPreviewItem : %@", [_quicklookPreviewController currentPreviewItem]);
#endif
    }
}

#pragma mark - QuicklookPreviewControllerDataSource Methods

- (NSInteger) numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    // ~this is a bad idea.~
    // Create an NSAray with the contents of urlOfDropboxFile and just return the count.
    return [[NSArray arrayWithContentsOfURL:_urlOfDropboxFile] count];
}
- (id<QLPreviewItem>) previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return _urlOfDropboxFile;
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
        NSArray * searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [searchPaths objectAtIndex:0];
        NSString * destPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [selectionMetadata filename]];
        
        _urlOfDropboxFile = nil;
        
        // Set up quicklook controller and set datasource to nil before we load the item from the DropboxModel
        _quicklookPreviewController = [[QLPreviewController alloc] init];
        [_quicklookPreviewController setDataSource:self];
        
        // modify quicklook controller appearance 
//        [_quicklookPreviewController setModalPresentationStyle:UIModalPresentationPageSheet];
//        [_quicklookPreviewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];

        // not sure if its a good idea or what but fuck it, trying it.
        [[DropboxModel sharedInstance] loadFile:[selectionMetadata path] intoPath:destPath];

        /* code ripped from http://developer.apple.com/library/ios/#featuredarticles/ViewControllerPGforiPhoneOS/ModalViewControllers/ModalViewControllers.html */
//        UINavigationController *navigationController = [[UINavigationController alloc]
//                                                        initWithRootViewController:_quicklookPreviewController];
//        [self presentViewController:navigationController animated:YES completion: nil];
        [self presentViewController:_quicklookPreviewController animated:YES completion:nil];       
    }
}

#pragma mark - dealloc

- (void) dealloc {
    [[DropboxModel sharedInstance] removeObserver:self forKeyPath:@"filePath"];
    // [super dealloc]; causes an error
}

@end
