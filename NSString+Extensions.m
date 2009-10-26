#import "NSScanner+Extensions.h"
#import "NSString+Extensions.h"


/* Data */

@implementation NSString (Data)

    + (id) stringWithData: (NSData*) data; {
        id result = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
        if (!result) result = [[[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding] autorelease];
        return result;
    }
    
    + (NSString*) stringWithCString: (const char *) cString; {
        if (!cString)
            return nil;
        return [NSString stringWithCString: cString encoding: NSUTF8StringEncoding];
    }

    - (id) data; {
        return [self dataUsingEncoding: NSASCIIStringEncoding allowLossyConversion: YES];
    }

@end


/* Extensions */

@implementation NSString (Extensions)

    - (BOOL) hasSubstring: (id) theString; {
        if (theString)
            return ([self rangeOfString: theString options: 0].location != NSNotFound);
        return NO;
    }
    
    - (NSString*) escapedString; {
        return [[[self stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding] stringByReplacingString: @"&" withString: @"%26"] stringByReplacingString: @"+" withString: @"%2B"];
    }

    - (NSString*) unescapedString; {
        return [self stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    }
    
    - (NSRange) rangeBetween: (NSString*) a and: (NSString*) b; 
    {
        if ([self isEqualToString: @""]) return NSMakeRange(NSNotFound,0);
        
        NSRange ra = NSMakeRange(0,0);
        NSRange rb = NSMakeRange([self length]-1,0);

        if (a) {
            if ([self length] > [a length])
                ra = [self rangeOfString: a];
            else
                ra.location = NSNotFound;
        }

        if (b && ra.location != NSNotFound) {
            NSRange searchRange = NSMakeRange(ra.location + ra.length, [self length] - ra.location - ra.length);
            if (searchRange.length > 0)
                rb = [self rangeOfString: b options: 0 range: searchRange];
        }
        
        if (ra.location == NSNotFound)
            return NSMakeRange(NSNotFound,0);
        else if (rb.location == NSNotFound)
            return NSMakeRange(ra.location + ra.length, [self length] - ra.location - ra.length);
        else
            return NSMakeRange(ra.location + ra.length, rb.location - ra.location - ra.length);
    }

    - (NSString*) substringBetween: (NSString*) a and: (NSString*) b; {
        NSRange range = [self rangeBetween: a and: b];
        if (range.location != NSNotFound)
            return [self substringWithRange: range];
        else
            return nil;
    }

    - (NSString*) stringByRemovingPrefix: (NSString*) thePrefix; {
        if ([self hasPrefix: thePrefix]) {
            return [self substringFromIndex: [thePrefix length]];
        } else {
            return self;
        }
    }

    - (NSString*) stringByRemovingSuffix: (NSString*) theSuffix; {
        if ([self hasSuffix: theSuffix]) {
            return [self substringToIndex: [self length]-[theSuffix length]];
        } else {
            return self;
        }
    }

    - (NSString*) trimmedString; {
        return [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    - (NSString*) stringByReplacingString: (id) a withString: (id) b; {
        id result = [NSMutableString stringWithString: self];
        [result replaceOccurrencesOfString: a withString: b options: 0 range: NSMakeRange(0, [result length])];
        return result;
    }

@end


/* Replace */

@implementation NSMutableString (Replace)

    - (void) appendStringA: (id) theString; {
        if (!EmptyString(theString))
            [self appendString: theString];
    }

    - (unsigned int) replaceOccurrencesOfString: (NSString*) target withString: (NSString*) replacement; {
        if (target && replacement)
            return [self replaceOccurrencesOfString: target withString: replacement options: 0 range: (NSRange){0, [self length]}];
        return 0;
    }

@end


/* UIKit Drawing */

@implementation NSString (UIKitDrawing)

    - (CGSize) drawInRect: (CGRect) theRect highlightedString: (NSString*) highlightedString normalFont: (UIFont*) normalFont highlightedFont: (UIFont*) highlightedFont; {
        NSRange highlightRange = (EmptyString(highlightedString)) ? NSMakeRange(NSNotFound, 0) : [self rangeOfString: highlightedString options: NSCaseInsensitiveSearch];

		CGSize size = CGSizeMake(0,0);
		CGSize out;
		
        if (highlightRange.location == NSNotFound) {
            out = [self drawAtPoint: theRect.origin forWidth: theRect.size.width withFont: normalFont lineBreakMode: UILineBreakModeTailTruncation];
            return out;
        }
		
        /* start */
        if (highlightRange.location > 0) {
            NSString* substring = [self substringToIndex: highlightRange.location];

            size = [substring drawAtPoint: theRect.origin forWidth: theRect.size.width withFont: normalFont lineBreakMode: UILineBreakModeTailTruncation];
            
            theRect.origin.x += size.width;
            theRect.size.width -= size.width;
        }
        
		out = size;
		
        if (theRect.size.width < 10)
            return out;
        
        /* middle */
        
        if (highlightRange.location >= 0 && theRect.size.width > 0) {
            NSString* substring = [self substringWithRange: highlightRange];

            size = [substring sizeWithFont: highlightedFont forWidth: theRect.size.width lineBreakMode: UILineBreakModeTailTruncation];

            if (size.width != 0) {
                [substring drawAtPoint: theRect.origin forWidth: theRect.size.width withFont: highlightedFont lineBreakMode: UILineBreakModeTailTruncation];
                theRect.origin.x += size.width;
                theRect.size.width -= size.width;
            }
        }

		out.width += size.width;		
		
			
        if (theRect.size.width < 10)
            return out;
            
        /* end */
        
        if (highlightRange.location + highlightRange.length < [self length] && theRect.size.width > 0) {
            NSString* substring = [self substringFromIndex: highlightRange.location + highlightRange.length];
            CGSize size = [substring drawAtPoint: theRect.origin forWidth: theRect.size.width withFont: normalFont lineBreakMode: UILineBreakModeTailTruncation];

			out.width += size.width;
		}
		return out;
    }

@end