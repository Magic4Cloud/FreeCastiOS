//
//  AutoCompleteTextField.m
//  AutoCompleteTextField
//
//  Created by Chandan on 5/6/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "CAAutoFillTextField.h"
#import "CAAutoCompleteObject.h"

@interface CAAutoFillTextField() {
    UITableView *autoCompleteTableView;
    UILabel *notMatchLabel;
    CGFloat tableHeight;
}

@property (nonatomic, strong) NSMutableArray <CAAutoCompleteObject *> *autoCompleteArray;

@end

@implementation CAAutoFillTextField

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        CGRect frame = self.frame;
        CGFloat totalHeight=667;//各部分比例
        CGFloat totalWeight=375;//各部分比例
        CGFloat viewH=frame.size.height*totalHeight/40;
        tableHeight = viewH*28/totalHeight;
        
        _txtField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
        _txtField.borderStyle = 3; // rounded, recessed rectangle
        _txtField.autocorrectionType = UITextAutocorrectionTypeNo;
        _txtField.textAlignment = NSTextAlignmentLeft;
        _txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _txtField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _txtField.returnKeyType = UIReturnKeyDone;
        _txtField.font = [UIFont systemFontOfSize:17.0];
        _txtField.textColor = [UIColor blackColor];
        _txtField.placeholder = NSLocalizedString(@"address_text", nil);
        _txtField.clipsToBounds = NO;
        [_txtField setDelegate:self];
        [self addSubview:_txtField];
        
        //Autocomplete Table
        autoCompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(3, _txtField.frame.origin.y+_txtField.frame.size.height, frame.size.width - 5, tableHeight*4+30) style:UITableViewStylePlain];
        autoCompleteTableView.delegate = self;
        autoCompleteTableView.dataSource = self;
        autoCompleteTableView.scrollEnabled = YES;
        autoCompleteTableView.hidden = NO;
        autoCompleteTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        autoCompleteTableView.rowHeight = tableHeight;
        [self addSubview:autoCompleteTableView];
        
        _dataSourceArray = [[NSMutableArray alloc] init];
        _autoCompleteArray = [[NSMutableArray alloc] init];
        
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat totalHeight=64+71+149+149+149+80+5;//各部分比例
        CGFloat totalWeight=375;//各部分比例
        CGFloat viewW= frame.size.width*totalWeight/246;
        CGFloat viewH=frame.size.height*totalHeight/40;
        tableHeight = viewH*28/totalHeight;
        
        _txtField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _txtField.borderStyle = 3; // rounded, recessed rectangle
        _txtField.autocorrectionType = UITextAutocorrectionTypeNo;
        _txtField.textAlignment = NSTextAlignmentLeft;
        _txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _txtField.returnKeyType = UIReturnKeyDone;
        _txtField.font = [UIFont systemFontOfSize:16.0];
        _txtField.textColor = [UIColor blackColor];
        _txtField.clipsToBounds = NO;
        _txtField.delegate = self;
        _txtField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtField.placeholder = NSLocalizedString(@"address_text", nil);
        [self addSubview:_txtField];
        
        UIView *line=[[UIView alloc]init];
        line.frame=CGRectMake(viewW*20/totalWeight,_txtField.frame.origin.y+_txtField.frame.size.height+viewH*18/totalHeight,viewW*200/totalWeight,1);
        line.backgroundColor=[UIColor colorWithRed:236/255.0 green:236/255.0 blue:237/255.0 alpha:1.0];
        [self addSubview:line];
        
        //Autocomplete Table
        autoCompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, line.frame.origin.y+line.frame.size.height+viewH*18/totalHeight, frame.size.width, 4*tableHeight+2) style:UITableViewStylePlain];
        autoCompleteTableView.delegate = self;
        autoCompleteTableView.dataSource = self;
        autoCompleteTableView.scrollEnabled = YES;
        autoCompleteTableView.hidden = NO;
        autoCompleteTableView.rowHeight = tableHeight;
        autoCompleteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:autoCompleteTableView];
        
        _dataSourceArray = [[NSMutableArray alloc] init];
        _autoCompleteArray = [[NSMutableArray alloc] init];
        
        notMatchLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, line.frame.origin.y+line.frame.size.height, frame.size.width, 4*tableHeight+30)];
        notMatchLabel.text = NSLocalizedString(@"url_no_match", nil);
        notMatchLabel.font = [UIFont systemFontOfSize: viewH*30/totalHeight*0.8];
        notMatchLabel.textColor = [UIColor colorWithRed:180/255.0 green:181/255.0 blue:186/255.0 alpha:1.0];
        notMatchLabel.lineBreakMode = UILineBreakModeWordWrap;
        notMatchLabel.textAlignment=UITextAlignmentCenter;
        notMatchLabel.numberOfLines = 0;
        [self addSubview:notMatchLabel];
    }
    return self;
}

