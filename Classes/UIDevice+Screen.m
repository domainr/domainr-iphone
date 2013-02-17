#import "UIDevice+Screen.h"
@implementation UIDevice (Screen)

+ (DeviceType)deviceType
{
    DeviceType thisDevice = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        thisDevice |= iPhone;
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
        {
            thisDevice |= iPhoneRetina;
            if ([[UIScreen mainScreen] bounds].size.height == 568)
                thisDevice |= iPhone5;
        }
    }
    else
    {
        thisDevice |= iPad;
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)])
            thisDevice |= iPadRetina;
    }
    return thisDevice;
}

@end