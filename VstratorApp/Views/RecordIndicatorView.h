//
//  RecordIndicatorView.h
//  VstratorApp
//
//  Created by Virtualler on 10.09.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordIndicatorViewDelegate;


@interface RecordIndicatorView : UIView

@property (nonatomic, weak) IBOutlet id<RecordIndicatorViewDelegate> delegate;
@property (nonatomic, readonly) BOOL started;
@property (nonatomic, readonly) BOOL active;

- (void)pause;
- (void)resume;
- (void)start;
- (void)startWithStartValue:(NSInteger)startValue endValue:(NSInteger)endValue;
- (void)stop;

@end


@protocol RecordIndicatorViewDelegate <NSObject>

@required
- (void)recordIndicatorViewDidFinish:(RecordIndicatorView *)sender;

@end
