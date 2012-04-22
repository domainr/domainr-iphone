#import <Foundation/Foundation.h>

@class ResultCell;

@interface Result : NSObject {
	NSString *domainName;
	NSString *availability;
	NSString *path;
	NSString *registerURL;
	NSMutableArray *registrars;
	int imageType;
	
	ResultCell *resultCell;
}

@property (retain) NSString	*domainName;
@property (nonatomic, retain) NSString	*availability;
@property (retain) NSString *path;
@property (retain) NSString *registerURL;
@property (nonatomic, retain) NSMutableArray *registrars;
@property int imageType;

@property (assign) ResultCell *resultCell;

- (BOOL)isResolvable;
- (BOOL)isRegistrable;
@end
