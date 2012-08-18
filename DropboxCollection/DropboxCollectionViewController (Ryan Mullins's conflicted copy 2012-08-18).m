//
//  DropboxCollectionViewController.m
//  DropboxCollection
//
//  Created by Daniel Miedema on 8/15/12.
//  Copyright (c) 2012 com.apple.cocoacamp. All rights reserved.
//

// TODO
//    Set up inital TableViewController at index 0 in CollectionView

#import "DropboxCollectionViewController.h"
#import "DropboxCollectionTableViewController.h"
#import "DropboxModel.h"
#import "DropboxQuicklookPreviewController.h"


/* Implement ALL the protocols... just to be safe */

@interface DropboxCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray * tableViewControllers;

- (void) clearExistingDirectories;

@end

@implementation DropboxCollectionViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewDidLoad {
    [super viewDidLoad];
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

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"activeDirectories"]) {
        // check for touchevents, if any, wait.
        [self clearExistingDirectories];
        int index = 0;
        
        for (DBMetadata * metadata in [[DropboxModel sharedInstance] activeDirectories]) {
            DropboxCollectionTableViewController * viewController = [[DropboxCollectionTableViewController alloc] init];
            [viewController setIndexOfCellContainingView:index];
            [self addDropboxTableViewController:viewController];
            index++;
        }
        
        [[self collectionView] reloadData];
    }
    
//    if ([keyPath isEqualToString:@"filePath"]) {
//        // Make a quicklook view controller here
//        
//        DropboxQuicklookPreviewController *dropboxQL = [[DropboxQuicklookPreviewController alloc] init];
//        [dropboxQL setDataSource:dropboxQL];
//        [dropboxQL setItemToPreviewURL:[NSURL URLWithString:[[DropboxModel sharedInstance] filePath]]];
//        [dropboxQL setFiles:[NSArray arrayWithContentsOfURL:[dropboxQL itemToPreviewURL]]];
//        if ([QLPreviewController canPreviewItem:dropboxQL]) {
//            [self presentViewController:dropboxQL animated:YES completion:nil];
//        }
//    }
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
    static NSString * reuseID = @"dropboxCollectionViewCell";
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    [cell addSubview:[[[self tableViewControllers] objectAtIndex:[indexPath row]] view]];
//    CGFloat contentWidth = [[self collectionView] contentSize].width;
//    CGFloat viewWidth = [[self view] frame].size.width;
//    [[self collectionView] setContentOffset:CGPointMake(contentWidth - viewWidth, 0) animated:YES];
    
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

@end
