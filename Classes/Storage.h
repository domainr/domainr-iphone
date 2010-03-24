#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "Result.h"

@interface Storage : NSObject {}

+ (Storage*) instance;
+ (void) clearSearchHistory;

- (void) storeResult:(Result *) result;
- (void) storeSearch:(NSString *) searchString;
- (void) removeItem:(NSString *) theString;

- (NSMutableArray*) recentHistory;
- (void) _insertString:(NSString *) theString intoArray: (NSMutableArray*) theArray;

@end
