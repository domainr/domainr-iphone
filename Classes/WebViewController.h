#import <UIKit/UIKit.h>
#import "Result.h"

@interface WebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	IBOutlet UIToolbar			*toolbar;
	IBOutlet UIWebView			*webView;
	IBOutlet UIBarButtonItem	*backButton;
    IBOutlet UIBarButtonItem	*forwardButton;
	IBOutlet UIActivityIndicatorView *spinner;
	IBOutlet UIBarButtonItem	*reloadButton;
	IBOutlet UIBarButtonItem	*fixedSpace;
	
	// title fields
    IBOutlet UIView				*titleAndAddressView;
    IBOutlet UILabel			*titleField;
    IBOutlet UILabel			*addressField;
	
	NSString					*loadAddress;
	NSMutableArray				*toolBarItems;
	Result						*_result;
}

- (id) initWithAddress: (NSString*) theAddress result:(Result *)result;

@property (readonly) UIWebView *webView;

- (void)reloadAction:(id)sender;
- (void) goBack: (id) sender;
- (void) action: (id) sender;

- (void)displayComposerSheet;

@end
