#import "YCPNative.h"
void YCPBootstrapNativeScene(UIWindowScene *scene, UISceneSession *session, UISceneConnectionOptions *options) {}
@interface TemplateRecorder : NSObject
@property(nonatomic, strong) CPListTemplate *root;
@end
@implementation TemplateRecorder
- (void)setRootTemplate:(CPTemplate *)template animated:(BOOL)animated completion:(void (^)(BOOL, NSError *))completion {
    self.root = (CPListTemplate *)template;
    if (completion) completion(YES, nil);
}
@end
@interface HarnessDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic, strong) UIWindow *window;
@end
@implementation HarnessDelegate
- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)options {
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 390, 844)];
    self.window.rootViewController = [UIViewController new];
    [self.window makeKeyAndVisible];
    dispatch_async(dispatch_get_main_queue(), ^{
        YCPSurface *surface = YCPSurface.shared;
        UIViewController *phoneRoot = self.window.rootViewController;
        TemplateRecorder *recorder = [TemplateRecorder new];
        [surface connectTemplate:(CPInterfaceController *)recorder window:nil];
        NSCAssert(!surface.activeWindow, @"Template must not manufacture a window");
        CPListItem *status = (CPListItem *)recorder.root.sections.firstObject.items.firstObject;
        NSCAssert([status.text isEqualToString:@"CarPlay interface unavailable"], @"Missing window needs accurate status");
        NSCAssert(!status.enabled, @"Status must not offer a nonfunctional action");
        NSCAssert(self.window.rootViewController == phoneRoot, @"Template-only connection must leave phone intact");
        UIWindow *first = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 800, 480)];
        [surface connectWindow:first];
        NSCAssert(recorder.root.sections.count == 0, @"Late window clears status");
        UIWindow *replacement = [[UIWindow alloc] initWithFrame:first.frame];
        [surface connectWindow:replacement];
        [surface disconnectWindow:first];
        NSCAssert(surface.activeWindow == replacement && recorder.root.sections.count == 0, @"Stale disconnect preserves current window state");
        [surface disconnectWindow:replacement];
        NSCAssert(recorder.root.sections.count == 1, @"Window loss restores status");
        [surface disconnectTemplate];
        [surface connectWindow:first];
        [surface connectTemplate:(CPInterfaceController *)recorder window:nil];
        NSCAssert(recorder.root.sections.count == 0, @"Window-first arrival suppresses status");
        [surface disconnectTemplate];
        NSCAssert(surface.activeWindow == first, @"Template loss preserves independent window");
        [surface disconnectWindow:first];
        NSCAssert(self.window.rootViewController == phoneRoot, @"Fallback tests preserve phone root");
        NSLog(@"NATIVE_FALLBACK_TESTS_PASSED");
        exit(0);
    });
    return YES;
}
@end
int main(int argc, char **argv) {
    @autoreleasepool { return UIApplicationMain(argc, argv, nil, NSStringFromClass(HarnessDelegate.class)); }
}
