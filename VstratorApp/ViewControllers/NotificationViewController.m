//
//  NotificationViewController.m
//  VstratorApp
//
//  Created by Admin on 19/10/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MediaService.h"
#import "Notification.h"
#import "NotificationButton.h"
#import "NotificationTypes.h"
#import "NotificationService.h"
#import "NotificationViewController.h"
#import "NSString+Extensions.h"
#import "ServiceFactory.h"
#import "UIAlertViewWrapper.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"
#import "WebViewController.h"

#define kVANotificationMaxButtonsCount  3

@interface NotificationViewController () <WebViewControllerProtocol>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UILabel *textBigLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) Notification *notification;
@property (nonatomic, strong) NSMutableDictionary *uiButtons;

@end

@implementation NotificationViewController

#pragma mark Actions

- (IBAction)buttonAction:(UIButton *)sender
{
    // get button identity
    NSString *buttonIdentity = [self identityByUIButton:sender];
    if ([NSString isNilOrWhitespace:buttonIdentity]) {
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    // get button
    NotificationButton *button = [self nButtonByIdentity:buttonIdentity];
    if (button == nil) {
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    // send button click to API
    [self showBGActivityIndicator:VstratorStrings.ProcessingNotificationButtonActivityTitle];
    [[[ServiceFactory sharedInstance] createNotificationService] pushTheButtonWithIdentity:buttonIdentity callback:^(NSError *error1) {
        if (error1) {
            [self dismissViewControllerAnimated:NO completion:nil];
            return;
        }
        // set notification as pushed
        [MediaService.mainThreadInstance pushNotificationButton:button callback:[self hideBGActivityCallback:^(NSError *error2) {
            if (error2 != nil || [NSString isNilOrEmpty:button.clickURL]) {
                [self dismissViewControllerAnimated:NO completion:nil];
                return;
            }
            WebViewController *vc = [[WebViewController alloc] initWithNibName:NSStringFromClass(WebViewController.class) bundle:nil];
            vc.delegate = self;
            vc.url = [NSURL URLWithString:button.clickURL];
            [self presentViewController:vc animated:NO completion:nil];
        }]];
    }];
}

#pragma mark WebViewControllerProtocol

- (void)webViewControllerDidClose:(WebViewController *)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark Business Logic

- (void)addButtons
{
    NSArray *buttons = [self.notification.buttons allObjects];
    // add action buttons
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ((NotificationButton *)evaluatedObject).type.intValue != NotificationButtonTypeCancel;
    }];
    NSArray *actionButtons = [buttons filteredArrayUsingPredicate:predicate];
    int buttonsCount = (actionButtons.count > kVANotificationMaxButtonsCount) ? kVANotificationMaxButtonsCount : actionButtons.count;
    int buttonsShift = kVANotificationMaxButtonsCount - buttonsCount;
    for (int i = 0; i < buttonsCount; i++) {
        [self addButton:actionButtons[i] atPosition:i + buttonsShift];
    }
    // add close button
    predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ((NotificationButton *)evaluatedObject).type.intValue == NotificationButtonTypeCancel;
    }];
    NSArray *closeButtons = [buttons filteredArrayUsingPredicate:predicate];
    if (closeButtons.count > 0) {
        NotificationButton *button = (NotificationButton *)closeButtons[0];
        [self.uiButtons setValue:self.closeButton forKey:button.identity];
    }
    self.closeButton.hidden = (closeButtons.count <= 0);
}

- (void)addButton:(NotificationButton *)nButton atPosition:(int)position
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(89, 326 + 32 * position, 143, 26);
    [button setTitle:nButton.text forState:UIControlStateNormal];
    NSString *imageName = (nButton.type.intValue == 0) ? @"but-notifications-download-free-normal.png" : @"but-notifications-see-all-normal.png";
    NSString *imageHoverName = (nButton.type.intValue == 0) ? @"but-notifications-download-free-hover.png" : @"but-notifications-see-all-hover.png";
    [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:imageHoverName] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [self.uiButtons setValue:button forKey:nButton.identity];
}

- (NSString *)identityByUIButton:(UIButton *)button
{
    NSEnumerator *enumerator = [self.uiButtons keyEnumerator];
    NSString *key = @"";
    while ((key = [enumerator nextObject])){
        UIButton *current = (self.uiButtons)[key];
        if (current == button) return key;
    }
    return key;
}

// TODO: move to extension
- (NotificationButton *)nButtonByIdentity:(NSString *)identity
{
    for (NotificationButton *button in self.notification.buttons) {
        if (button.identity == identity)
            return button;
    }
    return nil;
}

#pragma mark View LifeCycle

- (id)initWithNotification:(Notification *)notification
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        self.notification = notification;
        self.uiButtons = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    // Super
    [super viewDidLoad];
    // Navigation
    self.navigationBarView.hidden = YES;
    // Views
    NSAssert(self.notification != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    BOOL hasImage = self.notification.contentType.intValue == NotificationContentTypeImageOnly && self.notification.image != nil;
    self.titleLabel.text = self.notification.title;
    self.imageView.hidden = !hasImage;
    if (hasImage)
        self.imageView.image = [UIImage imageWithData:self.notification.image];
    self.textLabel.hidden = !hasImage;
    self.textLabel.text = self.notification.body;
    self.textBigLabel.hidden = hasImage;
    self.textBigLabel.text = [self.notification.body stringByAppendingString:@"\n\n\n\n\n\n\n\n\n\n\n\n"];
    // Buttons
    [self addButtons];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setCloseButton:nil];
    [self setTextLabel:nil];
    [self setTextBigLabel:nil];
    [self setImageView:nil];
    [super viewDidUnload];
}

@end
