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
#import <QuickLook/QuickLook.h>


/* Implement ALL the protocols... just to be safe */

@interface DropboxCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *file;
@property (nonatomic, strong) NSMutableArray * tableViewControllers;
@property (nonatomic) BOOL autoscrolled;

- (void) clearExistingDirectories;
- (void) animateScrollingToIndexPath:(NSIndexPath *)indexPath;

@end

@implementation DropboxCollectionViewController

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
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) addDropboxTableViewController:(UITableViewController *)viewController {
    [[self tableViewControllers] addObject:viewController];
    [self addChildViewController:viewController];
}

- (void) clearExistingDirectories {
    // UIGestureRecognizer *gestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:nil];
    // NSLog(@"number of touches %i", [gestureRecognizer numberOfTouches]);
    /* Potentially loop over touches on screen and see if
        any of the touches are in a table view about to be removed.
        if they are, could just busy wait until the touch is done.
     */
    //if ([gestureRecognizer numberOfTouches] < 2) {
        for (int i = [[self tableViewControllers] count] - 1; i >= 0; i--) {
            UIViewController * viewController = [[self tableViewControllers] lastObject];
            [viewController removeFromParentViewController];
            [[self tableViewControllers] removeLastObject];
        }
    //}
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

            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [[viewController view] setFrame:CGRectMake(0, 0, 335, 700)];
                NSLog(@"Shits an iPad, fucker.");
            }
            else {
                [[viewController view] setFrame:CGRectMake(0, 0, 300, 400)];
                NSLog(@"if its not an iPad what the fuck do you think it is...?");
            }
            
            //[[viewController view] setBackgroundColor:[UIColor clearColor]];
            [viewController setIndexOfCellContainingView:index];
            [self addDropboxTableViewController:viewController];
            index++;
        }
        [self setAutoscrolled:NO];
        [[self collectionView] reloadData];
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
    
    NSLog(@"Autscrolled %i", [self autoscrolled]);
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

#pragma mark - UICollectionViewDelegate

- (BOOL) collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL) collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


@end
