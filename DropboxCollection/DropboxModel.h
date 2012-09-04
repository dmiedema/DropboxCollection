//
//  DropboxModel.h
//  DropboxCollection
//
//  Created by Ryan Mullins on 8/14/12.
//  Copyright (c) 2012 com.apple.cocoacamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

@interface DropboxModel : NSObject

+ (DropboxModel *) sharedInstance;

- (DBMetadata *) metaDataForItemAtIndex:(NSUInteger)index;
- (void) jumpBackToDirectoryAtIndex:(NSUInteger)index;
- (void) loadMetadataForPath:(NSString *)path;
- (void) loadFile:(NSString *)dropboxPath intoPath:(NSString *)destinationPath;

@property (nonatomic, strong) NSMutableArray * activeDirectories;
@property (atomic, strong) NSString * filePath;

@end
