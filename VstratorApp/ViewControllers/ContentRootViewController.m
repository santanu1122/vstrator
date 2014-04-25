//
//  ContentRootViewController.m
//  VstratorApp
//
//  Created by Mac on 01.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ContentRootViewController.h"

#import "AccountController2.h"
#import "BaseTabbedViewController.h"
#import "CameraManagerViewController.h"
#import "ContentSetViewController.h"
#import "ContentQuickStartViewController.h"
#import "DownloadContent+Extensions.h"
#import "MediaListView.h"
#import "MediaService.h"
#import "MediaViewController.h"
#import "NotificationViewController.h"
#import "PurchaseManager.h"
#import "SideBySideEditorViewController.h"
#import "TabContentSetView.h"
#import "TabProView.h"
#import "TabSideBySideView.h"
#import "TabVstrateView.h"
#import "VstratorExtensions.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface ContentRootViewController()<CameraManagerResponderDelegate, ContentSetViewControllerDelegate, ContentQuickStartViewControllerDelegate, MediaViewControllerDelegate, TabContentSetViewDelegate, TabProViewDelegate, TabSideBySideViewDelegate, TabVstrateViewDelegate, TelestrationEditorViewControllerDelegate>
{
    GetClipCallback _captureClipCallback;
    BOOL _viewDidAppearOnce;
}

@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak, readonly) UIView<TabBarViewItemDelegate> *tabBarViewItem;
@property (nonatomic, strong, readonly) TabVstrateView *tabVstrateViewRef;
@property (nonatomic, weak, readonly) TabProView *tabProViewItem;
@property (nonatomic, weak, readonly) TabSideBySideView *tabSideBySideViewItem;
@property (nonatomic, weak, readonly) TabVstrateView *tabVstrateViewItem;
@property (nonatomic, weak, readonly) TabContentSetView *tabContentSetItem;

@end

#pragma mark -

@implementation ContentRootViewController

#pragma mark Properties

@synthesize containerView = _containerView;
@synthesize tabVstrateViewRef = _tabVstrateViewRef;

- (UIView<TabBarViewItemDelegate> *)tabBarViewItem
{
    return (UIView<TabBarViewItemDelegate> *)[self.containerView.subviews lastObject];
}

- (TabProView *)tabProViewItem
{
    if (self.tabBarViewItem == nil || ![self.tabBarViewItem isKindOfClass:TabProView.class])
        return nil;
    return (TabProView *)self.tabBarViewItem;
}

- (TabProView *)createTabProView
{
    TabProView *item = [[TabProView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height)];
    item.delegate = self;
    return item;
}

- (TabSideBySideView *)tabSideBySideViewItem
{
    if (self.tabBarViewItem == nil || ![self.tabBarViewItem isKindOfClass:TabSideBySideView.class])
        return nil;
    return (TabSideBySideView *)self.tabBarViewItem;
}

- (TabSideBySideView *)createTabSideBySideView
{
    TabSideBySideView *item = [[TabSideBySideView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height)];
    item.delegate = self;
    return item;
}

- (TabVstrateView *)tabVstrateViewItem
{
    if (self.tabBarViewItem == nil || ![self.tabBarViewItem isKindOfClass:TabVstrateView.class])
        return nil;
    return (TabVstrateView *)self.tabBarViewItem;
}

- (TabVstrateView *)tabVstrateViewRef
{
    if (_tabVstrateViewRef == nil) {
        _tabVstrateViewRef = [[TabVstrateView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height)];
        _tabVstrateViewRef.delegate = self;
    }
    return _tabVstrateViewRef;
}

- (TabContentSetView *)tabContentSetItem
{
    if (self.tabBarViewItem == nil || ![self.tabBarViewItem isKindOfClass:TabContentSetView.class])
        return nil;
    return (TabContentSetView *)self.tabBarViewItem;
}

- (TabContentSetView *)createTabContentSetView
{
    TabContentSetView *tabContentSetItem = [[TabContentSetView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height)];
    tabContentSetItem.delegate = self;
    return tabContentSetItem;
}

#pragma mark Navigation/Tab Bar

- (void)navigationBarView:(NavigationBarView *)sender action:(NavigationBarViewAction)action
{
    // Search
    if (action == NavigationBarViewActionSearch) {
        [super navigationBarView:sender action:action];
        return;
    }

    // (mostly for SearchBar)
    [self.view endEditing:YES];
    // SearchBar
    [self updateSearchBarState];

    // Back for Side by Side Tab
    if (action == NavigationBarViewActionBack && self.tabSideBySideViewItem) {
        if (self.tabSideBySideViewItem.selectedContentType == TabSideBySideViewContentTypeMedia)
            self.tabSideBySideViewItem.selectedContentType = TabSideBySideViewContentTypeSelector;
        else
            [self.tabBarView setSelectedActionAndFire:TabBarActionVstrate];
    }
    else if (action == NavigationBarViewActionBack && self.tabContentSetItem) {
        [self.tabBarView setSelectedActionAndFire:TabBarActionPro];
    }
    // Home for any Tab
    else if (action == NavigationBarViewActionHome) {
        [self showContentQuickStartViewController:NO];
    }
    // Super
    else {
        [super navigationBarView:sender action:action];
    }
}

