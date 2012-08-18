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

+ (DropboxModel *) sharedInstance {
    static DropboxModel * model;
    
    if (!model) {
        model = [[DropboxModel alloc] init];
    }
    
    return model;
}

- (DBMetadata *) metaDataForItemAtIndexPath:(NSUInteger)index {
    return [_activeDirectories objectAtIndex:index];
}

- (void) jumpBackToDirectoryAtIndex:(NSUInteger)index {
    for (int i = [[self activeDirectories] count]; i > index; i--) {
        [[self activeDirectories] removeLastObject];
    }
}

- (void) loadMetadataForPath:(NSString *)path {
    [[self restClient] loadMetadata:path];
}

- (NSMutableArray *) activeDirectories {
    if (!_activeDirectories) {
//        _activeDirectories = [[NSMutableArray alloc] initWithObjects:@"/", nil];
//    }
//    if ([self activeDirectories] == _activeDirectories) {
        [self setActiveDirectories:[[NSMutableArray alloc] initWithObjects:@"/", nil]];
    }
    NSLog(@"DEBUG: ObjectAtIndex[0]: %@", [_activeDirectories objectAtIndex:0]);
    // NSLog(@"DEBUG: ObjectAtIndex[0]: %@", [[self activeDirectories] objectAtIndex:0]);
    return _activeDirectories;
    //return [self activeDirectories];
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
    // Handle a file
}

- (void) restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    [[self activeDirectories] addObject:metadata];
    
    if (metadata.isDirectory) {
        // its a damn directory
        NSLog(@"Folder '%@' contains:", metadata.path);
        
        for (DBMetadata * item in metadata.contents) {
            // Handle the file
            NSLog(@"    %@", item.filename);
        }
    }
}

- (void) restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"ERROR: REST client could not load file. %@", error);
}

- (void) restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"ERROR: REST client could not load metadata. %@", error);
}

@end
