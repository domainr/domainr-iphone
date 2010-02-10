#import "NSMutableArray+Extensions.h"

@implementation NSMutableArray (Reverse)

	- (void)reverse; {
		NSUInteger i = 0;
		NSUInteger j = [self count] - 1;
		while (i < j) {
			[self exchangeObjectAtIndex:i
					  withObjectAtIndex:j];
			
			i++;
			j--;
		}
	}

@end