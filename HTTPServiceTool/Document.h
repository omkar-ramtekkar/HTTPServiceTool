//
//  Document.h
//  HTTPServiceTool
//
//  Created by omkar on 01/04/16.
//  Copyright (c) 2016 Omkar Ramtekkar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Document : NSDocument

@property (nonatomic, strong) IBOutlet NSComboBox *requestTypeCombo;
@property (nonatomic, strong) IBOutlet NSTextField *serverURLTF;

@property (nonatomic, strong) IBOutlet NSComboBox *contentTypeCombo;
@property (nonatomic, strong) IBOutlet NSTextField *soapActionTF;

@property (nonatomic, strong) IBOutlet NSTextView *httpBodyTV;
@property (nonatomic, strong) IBOutlet NSButton *useCookiecheckBox;

@property (nonatomic, strong) IBOutlet NSTextField *statusCodeTF;
@property (nonatomic, strong) IBOutlet NSTextField *redirectURLTF;
@property (nonatomic, strong) IBOutlet NSTextView *responseDataTV;
@property (nonatomic, strong) IBOutlet NSTextField *responseDataLengthLabel;
@property (nonatomic, strong) IBOutlet NSTextView *errorTV;

@property (nonatomic, strong) IBOutlet NSButton *startStopButton;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *progressBar;

@property (nonatomic, strong) IBOutlet NSTextField *usernameTF;
@property (nonatomic, strong) IBOutlet NSTextField *passwordTF;

-(IBAction) startStopHttpOperation:(id)sender;
-(IBAction) actionPreviewHttpResponse:(id)sender;


@end