// Take string from Search Textfield and compare it with autocomplete array
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
	
	[_autoCompleteArray removeAllObjects];
    
	for(CAAutoCompleteObject *object in _dataSourceArray) {
		NSRange substringRangeLowerCase = [[object.objName lowercaseString] rangeOfString:[substring lowercaseString]];
		
        if (substringRangeLowerCase.length != 0) {
			[_autoCompleteArray addObject:object];
		}
	}
	autoCompleteTableView.hidden = NO;
    notMatchLabel.hidden=YES;
	[autoCompleteTableView reloadData];
}

#pragma mark UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    
	//Resize auto complete table based on how many elements will be displayed in the table
    
    CGRect tableRect;
    CGRect baseViewRect;
    NSInteger returnCount = 0;
    
    if (_autoCompleteArray.count >=3) {
        tableRect = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableHeight*4);
        baseViewRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (tableHeight*4)+30);
		returnCount = _autoCompleteArray.count;
	}
	
	else if (_autoCompleteArray.count == 2 || _autoCompleteArray.count == 1) {
		tableRect = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableHeight*4);
        baseViewRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (tableHeight*4)+30);
		returnCount = _autoCompleteArray.count;
	}
	
	else {
		tableRect = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 0.0);
        baseViewRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, tableHeight);
		returnCount = _autoCompleteArray.count;
	}
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        autoCompleteTableView.frame = tableRect;
        self.frame = baseViewRect;
    } completion:^(BOOL finished) { }];
    
    autoCompleteTableView.hidden = NO;
    notMatchLabel.hidden=YES;
    if (returnCount == 0) {
        autoCompleteTableView.hidden = YES;
        notMatchLabel.hidden=NO;
    }
    return returnCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
	cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14.0]];
       
        CGFloat version = [[[ UIDevice currentDevice ] systemVersion ] floatValue];
        if( version > 6 ){
            [cell setBackgroundColor:[UIColor clearColor]];
        }
	}
    CAAutoCompleteObject *object = [_autoCompleteArray objectAtIndex:indexPath.row];
	cell.textLabel.text = object.objName;
    cell.imageView.image=[UIImage imageNamed:@"Live stream_server url_Pop-ups_link icon@3x.png"];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	CAAutoCompleteObject *object = [_autoCompleteArray objectAtIndex:indexPath.row];
	_txtField.text = object.objName;
	[self finishedSearching];
}

- (void) finishedSearching {
	[self resignFirstResponder];
    
    [_autoCompleteArray removeAllObjects];
    [autoCompleteTableView reloadData];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(CAAutoTextFillBeginEditing:)]) {
        [_delegate CAAutoTextFillBeginEditing:self];
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(CAAutoTextFillEndEditing:)]) {
        [_delegate CAAutoTextFillEndEditing:self];
    }
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL didYES = NO;
    if ([_delegate respondsToSelector:@selector(CAAutoTextFillWantsToEdit:)]) {
        didYES =  [_delegate CAAutoTextFillWantsToEdit:self];
    }
    
    return didYES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *substring = [NSString stringWithString:_txtField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
	[self searchAutocompleteEntriesWithSubstring:substring];
    
    return YES;
}

- (void)clear{
    [_dataSourceArray removeAllObjects];
    [_autoCompleteArray removeAllObjects];
    [autoCompleteTableView reloadData];
}

- (void)dealloc {
    [_dataSourceArray removeAllObjects];
    [_autoCompleteArray removeAllObjects];
    
    _autoCompleteArray = nil;;
    _dataSourceArray = nil;
    
    [autoCompleteTableView removeFromSuperview];
    autoCompleteTableView = nil;
    [_txtField removeFromSuperview];
    _txtField = nil;
}

@end