- (void)tabBarView:(TabBarView *)sender action:(TabBarAction)action changesSelection:(BOOL)changesSelection
{
    [super tabBarView:sender action:action changesSelection:changesSelection];
    // (mostly for SearchBar)
    [self.view endEditing:YES];
    // switch views
    if (changesSelection) {
        if (action == TabBarActionCapture) {
            CameraManagerViewController *vc = [[CameraManagerViewController alloc] init];
            vc.delegate = self;
            [self presentViewController:vc animated:NO completion:nil];
        } else if (action == TabBarActionPro) {
            if (self.tabProViewItem == nil) {
                [self.containerView switchViews:[self createTabProView]];
                self.navigationBarView.title = self.title = VstratorStrings.TitleContentPro;
                self.navigationBarView.showSearch = (self.tabProViewItem.selectedContentType == TabProViewContentTypeTutorials);
            }
            [self setOrientation:self.interfaceOrientation forView:self.tabProViewItem];
        } else if (action == TabBarActionSideBySide) {
            if (self.tabSideBySideViewItem == nil) {
                [self.containerView switchViews:[self createTabSideBySideView]];
                self.navigationBarView.title = self.title = VstratorStrings.TitleContentSideBySide;
                self.navigationBarView.showSearch = (self.tabSideBySideViewItem.selectedContentType == TabSideBySideViewContentTypeMedia);
            }
            [self setOrientation:self.interfaceOrientation forView:self.tabSideBySideViewItem];
        } else if (action == TabBarActionVstrate) {
            if (self.tabVstrateViewItem == nil) {
                [self.containerView switchViews:self.tabVstrateViewRef];
                self.navigationBarView.title = self.title = VstratorConstants.NavigationBarLogoTitle;
                self.navigationBarView.showSearch = YES;
            }
            [self setOrientation:self.interfaceOrientation forView:self.tabVstrateViewItem];
        } else {
            [self.containerView switchViews:nil];
            self.navigationBarView.title = self.title = nil;
            self.navigationBarView.showSearch = NO;
        }
    }
    // SearchBar
    [self updateSearchBarState];
}

#pragma mark TelestrationEditorViewControllerDelegate

- (void)telestrationEditorViewControllerDidSave:(TelestrationEditorViewController *)sender session:(Session *)session
{
    [self.tabBarView setSelectedActionAndFire:TabBarActionVstrate];
    self.tabVstrateViewItem.selectedContentType = MediaListViewContentTypeUserClips;
    [self tabVstrateView:self.tabVstrateViewItem media:session action:MediaActionSelect];
}

#pragma mark Tab*ViewDelegate

- (void)tabContentSetView:(TabContentSetView *)sender didSelectContentSet:(ContentSet *)contentSet
{
    ContentSetViewController *vc = [[ContentSetViewController alloc] initWithDelegate:self contentSet:contentSet];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)tabProView:(TabProView *)sender didSwitchToContent:(TabProViewContentType)contentType
{
    // NavigationBar
    self.navigationBarView.showSearch = (contentType == TabProViewContentTypeTutorials);
    // (mostly for SearchBar)
    [self.view endEditing:YES];
    // SearchBar
    [self updateSearchBarState];
}

- (void)tabProView:(TabProView *)sender media:(Media *)media action:(MediaAction)action
{
    [self tabBarMedia:media action:action];
}

- (void)tabProViewNavigateToContentSetAtion:(TabProView *)sender
{
    // (mostly for SearchBar)
    [self.view endEditing:YES];
    // SearchBar
    [self updateSearchBarState];
    // perform
    [self.tabBarView setSelectedAction:TabBarActionNotSet];
    [self.containerView switchViews:[self createTabContentSetView]];
}

- (void)tabSideBySideView:(TabSideBySideView *)sender didSwitchToContent:(TabSideBySideViewContentType)contentType
{
    // NavigationBar
    self.navigationBarView.showSearch = (contentType == TabSideBySideViewContentTypeMedia);
    // (mostly for SearchBar)
    [self.view endEditing:YES];
    // SearchBar
    [self updateSearchBarState];
}

-(void)tabSideBySideView:(TabSideBySideView *)sender captureClipWithCallback:(GetClipCallback)completionCallback
{
    _captureClipCallback = completionCallback;
    [self.tabBarView setSelectedActionAndFire:TabBarActionCapture];
}

