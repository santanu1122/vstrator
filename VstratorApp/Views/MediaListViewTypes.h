//
//  MediaListViewTypes.h
//  VstratorApp
//
//  Created by Mac on 26.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#ifndef VstratorApp_MediaListViewTypes_h
#define VstratorApp_MediaListViewTypes_h

typedef enum {
    MediaActionNon,
    MediaActionSelect,
    MediaActionPlay,
    MediaActionDelete,
    MediaActionSideBySide,
    MediaActionVstrate,
    MediaActionDetails,
    MediaActionTrim,
    MediaActionUpload,
    MediaActionUploading,
    MediaActionUploaded,
    MediaActionUploadRetry,
    MediaActionShare,
    MediaActionStop
} MediaAction;

typedef enum {
    MediaListViewContentTypeNotSet,
    MediaListViewContentTypeUserClips,
    MediaListViewContentTypeUserSessions,
    MediaListViewContentTypeUserAllClipsAndSessions,
    MediaListViewContentTypeProClips,
    MediaListViewContentTypeProSessions,
    MediaListViewContentTypeAllClips,
    MediaListViewContentTypeAllSessions,
    MediaListViewContentTypeAllClipsAndSessions,
    MediaListViewContentTypeProInterviews,
    MediaListViewContentTypeProTutorials
} MediaListViewContentType;

@class Media, MediaListView, MediaListViewCell, MediaListViewHeader, MediaListViewProHeader;

@protocol MediaListViewDelegate<NSObject>

@required
- (void)mediaListView:(MediaListView *)sender media:(Media *)media action:(MediaAction)action;
@optional
- (void)mediaListViewSyncAction:(MediaListView *)sender;
- (void)mediaListViewNavigateToContentSetAction:(MediaListView *)sender;

@end

@protocol MediaListViewCellDelegate<NSObject>

@required
- (void)mediaListViewCell:(MediaListViewCell *)sender action:(MediaAction)action;

@end

@protocol MediaListViewHeaderDelegate<NSObject>

@required
- (void)mediaListViewHeaderSyncAction:(MediaListViewHeader *)sender;

@end

@protocol MediaListViewProHeaderDelegate<NSObject>

@required
- (void)mediaListViewProHeaderSelectAction:(MediaListViewProHeader *)sender;

@end

#endif
