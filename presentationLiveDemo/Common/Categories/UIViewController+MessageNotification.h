
#import <UIKit/UIKit.h>

@interface UIViewController (MessageNotification)

//Notifications
- (void)showSuccessWithContent:(NSString *) content;
- (void)showSuccessWithContent:(NSString *) content isAlwaysDisplay:(BOOL) isDisplay beDismised:(BOOL) dismiss;

- (void)showInfoWithContent:(NSString *) content;
- (void)showWarningWithContent:(NSString *) content;
- (void)showErrorWithContent:(NSString *) content;

@end
