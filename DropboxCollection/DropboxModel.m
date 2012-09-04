//
//  DropboxModel.m
//  DropboxCollection
//
//  Created by Ryan Mullins on 8/14/12.
//  Copyright (c) 2012 com.apple.cocoacamp. All rights reserved.
//

#import "DropboxModel.h"

@interface DropboxModel() <DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient * restClient;

@end

@implementation DropboxModel
@synthesize activeDirectories;

+ (DropboxModel *) sharedInstance {
    static DropboxModel * model;
    
    if (!model) {
        model = [[DropboxModel alloc] init];
    }
    
    return model;
}

- (id) init {
    self = [super init];
    
    if (self) {
        activeDirectories = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (DBMetadata *) metaDataForItemAtIndex:(NSUInteger)index {
    /* BUG:
     *
     * When accessing the TableViews for multiple directories, if one kicks off a 
     * call to the datamodel to load a new directory and another TableView is 
     * still being touched on the interface and error will occur where the second 
     * TableView will register a new event of some sort but the 
     * TableViewController for that second TableView has been removed from the
     * system and cannot be accessed so the app breaks.
     *
     * SOLUTION:
     * 
     * When interacting with any one table view, turn off selection of cells in 
     * all other visible table views.
     */
    return [[self activeDirectories] objectAtIndex:index];
}

- (void) jumpBackToDirectoryAtIndex:(NSUInteger)index {
    for (int i = [[self activeDirectories] count] - 1; i > index; i--) {
        [[self activeDirectories] removeLastObject];
    }
}

- (void) loadMetadataForPath:(NSString *)path {
    [[self restClient] loadMetadata:path];
}

- (void) loadFile:(NSString *)dropboxPath intoPath:(NSString *)destinationPath {
    /* I feel like this might be part of the error */
//    NSLog(@"\ndropboxPath: %@\n", dropboxPath);
//    NSLog(@"\nintoPath: %@\n", destinationPath);
    [[self restClient] loadFile:dropboxPath intoPath:destinationPath];
}

#pragma mark - DropboxSDK

- (DBRestClient *) restClient {
    if (!_restClient) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        [_restClient setDelegate:self];
    }
    return _restClient;
}

- (void) restClient:(DBRestClient *)client loadedFile:(NSString *)destPath {
    [self setFilePath:destPath];
}

- (void) restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSMutableArray * hackArray = [[NSMutableArray alloc] initWithArray:[self activeDirectories]];
    [hackArray addObject:metadata];
    [self setActiveDirectories:hackArray];
}

- (void) restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"ERROR: REST client could not load file. %@", error);
}

- (void) restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"ERROR: REST client could not load metadata. %@", error);
}

@end
