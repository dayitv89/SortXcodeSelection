//
//  SortXcodeSelection.m
//  SortXcodeSelection
//
//  Created by Gaurav Sharma on 18/02/16.
//  Copyright © 2016 iOS Dev. All rights reserved.
//

#import "SortXcodeSelection.h"
#import "VVKeyboardEventSender.h"

@interface SortXcodeSelection()
@property (nonatomic, unsafe_unretained) NSTextView *sourceTextView;
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation SortXcodeSelection

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectionDidChange:)
                                                     name:NSTextViewDidChangeSelectionNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti {
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"GDS Sort Selected Area v1.0" action:@selector(doMenuAction) keyEquivalent:@""];
        [actionMenuItem setKeyEquivalent:@"`"];
        [actionMenuItem setKeyEquivalentModifierMask:NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

- (void)selectionDidChange:(NSNotification *)noti {
    if ([[noti object] isKindOfClass:[NSTextView class]]) {
        NSTextView *textView = [noti object];
        NSString *className = NSStringFromClass([textView class]);
        if ([className isEqualToString:@"DVTSourceTextView"] ||
            [className isEqualToString:@"IDEConsoleTextView"] ) {
            self.sourceTextView = textView;
        }
    }
}

- (void)doMenuAction {
    NSTextView *textView = self.sourceTextView;
    NSRange selectedRange = [textView selectedRange];
    NSString *text = textView.textStorage.string;
    NSString *nSelectedStr = [[text substringWithRange:selectedRange] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n"]];
    
    if (!nSelectedStr.length) {
        return;
    }
    
    NSArray *oldLines = [nSelectedStr componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSArray *newLines = [oldLines sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *newStr = [newLines componentsJoinedByString:@"\n"];

    //-- keyboar helper 3rd party
    VVKeyboardEventSender *kes = [[VVKeyboardEventSender alloc] init];
    [kes beginKeyBoradEvents];
    
    //-- start paste board
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];

    //-- copy user copy value
    NSString *originPBString = [pasteBoard stringForType:NSPasteboardTypeString];
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pasteBoard setString:newStr forType:NSStringPboardType];
    
    //-- type control+delete (delete)
    [kes sendKeyCode:kVK_Delete withModifierCommand:NO alt:NO shift:NO control:YES];

    //-- type cmd+v (paste)
    [kes sendKeyCode:kVK_ANSI_V withModifierCommand:YES alt:NO shift:NO control:NO];

    //-- Restore previous patse board content
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pasteBoard setString:originPBString forType:NSStringPboardType];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