- (void)tabSideBySideView:(TabSideBySideView *)sender vstrateClip:(Clip *)clip withClip2:(Clip *)clip2
{
    NSError *error = nil;
    SideBySideEditorViewController *vc = [[SideBySideEditorViewController alloc] initWithClip:clip clip2:clip2 delegate:self error:&error];
    if (error == nil) {
        [self presentViewController:vc animated:NO completion:nil];
    } else {
        [UIAlertViewWrapper alertError:error];
    }
}

-(void) tabVstrateView:(TabVstrateView *)sender didSwitchToContent:(MediaListViewContentType)contentType
{
    // (mostly for SearchBar)
    [self.view endEditing:YES];
    // update SearchBar
    [self updateSearchBarState];
}

-(void)tabVstrateView:(TabVstrateView *)sender media:(Media *)media action:(MediaAction)action
{
    [self tabBarMedia:media action:action];
}

- (void)tabBarMedia:(Media*)media action:(MediaAction)action
{
    [self.view endEditing:YES];
    [self updateSearchBarState];
    switch (action) {
        case MediaActionSelect:
        case MediaActionPlay:
        case MediaActionVstrate: {
            MediaViewController *vc = [[MediaViewController alloc] initWithDelegate:self media:media mediaAction:action];
            [self presentViewController:vc animated:NO completion:nil];
            break;
        }
        case MediaActionDelete: {
            NSError* error = nil;
            [MediaService.mainThreadInstance deleteObject:media error:&error];
            if (error) {
                [self hideBGActivityIndicator:error];
            } else {
                [MediaService.mainThreadInstance saveChanges:[self hideBGActivityCallback]];
            }
            break;
        }
        default:
            break;
    }
}

- (void)tabVstrateViewSyncAction:(TabVstrateView *)sender
{
    [MediaService.mainThreadInstance downloadContentWithStatus:DownloadContentStatusNew
                                              authorIdentities:@[AccountController2.sharedInstance.userIdentity]
                                                      callback:^(NSError *error, NSFetchedResultsController *result) {
                                                          if (error) {
                                                              [UIAlertViewWrapper alertError:error];
                                                              return;
                                                          }
                                                          NSError *error2 = nil;
                                                          @try {
                                                              [result performFetch:&error2];
                                                          }
                                                          @finally {
                                                              if (error2) {
#ifdef DEBUG_CORE_DATA
                                                                  NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error2 localizedDescription], [error2 localizedFailureReason]);
#endif
                                                              }
                                                          }
                                                          for (DownloadContent *dc in result.fetchedObjects) {
                                                              [dc addToDownloadQueue];
                                                          }
                                                      }];
}

#pragma mark ContentSetViewControllerDelegate

- (void)contentSetViewController:(ContentSetViewController *)sender downloadContentSet:(ContentSet *)contentSet
{
    [PurchaseManager.sharedInstance purchaseContentSet:contentSet callback:^(NSError *error) {
        if (error) NSLog(@"Cannot purchase product. Error: %@", error);
    }];
}

#pragma mark CameraManagerViewController

- (void)cameraManagerViewControllerDidFinish:(id)sender withLastClip:(Clip *)lastClip clipAction:(CameraManagerClipAction)clipAction
{
    // save & flush callback
    GetClipCallback captureClipCallback = _captureClipCallback;
    _captureClipCallback = nil;
    // process
    if (captureClipCallback != nil) {
        kItemCallbackIf(captureClipCallback, nil, lastClip);
        return;
    }
    
    if (!lastClip) return;
    
    MediaAction mediaAction;
    switch (clipAction) {
        case CameraManagerClipActionOpen:
            mediaAction = MediaActionSelect;
            break;
        case CameraManagerClipActionVstrate:
            mediaAction = MediaActionVstrate;
            break;
        default:
            return;
    }
    [self.tabBarView setSelectedActionAndFire:TabBarActionVstrate];
    [self tabVstrateView:self.tabVstrateViewItem media:lastClip action:mediaAction];
}

#pragma mark ContentQuickStartViewControllerDelegate

- (void)showContentQuickStartViewController:(BOOL)firstTimeMode
{
    ContentQuickStartViewController *vc = [[ContentQuickStartViewController alloc] initWithNibName:NSStringFromClass(ContentQuickStartViewController.class) bundle:nil];
    vc.delegate = self;
    vc.firstTimeMode = firstTimeMode;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)contentQuickStartViewController:(ContentQuickStartViewController *)sender didTabBar:(TabBarAction)action
{
    [self.tabBarView setSelectedActionAndFire:action];
}

#pragma mark MediaViewControllerDelegate

