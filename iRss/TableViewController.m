#import "TableViewController.h"

@interface TableViewController () {
    
}

@end


@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    UIBarButtonItem *newBackButton= [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    arrayDataRss = [[NSArray alloc] init];
    [self buttonBarRefresh:nil];
}

#pragma mark - Action
- (IBAction)buttonBarRefresh:(id)sender {
    if ([Internet internetConnection] == YES) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self retrievingData];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                            message:NSLocalizedString(@"ERROR_INTERNET_CONNECTION", nil)
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

#pragma mark -
- (void)retrievingData {
    NSURL *url = [NSURL URLWithString:[self linkToTheRssFeeds]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    [RSSParser parseRSSFeedForRequest:request success:^(NSArray *feedItems) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        arrayDataRss = feedItems;
        NSString *stringTitle = [NSString stringWithFormat:NSLocalizedString(@"TITLE_ALL_NEWS", nil), (unsigned long)[arrayDataRss count]];
        [[self navigationItem] setTitle:stringTitle];
        [[self tableView] reloadData];
    }failure:^(NSError *error) {
        NSLog(@"Error Get Data! %@", error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                            message:NSLocalizedString(@"CHANEL_NOT_ERRPR", nil)
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrayDataRss count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    RSSItem *item = [arrayDataRss objectAtIndex:[indexPath row]];
    
    if (cell) {
        [[cell textLabel] setText:[item title]];
        [[cell detailTextLabel] setText:[item pubDates]];
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"OpenDetailNews"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        if (indexPath) {
            RSSItem *item = [arrayDataRss objectAtIndex:[indexPath row]];
            [[segue destinationViewController] setDetailItem:item];
        }
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
