//
//  DropboxQuicklookPreviewController.h
//  DropboxCollection
//
//  Created by Daniel Miedema on 8/16/12.
//  Copyright (c) 2012 com.apple.cocoacamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

@interface DropboxQuicklookPreviewController : QLPreviewController <QLPreviewControllerDelegate, QLPreviewItem>


// Required properties by QLPreviewItem
@property (atomic, strong) NSURL *previewItemURL;

@end
