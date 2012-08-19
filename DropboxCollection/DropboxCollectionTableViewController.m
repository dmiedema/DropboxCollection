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

@property (nonatomic, strong) DropboxQuicklookPreviewController *dropboxQuicklookController;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) NSString *urlPathOfQuicklookItemAsString;

- (NSArray *) dropboxDirectoryContents;

@end

@implementation DropboxCollectionTableViewController

@synthesize popoverController;

- (void) viewDidLoad {
    [super viewDidLoad];
    [[self tableView] registerNib:[UINib nibWithNibName:@"DBCTableView" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DBMetadataCell"];
    
    [[DropboxModel sharedInstance] addObserver:self
                                    forKeyPath:@"filePath"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
}

- (NSArray *) dropboxDirectoryContents {
    return [[[DropboxModel sharedInstance] metaDataForItemAtIndex:[self indexOfCellContainingView]] contents];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - KeyValue Method
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"filePath"]) {
        NSLog(@"Change observed in [[DropboxModel sharedInstance] filePath]");
        NSLog(@"[[DropboxModel shareInstance] filePath] changed to : %@", [[DropboxModel sharedInstance] filePath]);
        // somehow make this work
        [_dropboxQuicklookController setPreviewItemURL:[NSURL fileURLWithPath:[[DropboxModel sharedInstance] filePath]]];
        NSLog(@"Current/new _dropboxQuicklookController previewItemURL: %@", [_dropboxQuicklookController previewItemURL]);
        [[_dropboxQuicklookController view] setNeedsDisplay];
        [popoverController setContentViewController:_dropboxQuicklookController animated:YES];
    }
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
        [[DropboxModel sharedInstance] loadFile:[selectionMetadata path] intoPath:destPath];
        
        // Create the PopoverController
            // i think this might not have anything in the URL i'm loading yet, but when it is actually downloaded
            // to the location the popover doesnt update
            //
            // -- Potential way to fix it --
            // set up KeyValueObserving of the filePath just like what was done in
            // DropboxCollectionViewController to update when there is something in there
            // and while there hasnt been an update it might be beneficial to
            // set [_dropboxQuicklookController setPreviewItemURL:] to nil
            // and then once the KeyValue is observed update
            // [_dropboxQuicklookController setPreviewItemURL:] to the new
            // observed fileURLWithPath:destPath
        
        _dropboxQuicklookController = [[DropboxQuicklookPreviewController alloc] init];
        [_dropboxQuicklookController setPreviewItemURL:nil];
        popoverController = [[UIPopoverController alloc] initWithContentViewController:_dropboxQuicklookController];
        //        //- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
        //        [_popoverController presentPopoverFromRect:[[self collectionView] bounds] inView:[self collectionView] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        // changed the presentPopoverFromRect to pull in the tableViews superview to hopefully take up the entire screen.
        [popoverController presentPopoverFromRect:[[[self view] superview] bounds] inView:[[self view] superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
}

@end
