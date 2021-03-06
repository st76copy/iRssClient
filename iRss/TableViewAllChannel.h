#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "EditChannelTableViewController.h"
#import "ResetSettingToDefault.h"
#import "Client.h"

@interface TableViewAllChannel : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    @private
    UIBarButtonItem *barButtonAddChannel;
    UIBarButtonItem *barButtonDeleteAllChannel;
    
    NSDictionary *dictionaryRssChannel;
}

#pragma mark - Action
- (IBAction)buttonToolbarOpenSetting:(id)sender;

#pragma mark - Outlet
@property (weak, nonatomic) IBOutlet UITableView *tableView;

#pragma mark -
- (NSArray *)arrayAllRssChannel;

@end
