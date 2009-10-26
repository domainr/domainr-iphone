#import <UIKit/UIKit.h>
#import "NSUserDefaults+Extensions.h"

#define Autorelease(A) { [A autorelease]; A = nil; }
#define Release(A) { [A release]; A = nil; }
#define instanceof(A,B) [A isKindOfClass: [B class]]

#define EmptyString(A) (!A || [A isEqualToString: @""])
#define SDLocalizedString(s) NSLocalizedString(s,s)
#define SDLocalizedStringWithFormat(s,...) [NSString stringWithFormat:NSLocalizedString(s,s),##__VA_ARGS__]

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kAvailable	 0
#define kMaybe		 1
#define kTaken	 	 2
#define kTLD		 3
#define kSubdomain	 4
#define kUnavailable 5

#define KEYBOARD_HEIGHT_PORTRAIT 216
#define KEYBOARD_HEIGHT_LANDSCAPE 162

@interface NSObject (Events)

- (void) postNotificationAboutSelf: (id) name;
- (void) postNotificationAboutSelfLater: (id) name;

- (void) listenForNotification: (id) name selector: (SEL) sel;
- (void) listenForNotification: (id) name selector: (SEL) sel object: (id) obj;

- (void) stopListening;

- (id) repeatingTimerWithTimeInterval: (NSTimeInterval) interval selector: (SEL) sel;

- (void) kill;

@end


@interface NSArray (Protection)

- (id) objectAtIndexA: (int) theIndex;

@end