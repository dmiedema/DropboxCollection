//
//  DropboxQuicklookPreviewController.m
//  DropboxCollection
//
//  Created by Daniel Miedema on 8/16/12.
//  Copyright (c) 2012 com.apple.cocoacamp. All rights reserved.
//

#import "DropboxQuicklookPreviewController.h"

@implementation DropboxQuicklookPreviewController
@synthesize previewItemURL = _previewItemURL;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (NSURL *) previewItemURL {
//    if (!_previewItemURL) {
//        _previewItemURL = [[NSURL alloc] init];
//    }
    return _previewItemURL;
}

- (void) setPreviewItemURL:(NSURL *)previewItemURL {
    _previewItemURL = previewItemURL;
}
@end
