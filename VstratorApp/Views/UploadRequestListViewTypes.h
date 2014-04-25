//
//  UploadRequestListViewTypes.h
//  VstratorApp
//
//  Created by Lion User on 25/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

typedef enum {
    UploadRequestActionRetry = 0,
    UploadRequestActionPlayMedia,
    UploadRequestActionDelete,
    UploadRequestActionStop
} UploadRequestAction;

typedef enum {
    UploadRequestContentTypeAll = 0,
    UploadRequestContentTypeInProgress,
    UploadRequestContentTypeCompleted
} UploadRequestContentType;

@class UploadRequest, UploadRequestListView, UploadRequestListViewCell;


