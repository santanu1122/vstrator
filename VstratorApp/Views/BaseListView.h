//
//  BaseListView.h
//  VstratorApp
//
//  Created by Lion User on 16/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataSelector.h"

@interface BaseListView : UIView<UITableViewDelegate, UITableViewDataSource, CoreDataSelectorDelegate>

@property (nonatomic, strong, readonly) CoreDataSelector *coreDataSelector;
@property (nonatomic, copy) NSString* queryString;
@property (nonatomic) NSInteger contentType;

@property (nonatomic, copy, readonly) NSString *infoNotExistText;
@property (nonatomic, copy, readonly) NSString *infoNotFoundText;

- (void)setInfoWithNotExistText:(NSString *)notExistText
                   notFoundText:(NSString *)notFoundText;

- (void) reload;
- (void) refreshTable;
- (void) setup;
- (id) objectByCell:(id)sender;
- (void) setContentTypeField:(NSInteger)contentType;
- (NSInteger)numberOfRows;
- (void)switchViewsByCoreData;
- (id)objectAtIndexPath:(NSIndexPath*)indexPath;

@end
