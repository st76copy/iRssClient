#import "OfflineTableViewController.h"

@interface OfflineTableViewController () {
    
}

@end


@implementation OfflineTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [self editButtonItem];
    [[self navigationItem] setTitle:NSLocalizedString(@"FAVORITES", nil)];
    
    UIBarButtonItem *newBackButton= [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    buttonDeleteAll = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                    target:self
                                                                    action:@selector(buttonDeleteAllRecords:)];
    barButtonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(barButtonDone:)];
    self.navigationItem.rightBarButtonItem = barButtonDone;
}

#pragma mark - Action
- (void)barButtonDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)buttonDeleteAllRecords:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault boolForKey:@"SWITCH_WARNING_BOOL"] == NO) {
        [Client deleteAllFavorites];
        [[self tableView] reloadData];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WARNING", nil)
                                                            message:NSLocalizedString(@"DELETE_AFF_FAVORITES", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"DELETE", nil)
                                                  otherButtonTitles:NSLocalizedString(@"CANCEL", nil), nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            [Client deleteAllFavorites];
            [[self tableView] reloadData];
            break;
        }
        default: {
            break;
        }
    }
}

#pragma mark - Editing Bar Button
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:YES];
    if (editing) {
        self.navigationItem.rightBarButtonItem = buttonDeleteAll;
    }
    else {
        self.navigationItem.rightBarButtonItem = barButtonDone;
    }
}

#pragma mark - SQL Query
- (NSArray *)arrayAllFavoritesNotes {
    return [Client selectAllFavoritesNotes];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self arrayAllFavoritesNotes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *dictionary = [[self arrayAllFavoritesNotes] objectAtIndex:[indexPath row]];
    
    if (cell) {
        if ([indexPath section] == 0) {
            [[cell textLabel] setText:[dictionary objectForKey:@"title"]];
            [[cell detailTextLabel] setText:[dictionary objectForKey:@"date_added"]];
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([indexPath section] == 0) {
            NSDictionary *dictionary = [[self arrayAllFavoritesNotes] objectAtIndex:[indexPath row]];
            [Client deleteFavoritesNotes:[dictionary objectForKey:@"id"]];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"OpenNewsOfFavorites"]) {
        NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
        if (indexPath) {
            NSDictionary *dictionary = [[self arrayAllFavoritesNotes] objectAtIndex:[indexPath row]];
            DetailViewController *detailViewController = [segue destinationViewController];
            [detailViewController setStringOfflineKey:@"Offline"];
            [detailViewController setDetailItemOffline:dictionary];
        }
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
