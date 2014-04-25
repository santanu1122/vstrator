//
//  Media+Extensions.h
//  VstratorApp
//
//  Created by user on 29.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Media.h"
#import "Callbacks.h"

@class Clip, Session;

typedef enum MediaType {
    MediaTypeUsual,
    MediaTypeFeaturedVideo,
    MediaTypeAll, // The last one used only in queries
} MediaType;

typedef enum {
	SearchMediaTypeClips,
	SearchMediaTypeSessions,
	SearchMediaTypeAll
} SearchMediaType;

typedef void (^ClipBlock)(Clip *clip);
typedef void (^SessionBlock)(Session *session);
typedef void (^ProcessMediaCallback)(NSError *error, NSData *thumbnail, NSNumber *duration, NSString *url, CGSize size);

@interface Media (Extensions)

@property (nonatomic, readonly) BOOL alreadyUploaded;
@property (nonatomic, readonly) BOOL isInUploadQueue;
@property (nonatomic, readonly) BOOL alreadyUploadedAndProcessed;
@property (nonatomic, readonly) BOOL isInUploadQueueOrNotProcessed;
@property (nonatomic, readonly) BOOL isUploadedWithErrors;
@property (nonatomic, readonly, getter=isProMedia) BOOL proMedia;
@property (nonatomic, copy, readonly) NSString *sportAndActionTitle;

@property (nonatomic, readonly) NSString* playbackImagesFolder;

-(BOOL)validateDelete:(NSError **)error;

-(BOOL)isProMedia;
-(BOOL)canDelete:(NSString *)authorIdentity;
-(BOOL)canEdit:(NSString *)authorIdentity;
-(BOOL)canShare:(NSString *)authorIdentity;
-(BOOL)canUpload:(NSString *)authorIdentity;
-(BOOL)canVstrate:(NSString *)authorIdentity;

-(void)performBlockIfClip:(ClipBlock)block;
-(void)performBlockIfSession:(SessionBlock)block;
-(void)performBlockIfClip:(ClipBlock)clipBlock orSession:(SessionBlock)sessionBlock;

-(void)setupURL:(NSURL*)url title:(NSString*)title authorIdentity:(NSString*)authorIdentity sportName:(NSString*)sportName actionName:(NSString*)actionName note:(NSString *)note callback:(ErrorCallback)callback;

+(id)findMediaWithURL:(NSURL *)url mediaType:(SearchMediaType)mediaType authorIdentity:(NSString *)authorIdentity inContext:(NSManagedObjectContext *)context error:(NSError **)error;
+(void)processMediaWithURL:(NSURL*)url callback:(ProcessMediaCallback)callback;
+(Media*)mediaFromObject:(NSDictionary*)object inContext:(NSManagedObjectContext*)context error:(NSError**)error;

@end
