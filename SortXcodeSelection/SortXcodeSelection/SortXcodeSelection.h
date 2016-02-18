//
//  SortXcodeSelection.h
//  SortXcodeSelection
//
//  Created by Gaurav Sharma on 18/02/16.
//  Copyright © 2016 iOS Dev. All rights reserved.
//

#import <AppKit/AppKit.h>

@class SortXcodeSelection;

static SortXcodeSelection *sharedPlugin;

@interface SortXcodeSelection : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end