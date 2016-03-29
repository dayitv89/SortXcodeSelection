//
//  NSObject_Extension.m
//  SortXcodeSelection
//
//  Created by Gaurav Sharma on 18/02/16.
//  Copyright © 2016 iOS Dev. All rights reserved.
//


#import "NSObject_Extension.h"
#import "SortXcodeSelection.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[SortXcodeSelection alloc] initWithBundle:plugin];
        });
    }
}
@end
