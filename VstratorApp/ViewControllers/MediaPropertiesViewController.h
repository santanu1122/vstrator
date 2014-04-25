//
//  MediaPropertiesViewController.h
//  VstratorApp
//
//  Created by Mac on 16.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

extern NSString* RecentSportNameKey;
extern NSString* RecentActionNameKey;

@protocol MediaPropertiesViewControllerDelegate;


@interface MediaPropertiesViewController : BaseViewController

@property (nonatomic, weak) id<MediaPropertiesViewControllerDelegate> delegate;
@property (nonatomic, copy) NSURL *sourceURL;
@property (nonatomic, copy, readonly) NSString *mediaTitle;
@property (nonatomic, copy, readonly) NSString *mediaSportName;
@property (nonatomic, copy, readonly) NSString *mediaActionName;
@property (nonatomic, copy, readonly) NSString *mediaNote;

- (id)initWithDelegate:(id<MediaPropertiesViewControllerDelegate>)delegate
             sourceURL:(NSURL *)sourceURL;

- (id)initWithDelegate:(id<MediaPropertiesViewControllerDelegate>)delegate
             sourceURL:(NSURL *)sourceURL
                 title:(NSString *)title
             sportName:(NSString *)sportName
            actionName:(NSString *)actionName
                  note:(NSString *)note
         vstrationMode:(BOOL)vstrationMode;

@end


typedef enum {
    MediaPropertiesActionDelete,
    MediaPropertiesActionDeleteAndRetry,
    MediaPropertiesActionSave,
    MediaPropertiesActionSaveAndUse,
    MediaPropertiesActionSaveAndVstrate,
    MediaPropertiesActionSaveAndRetry
} MediaPropertiesAction;

@protocol MediaPropertiesViewControllerDelegate <NSObject>

@optional
- (void)mediaPropertiesViewControllerDidCancel:(MediaPropertiesViewController *)sender;
- (void)mediaPropertiesViewController:(MediaPropertiesViewController *)sender didAction:(MediaPropertiesAction)action;

@end
