#import "SDImage.h"


@implementation SDImage

    static NSMutableDictionary* cache = nil;

    + (UIImage*) imageNamed: (NSString*) theName; {
        if (!cache) cache = [[NSMutableDictionary alloc] init];
        UIImage* result;
        if (!(result = [cache objectForKey: theName])) {
            result = [UIImage imageNamed: theName];
            if (result)
                [cache setObject: result forKey: theName];
        }
        return result;
    }

@end