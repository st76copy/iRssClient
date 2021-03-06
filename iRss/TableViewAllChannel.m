#import "TableViewAllChannel.h"

@interface TableViewAllChannel () {
    
}

@end


@implementation TableViewAllChannel

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [self editButtonItem];
    [[self navigationItem] setTitle:NSLocalizedString(@"ALL_RSS", nil)];
    
    UIBarButtonItem *newBackButton= [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    barButtonAddChannel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(buttonBarAddNewRssChannel:)];
    self.navigationItem.rightBarButtonItem = barButtonAddChannel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

#pragma mark - SQL Query
- (NSArray *)arrayAllRssChannel {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault boolForKey:@"SWITCH_SORT_CHANNEL_BOOL"] == NO) {
        return [Client selectAllChannelDesc];
    }
    else {
        return [Client selectAllChannelByTitle];
    }
}

#pragma mark - Button Toolbar
- (IBAction)buttonToolbarOpenSetting:(id)sender {
}

#pragma mark - Button Bar
- (void)buttonBarAddNewRssChannel:(id)sender {
    [self performSegueWithIdentifier:@"OpenAddRssChannel" sender:self];
}

- (void)buttonBarDeleteAllChannel:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault boolForKey:@"SWITCH_WARNING_BOOL"] == NO) {
        [Client deleteAllRssChanel];
        [[self tableView] reloadData];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WARNING", nil)
                                                            message:NSLocalizedString(@"DELETE_ALL_CHANEL", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"DELETE", nil)
                                                  otherButtonTitles:NSLocalizedString(@"CANCEL", nil), nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:{
            [Client deleteAllRssChanel];
            [[self tableView] reloadData];
            break;
        }
        default: {
            break;
        }
    }
}

#pragma mark - UIViewControllerEditing
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        [[self tableView] setEditing:YES animated:YES];
        barButtonDeleteAllChannel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(buttonBarDeleteAllChannel:)];
        self.navigationItem.rightBarButtonItem = barButtonDeleteAllChannel;
    }
    else {
        [[self tableView] setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = barButtonAddChannel;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [[self arrayAllRssChannel] count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *channelCell = [tableView dequeueReusableCellWithIdentifier:@"ChannelCell"];
    NSDictionary *dictionary = [[self arrayAllRssChannel] objectAtIndex:[indexPath row]];
    if (channelCell) {
        if ([indexPath section] == 0) {
            [[channelCell textLabel] setText:[dictionary objectForKey:@"title"]];
            return channelCell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([indexPath section] == 0) {
            NSDictionary *dictionary = [[self arrayAllRssChannel] objectAtIndex:[indexPath row]];
            [Client deleteRssChannel:[dictionary objectForKey:@"id_rss_chanel"]];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
         //Удаляет секциями.
         //[tableView deleteSections:[NSIndexSet indexSetWithIndex:[indexPath section]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setEditing:YES];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setEditing:NO];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellAccessoryDisclosureIndicator) {
        if ([indexPath section] == 0) {
            dictionaryRssChannel = [[self arrayAllRssChannel] objectAtIndex:[indexPath row]];
            [self performSegueWithIdentifier:@"OpenEditRssChannel" sender:self];
        }
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"OpenRssChannel"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        if (indexPath) {
            TableViewController *tableViewController = [segue destinationViewController];
            NSDictionary *dictionary = [[self arrayAllRssChannel] objectAtIndex:[indexPath row]];
            NSString *stringUrlLink = [dictionary objectForKey:@"link"];
            [tableViewController setLinkToTheRssFeeds:stringUrlLink];
        }
    }
    else if ([[segue identifier] isEqualToString:@"OpenEditRssChannel"]) {
        EditChannelTableViewController *editChannelTableViewController = [segue destinationViewController];
        [editChannelTableViewController setDictionaryRssChannel:dictionaryRssChannel];
    }
    else if ([[segue identifier] isEqualToString:@"OpenAddRssChannel"]) {
    }
    else if ([[segue identifier] isEqualToString:@"OpenFavorites"]) {
    }
    else if ([[segue identifier] isEqualToString:@"OpenSetting"]) {
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
