//
//  IssueTypeSelectorView.h
//  VstratorApp
//
//  Created by Mac on 03.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IssueType.h"

@interface IssueTypeSelectorView : UIButton

@property (nonatomic, weak) IBOutlet UIView *controllerView;

@property (nonatomic) IssueTypeKey sourceIssueTypeKey;
@property (nonatomic, readonly) IssueTypeKey selectedIssueTypeKey;

@end
