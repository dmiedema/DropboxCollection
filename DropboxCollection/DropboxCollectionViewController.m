//
//  DropboxCollectionViewController.m
//  DropboxCollection
//
//  Created by Daniel Miedema on 8/15/12.
//  Copyright (c) 2012 com.apple.cocoacamp. All rights reserved.
//

#import "DropboxCollectionViewController.h"
#import "DropboxCollectionTableViewController.h"
#import "DropboxModel.h"
#import "DropboxQuicklookPreviewController.h"
#import <QuickLook/QuickLook.h>


/* Implement ALL the protocols... just to be safe */

//TODO
// Have a modal segue when a file is selected.  It was crashing at one point with EXC_BAD_ACCESS but now it
// won't even crash. Nor does it observe the change or activate the segue -- and i didn't change anything.

@interface DropboxCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource, QLPreviewControllerDataSource, QLPreviewItem>

@property (nonatomic, strong) NSArray *file;
@property (nonatomic, strong) NSMutableArray * tableViewControllers;
@property (nonatomic) BOOL autoscrolled;
@property (nonatomic, strong) UIPopoverController *popoverController;

- (void) clearExistingDirectories;
- (void) animateScrollingToIndexPath:(NSIndexPath *)indexPath;

@end

@implementation DropboxCollectionViewController

@synthesize previewItemURL = _previewItemURL;
@synthesize popoverController; // had to manually synthesize to avoid an error, it doesn't like _popoverController


- (NSURL *)previewItemURL {
    if (!_previewItemURL) {
        _previewItemURL = [[NSURL alloc] initFileURLWithPath:[[DropboxModel sharedInstance] filePath]];
    }
    return _previewItemURL;
}

- (void)setPreviewItemURL:(NSURL *)newURL {
    _previewItemURL = newURL;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setAutoscrolled:NO];
    [[DropboxModel sharedInstance] addObserver:self
                                    forKeyPath:@"activeDirectories"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
    [[DropboxModel sharedInstance] addObserver:self
                                    forKeyPath:@"filePath"
                                       options:NSKeyValueObservingOptionNew
                                       context:nil];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) addDropboxTableViewController:(UITableViewController *)viewController {
    [[self tableViewControllers] addObject:viewController];
    [self addChildViewController:viewController];

}

- (void) clearExistingDirectories {
    for (int i = [[self tableViewControllers] count] - 1; i >= 0; i--) {
        UIViewController * viewController = [[self tableViewControllers] lastObject];
        [viewController removeFromParentViewController];
        [[self tableViewControllers] removeLastObject];
    }
}

- (void) animateScrollingToIndexPath:(NSIndexPath *)indexPath {
    if ( indexPath.row >= 2 ) {
        [[self collectionView] scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        [self setAutoscrolled: YES];
    }
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger) numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return [[self file] count];
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSLog(@"%@", [NSURL fileURLWithPath:[NSURL URLWithString:[[DropboxModel sharedInstance] filePath]]]);
	return [NSURL fileURLWithPath:[NSURL URLWithString:[[DropboxModel sharedInstance] filePath]]];
}

#pragma mark - keyValue Method
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"activeDirectories"]) {
        
        [self clearExistingDirectories];
        int index = 0;
        
        for (DBMetadata * metadata in [[DropboxModel sharedInstance] activeDirectories]) {
            DropboxCollectionTableViewController * viewController = [[DropboxCollectionTableViewController alloc] init];
            [[viewController view] setFrame:CGRectMake(0, 0, 335, 700)];
            //[[viewController view] setBackgroundColor:[UIColor clearColor]];
            [viewController setIndexOfCellContainingView:index];
            [self addDropboxTableViewController:viewController];
            index++;
        }
        [self setAutoscrolled:NO];
        [[self collectionView] reloadData];
    }
    
    if ([keyPath isEqualToString:@"filePath"]) {
        /* segue */
        NSLog(@"Was told to segue");
        [self performSegueWithIdentifier:@"quicklookPopOverSegue" sender:self];
    }
}

- (NSInteger) numberOfCells {
    return [[self tableViewControllers] count];
}

- (NSMutableArray *) tableViewControllers {
    if (!_tableViewControllers) {
        _tableViewControllers = [[NSMutableArray alloc] init];
    }
    
    return _tableViewControllers;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    /* protentially set up using Autolayout*/
    
    static NSString * reuseID = @"dropboxCollectionViewCell";
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    [cell addSubview:[[[self tableViewControllers] objectAtIndex:[indexPath row]] view]];
    
    if (![self autoscrolled]) {
        [self animateScrollingToIndexPath:indexPath];
    }
    
    return cell;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView
            viewForSupplementaryElementOfKind:(NSString *)kind
                                  atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self tableViewControllers] count];
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

#pragma mark - UICOllectionViewDelegate

- (BOOL) collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL) collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark -

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"quicklookPopOverSegue"]) {
        //segue correcly.
        NSLog(@"segue bro %@", [segue destinationViewController]);
        
        //[[segue destinationViewController] setDelegate:self];
        //[[segue destinationViewController] setDataSource:[[self tableViewControllers] lastObject]];
        [[segue destinationViewController] setPreviewItemURL:[[self file] lastObject]];
    }
}

@end
