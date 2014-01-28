//
//  SFTodoTableViewController.m
//  TodoListApp
//
//  Created by Upkar Lidder on 2014-01-24.
//  Copyright (c) 2014 8indaas. All rights reserved.
//

#import "SFTodoTableViewController.h"
#import "SFTodoCell.h"
#import "SFTodoModel.h"
#import <Parse/Parse.h>
#import "Toast+UIView.h"

@interface SFTodoTableViewController ()
@property (nonatomic, strong) NSMutableArray *items;

#define kLabelFrameMaxSize CGSizeMake(265.0, 200.0)
@end

@implementation SFTodoTableViewController{
    BOOL addButtonPressed;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *uiNib = [UINib nibWithNibName:@"SFTodoCell" bundle:nil];
    [self.tableView registerNib:uiNib forCellReuseIdentifier:@"SFTodoCell"];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    //load from parse as it might be more up to date
    [self loadItemsFromParse];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)loadItemsFromParse{
    PFQuery *query = [SFTodoModel query];
    [query orderByAscending:@"position"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error){
            [self.navigationController.view makeToast:[error localizedDescription] duration:2.0 position:@"bottom"];
            //parse is unreachable, load local items
            [self loadItemsLocal];
        }
        else{
            self.items = [objects mutableCopy];
            [self.tableView reloadData];
            [self.navigationController.view makeToast:@"Loaded from parse" duration:2.0 position:@"bottom"];
        }
    }];
    [self.tableView reloadData];
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [self becomeFirstResponder];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddButtonPressed:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SFTodoCell";
    SFTodoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.todoCellTextView.delegate = self;
    cell.todoCellTextView.tag = indexPath.row;
    SFTodoModel *currentItem = self.items[indexPath.row];
    cell.todoCellTextView.text = currentItem.itemText;
    cell.todoCellTextView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SFTodoModel *currentModel = self.items[indexPath.row];
    NSString *text = currentModel.itemText;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17.0], NSFontAttributeName, nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    CGSize constraint = CGSizeMake(320, CGFLOAT_MAX);
    CGSize size = [attributedString boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
    return MAX(size.height + 10, 44);
}

- (CGFloat) heightOfContent: (NSString *)content
{
    CGFloat width = 320;
    if(content){
        CGRect rect = [content boundingRectWithSize:CGSizeMake(width, NSIntegerMax) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil];
        return rect.size.height + 10;
    }
    else{
        return self.tableView.rowHeight;
    }
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    NSArray *visibleCells = [self.tableView visibleCells];
    
    for(SFTodoCell *cell in visibleCells){
        [cell.todoCellTextView setEditable:!editing];
    }

    NSLog(@"");
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //disable textview editing
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        SFTodoModel *item = [self.items objectAtIndex:indexPath.row];
        [item deleteInBackground];
        
        [self.items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updatePositions];
        [self saveItemsLocal];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.items exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    [self updatePositions];
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


#pragma TextViewDelegate methods
-(void)textViewDidEndEditing:(UITextView *)textView{
    [self updateItem:textView.tag withText:textView.text];
    [textView resignFirstResponder];
    
    // remove the Done button
    self.navigationItem.rightBarButtonItem = nil;
    
    //add back the + button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddButtonPressed:)];
}

- (void)updateItem:(NSInteger)index withText:(NSString *)text
{
	SFTodoModel *item = self.items[index];
    NSString *itemText = item.itemText;
    
	if (![itemText isEqualToString:text]) {
		itemText = text;
	}
}

- (void)textViewDidChange:(UITextView *)textView{
//    NSLog(@"textViewDidChange");
    SFTodoModel *todo = self.items[textView.tag];
    todo.itemText = textView.text;
    [self saveItemsLocal];
    [todo saveInBackground];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // Trigger size updates
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    // Dismiss keyboard on enter
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneButton:)];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(SFTodoCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    // add button is pressed and first row is being displayed, put the user inside the textview in edit mode.
    if(addButtonPressed == TRUE && indexPath.row == 0){
        [cell.todoCellTextView becomeFirstResponder];
        addButtonPressed = FALSE;
    }
}


- (void)setFrameToTextSize:(CGRect)txtFrame textView:(UITextView *)textView
{
    const float MAX_HEIGHT_MESSAGE_TEXTBOX = 80;
    const float MIN_HEIGHT_MESSAGE_TEXTBOX = 30;
    
    if(txtFrame.size.height > MAX_HEIGHT_MESSAGE_TEXTBOX)
    {
        //OK, the new frame is to large. Let's use scroll
        txtFrame.size.height = MAX_HEIGHT_MESSAGE_TEXTBOX;
        textView.scrollEnabled = YES;
        [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];
    }
    else
    {
        if (textView.frame.size.height < MIN_HEIGHT_MESSAGE_TEXTBOX) {
            //OK, the new frame is to small. Let's set minimum size
            txtFrame.size.height = MIN_HEIGHT_MESSAGE_TEXTBOX;
        }
        //no need for scroll
        textView.scrollEnabled = NO;
    }
    //set the frame
    textView.frame = txtFrame;
}


#pragma ibactions for the main controller
- (IBAction)onDoneButton:(id)sender {
    //if the cell being edited is empty, add the text back and show a toast 'cannot add empty todo'
    [self.view endEditing:YES];
}


- (IBAction)onAddButtonPressed:(id)sender {
    SFTodoModel *todo = [[SFTodoModel alloc]init];
    todo.itemText = @"";
    todo.position = 0;
    todo.isDone = FALSE;
    
    //save the item to parse
    [todo saveInBackground];
    
    addButtonPressed = YES;
	[self.items insertObject:todo atIndex:0];
    
    [self updatePositions];
    
    //reload table to show the addition in the UI
	[self.tableView reloadData];
    
    //table is updated, make it first responder so that it can receive keyboard events
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    SFTodoCell *cell = (SFTodoCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.todoCellTextView becomeFirstResponder];
    
    [self saveItemsLocal];
}

-(void)saveItemsLocal{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *serializable = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < self.items.count; i++) {
        SFTodoModel *item = self.items[i] ;
        NSMutableDictionary *object = [[NSMutableDictionary alloc] init];
        [object setValue:item.itemText forKey:@"text"];
        [object setValue:[NSString stringWithFormat:@"%ld",(long)item.position] forKey:@"position"];
        [object setValue:[NSNumber numberWithBool:item.isDone] forKey:@"done"];
        [serializable addObject:[NSDictionary dictionaryWithDictionary:object]];
    }
    [defaults setObject:[NSArray arrayWithArray:serializable] forKey:@"todos"];
    [defaults synchronize];
}

-(void)loadItemsLocal{
    // First load items from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedTodos = [defaults objectForKey:@"todos"];
    self.items = [[NSMutableArray alloc] init];
    if (savedTodos == nil) {
        self.items = [[NSMutableArray alloc] init];
    } else {
        for (NSUInteger i = 0; i < savedTodos.count; i++) {
            SFTodoModel *item = [[SFTodoModel alloc]init];
            item.itemText = [savedTodos[i] objectForKey:@"text"];
            [self.items addObject:item];
        }
    }
    [self.tableView reloadData];
}

#pragma helper method to update position for all items. This can happen on insert, delete and when the order of items change

-(void)updatePositions{
    //update on parse and then save what is in view locally
    for (NSInteger i = 0; i < self.items.count; i++) {
        SFTodoModel *item = self.items[i];
        item.position = i;
        [item saveInBackground];
    }
    [self saveItemsLocal];
}


@end
