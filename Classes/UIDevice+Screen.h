@interface UIDevice (Screen)
typedef enum
{
    iPhone          = 1 << 1,
    iPhoneRetina    = 1 << 2,
    iPhone5         = 1 << 3,
    iPad            = 1 << 4,
    iPadRetina      = 1 << 5
    
} DeviceType;

+ (DeviceType)deviceType;
@end