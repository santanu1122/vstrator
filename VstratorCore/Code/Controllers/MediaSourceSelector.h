//
//  MediaSourceSelector.h
//  VstratorApp
//
//  Created by Mac on 24.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MediaSourcePreferableNon,
    MediaSourcePreferableCamera,
    MediaSourcePreferableLibrary
} MediaSourcePreferable;

@protocol MediaSourceSelectorDelegate;

@interface MediaSourceSelector : NSObject<UIActionSheetDelegate>

@property (nonatomic, weak) id<MediaSourceSelectorDelegate> delegate;
@property (nonatomic, strong) NSArray *mediaTypes;

- (id)initWithDelegate:(id<MediaSourceSelectorDelegate>)delegate;
- (id)initWithDelegate:(id<MediaSourceSelectorDelegate>)delegate mediaTypes:(NSArray *)mediaTypes;
- (void)showWithPreferable:(MediaSourcePreferable)preferable;

@end

@protocol MediaSourceSelectorDelegate
@required
- (UIView *)view;
- (void)mediaSourceSelector:(MediaSourceSelector *)sender selected:(BOOL)selected type:(UIImagePickerControllerSourceType)sourceType;
@end

