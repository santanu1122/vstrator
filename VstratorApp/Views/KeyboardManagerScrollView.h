//
//  IssueTypeSelectorView.h
//  VstratorApp
//
//  Created by Mac on 03.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

@interface KeyboardManagerScrollView : UIScrollView {
    UIEdgeInsets    _priorInset;
    BOOL            _priorInsetSaved;
    BOOL            _keyboardVisible;
    CGRect          _keyboardRect;
    CGSize          _originalContentSize;
}

- (void)adjustOffsetToIdealIfNeeded;
@end
