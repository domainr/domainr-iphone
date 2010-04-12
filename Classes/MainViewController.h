#import <UIKit/UIKit.h>
#import "CJSONDeserializer.h"

@class Reachability;

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UINavigationBarDelegate> {	
	IBOutlet UITableView                *myTableView;
	IBOutlet UITableView				*historyTableView;
	IBOutlet UISearchBar				*mySearchBar;
	IBOutlet UIActivityIndicatorView	*activityIndicator;
	IBOutlet UIView						*whiteBgView;
	IBOutlet UIButton					*infoButton;
	
	NSData					*jsonData;
	NSURL					*jsonURL;
	NSMutableData			*receivedData;
	NSString				*jsonString;
	NSURLConnection			*theConnection;
	
	NSString				*searchQuery;
	NSMutableArray			*results;
	NSMutableArray			*historyArray;
	BOOL					loading;
	
	NSDate					*previousTimeStamp;
	
	Reachability			*internetReach;
	
	BOOL					keyboardHidden;
	
	BOOL					firstLaunch;
	UIAlertView				*alert;
}

@property (nonatomic, retain) UITableView       *myTableView;
@property (nonatomic, retain) UITableView		*historyTableView;
@property (nonatomic, retain) UISearchBar		*mySearchBar;

- (void) toggleActivityIndicator:(BOOL)show;
- (void) setKeyboardState:(BOOL)show;
- (void)_showKeyboardWorkAround;

/* i know, these are hacky, got a better idea? ok fine, then fork it and fix it. jeez */ 
- (void)_showClearButton;
- (void)_hideClearButton;

- (void) search;
- (BOOL) networkAvailable;

- (void) showHistory;

- (IBAction)showAbout;

@end
