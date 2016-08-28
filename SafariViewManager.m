#import "SafariViewManager.h"
#import "RCTUtils.h"
#import "RCTLog.h"
#import "RCTConvert.h"

@implementation SafariViewManager

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(show:(NSDictionary *)args callback:(RCTResponseSenderBlock)callback)
{
    UIColor *tintColorString = args[@"tintColor"];

    // Error if no url is passed
    if (!args[@"url"]) {
        RCTLogError(@"[SafariView] You must specify a url.");
        return;
    }

    // Initialize the Safari View
    self.safariView = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:args[@"url"]] entersReaderIfAvailable:args[@"readerMode"]];
    self.safariView.delegate = self;

    // Set tintColor if available
    if (tintColorString) {
        UIColor *tintColor = [RCTConvert UIColor:tintColorString];
        [self.safariView.view setTintColor:tintColor];
    }

    // Display the Safari View
    UIViewController *ctrl = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [ctrl presentViewController:self.safariView animated:YES completion:nil];

    if (self.hasListeners) {
        [self sendEventWithName:@"onShow" body:nil];
    }
}

RCT_EXPORT_METHOD(isAvailable:(RCTResponseSenderBlock)callback)
{
    if ([SFSafariViewController class]) {
        // SafariView is available
        return callback(@[[NSNull null], @true]);
    } else {
        return callback(@[RCTMakeError(@"[SafariView] SafariView is unavailable.", nil, nil)]);
    }
}

RCT_EXPORT_METHOD(dismiss)
{
    [self dismissWithData:nil];
}

RCT_EXPORT_METHOD(dismissWithData:(id) data)
{
    NSLog(@"[SafariView] SafariView dismissed programmatically.");

    if (self.hasListeners) {
        [self sendEventWithName:@"onDismiss" body:@{@"dismissedByUser": @NO, @"data": data ?: [NSNull null] }];
    }

    [self.safariView dismissViewControllerAnimated:true completion:nil];
}

-(void)startObserving {
    self.hasListeners = YES;
}

-(void)stopObserving {
    self.hasListeners = NO;
}

-(NSArray<NSString *> *)supportedEvents {
    return @[@"onShow",@"onDismiss"];
}

-(void)safariViewControllerDidFinish:(nonnull SFSafariViewController *)controller
{
    NSLog(@"[SafariView] SafariView dismissed by user.");

    if (self.hasListeners) {
        [self sendEventWithName:@"onDismiss" body:@{@"dismissedByUser": @YES}];
    }
}

@end