- (void)mediaViewController:(MediaViewController *)sender didSelectSession:(Media *)media
{
    MediaViewController *vc = [[MediaViewController alloc] initWithDelegate:self media:media mediaAction:MediaActionNon];
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)mediaViewController:(MediaViewController *)sender didAction:(MediaAction)action
{
    if (action == MediaActionSideBySide) {
        [self.tabBarView setSelectedActionAndFire:TabBarActionSideBySide];
        self.tabSideBySideViewItem.clip = (Clip *)((MediaViewController *)sender).media;
    }
}

#pragma mark SearchBar

- (void)arrangeSearchBarViews
{
    [self rotate:self.interfaceOrientation];
}

- (void)performSearch
{
    NSString *queryString = [NSString trimmedStringOrNil:self.searchBar.text];
    if (self.tabBarViewItem == nil) {
        [self.tabBarView setSelectedActionAndFire:TabBarActionVstrate];
        self.tabVstrateViewItem.queryString = queryString;
    } else {
        self.tabBarViewItem.queryString = queryString;
    }
}

- (void)updateSearchBarState
{
    if (self.tabBarViewItem != nil && self.navigationBarView.showSearch) {
        self.searchBar.text = self.tabBarViewItem.queryString;
        [self showOrHideSearchBar:NO];
    } else {
        [self hideSearchBar];
    }
}

#pragma mark Notifications

- (void)showNotificationsIfAny
{
    self.view.userInteractionEnabled = NO;
    [MediaService.mainThreadInstance getLastNotification:^(Notification *notification, NSError *error) {
        if (notification) {
            NotificationViewController *vc = [[NotificationViewController alloc] initWithNotification:notification];
            [self presentViewController:vc animated:NO completion:nil];
        }
        self.view.userInteractionEnabled = YES;
    }];
}

#pragma mark Notifications

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (self.view && self.tabVstrateViewItem && self.tabVstrateViewItem.superview)
        [self showNotificationsIfAny];
}

- (void)didReceiveUserIdentityChangedNotification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.view == nil)
            return;
        [self.tabBarView setSelectedActionAndFire:TabBarActionVstrate];
        [self.tabVstrateViewRef reload];
    });
}

#pragma mark Ctors/Dtors

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didReceiveUserIdentityChangedNotification) name:VAUserIdentityChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:VAUserIdentityChangedNotification object:nil];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // rotation-related
    self.containerView.autoresizingMask = UIViewAutoresizingNone;
    // navigation/tab bar
    self.navigationBarView.showBack = NO;
    self.navigationBarView.showSearch = YES;
    self.navigationBarView.showSettings = YES;
    // views
    [self.tabBarView setSelectedActionAndFire:TabBarActionVstrate];
    // hide self
    [self showBlackoutView];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Rotation
    //[self rotate:self.interfaceOrientation];
    // Super
    [super viewWillAppear:animated];
    // Events
    //[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(needsRotate:) name:VstratorConstants.NotificationNeedsRotate object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Super
    [super viewDidAppear:animated];
    // Launch following processing only once
    if (_viewDidAppearOnce)
        return;
    _viewDidAppearOnce = YES;
    // Welcome
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showContentQuickStartViewController:YES];
        [self hideBlackoutView];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Events
    //[NSNotificationCenter.defaultCenter removeObserver:self name:VstratorConstants.NotificationNeedsRotate object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    // Super
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.containerView = nil;
    _tabVstrateViewRef = nil;
    // Super
    [super viewDidUnload];
}

#pragma mark Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)rotate:(UIInterfaceOrientation)toInterfaceOrientation
{
    [super rotate:toInterfaceOrientation];

    CGSize viewSize = self.view.bounds.size; // UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? self.viewSizeForLandscape : self.viewSizeForPortrait;
    CGSize navBarSize = self.navigationBarView.frame.size;
    CGSize tabBarSize = self.tabBarView.frame.size;
    CGFloat containerHeight = viewSize.height - navBarSize.height - tabBarSize.height;
    CGFloat searchBarHeight0 = self.searchBar.superview == nil ? 0 : self.searchBar.frame.size.height;

    self.searchBar.frame = CGRectMake(0, navBarSize.height, viewSize.width, self.searchBar.frame.size.height);
    self.containerView.frame = CGRectMake(0, navBarSize.height + searchBarHeight0, viewSize.width, containerHeight - searchBarHeight0);
    CGRect rect = CGRectMake(0, 0, viewSize.width, containerHeight - searchBarHeight0);
    self.tabProViewItem.frame = rect;
    self.tabSideBySideViewItem.frame = rect;
    self.tabVstrateViewItem.frame = rect;
    self.tabContentSetItem.frame = rect;
    self.tabBarView.frame = CGRectMake(0, viewSize.height - tabBarSize.height, viewSize.width, tabBarSize.height);
}

//- (void)needsRotate:(NSNotification *)notification
//{
//    if ([notification.object isKindOfClass:[UIView class]])
//        [self setOrientation:self.interfaceOrientation forViewInt:(UIView*)notification.object];
//}

@end
