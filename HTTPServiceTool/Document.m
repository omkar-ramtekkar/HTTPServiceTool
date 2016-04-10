//
//  Document.m
//  HTTPServiceTool
//
//  Created by omkar on 01/04/16.
//  Copyright (c) 2016 Omkar Ramtekkar. All rights reserved.
//

#import "Document.h"
#import <AFNetworking/AFNetworking.h>

#define VALIDATE_UI_STRING(string) string ? string : @""
#define VALIDATE_STRING(string) TRIM(string).length ? TRIM(string) : nil
#define TRIM(string) [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]

@interface Document ()

@property (strong) AFHTTPRequestOperationManager *operationManager;
@property (copy) NSHTTPURLResponse *lastHttpResponse;

@end

@implementation Document

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        self.operationManager = [AFHTTPRequestOperationManager manager];
        self.operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    [self revertDocumentToSaved:self];
    
    [self.progressBar setHidden:YES];
    
    id w = self.contentTypeCombo.window;
    [self.requestTypeCombo.window makeFirstResponder:self.requestTypeCombo];
    [self.useCookiecheckBox setState:NSOnState];
}

+ (BOOL)autosavesInPlace {
    return NO;
}

-(IBAction) startStopHttpOperation:(id)sender
{
    if (self.operationManager.operationQueue.operationCount)
    {
        [self stopOperation];
    }
    else
    {
        [self startOperation];
    }
}

-(IBAction) actionPreviewHttpResponse:(id)sender
{
    NSString *tempDir = NSTemporaryDirectory();
    
    NSString *tempPreviewFilePath = [tempDir stringByAppendingPathComponent:@"httpservicetool.xml"];
    
    NSError *error = nil;
    BOOL b = [self.responseDataTV.string writeToFile:tempPreviewFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
    {
        NSLog(@"Preview error - %@", error);
        return;
    }
    
    NSString *cmd = [NSString stringWithFormat:@"/usr/bin/open -a \"/Volumes/Yosemite/Applications/Google Chrome.app\" %@", tempPreviewFilePath];
    
    system(cmd.UTF8String);
}

-(void) startOperation
{
    NSLog(@"%@", self.httpBodyTV.string);
    
    if (VALIDATE_STRING(self.usernameTF.stringValue) && VALIDATE_STRING(self.passwordTF.stringValue))
    {
        [self.operationManager.requestSerializer setAuthorizationHeaderFieldWithUsername:VALIDATE_STRING(self.usernameTF.stringValue) password:VALIDATE_STRING(self.passwordTF.stringValue)];
    }
    
    NSString *randomTokenRequestString = [NSString stringWithFormat:@"%@#%lu", VALIDATE_STRING(self.serverURLTF.stringValue), random()];
    
    NSMutableURLRequest *request = [self.operationManager.requestSerializer requestWithMethod:VALIDATE_STRING(self.requestTypeCombo.objectValueOfSelectedItem) URLString:randomTokenRequestString  parameters:nil error:nil];
    
    if (VALIDATE_STRING(self.httpBodyTV.string))
    {
        
        [request setHTTPBody:[VALIDATE_STRING(self.httpBodyTV.string) dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (VALIDATE_STRING(self.soapActionTF.stringValue))
    {
        [request setValue:VALIDATE_STRING(self.soapActionTF.stringValue) forHTTPHeaderField:@"SOAPAction"];
    }
    
    if (VALIDATE_STRING(self.contentTypeCombo.objectValueOfSelectedItem))
    {
        [request setValue:VALIDATE_STRING(self.contentTypeCombo.objectValueOfSelectedItem) forHTTPHeaderField:@"content-type"];
    }
    
    [request setHTTPShouldHandleCookies:self.useCookiecheckBox.state == NSOnState ? YES : NO];
    
    [self.startStopButton setTitle:@"Cancel"];
    [self.progressBar setHidden:NO];
    [self.progressBar startAnimation:self];
    
    
    AFHTTPRequestOperation *op = [self.operationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [self handleHTTPSuccessful:operation];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleHTTPFailed:operation error:error];
    }];
    
    [self.operationManager.operationQueue addOperation:op];
}

-(void) handleHTTPSuccessful:(AFHTTPRequestOperation*) operation
{
    NSLog(@"Operation Successful - %@", operation);
    
    [self.startStopButton setTitle:@"Start"];
    [self.progressBar stopAnimation:self];
    [self.progressBar setHidden:YES];
    
    self.statusCodeTF.stringValue = [NSString stringWithFormat:@"%lu", operation.response.statusCode];
    self.redirectURLTF.stringValue = VALIDATE_UI_STRING(operation.response.URL.absoluteString);
    [self.responseDataTV setString:VALIDATE_UI_STRING(operation.responseString)];
    self.responseDataLengthLabel.stringValue = [NSString stringWithFormat:@"%lu bytes", operation.responseData.length];
    self.lastHttpResponse = operation.response;
}

-(void) handleHTTPFailed:(AFHTTPRequestOperation*) operation error:(NSError*) error
{
    NSLog(@"Operation Failed - %@", error);
    
    [self.startStopButton setTitle:@"Start"];
    [self.progressBar stopAnimation:self];
    [self.progressBar setHidden:YES];
    
    self.statusCodeTF.stringValue = [NSString stringWithFormat:@"%lu", operation.response.statusCode];
    self.redirectURLTF.stringValue = VALIDATE_UI_STRING(operation.response.URL.absoluteString);
    [self.responseDataTV setString:VALIDATE_UI_STRING(operation.responseString)];
    self.responseDataLengthLabel.stringValue = [NSString stringWithFormat:@"%lu bytes", operation.responseData.length];
    
    self.errorTV.string = VALIDATE_UI_STRING(error.localizedDescription);
}



-(void) stopOperation
{
    if([self.operationManager.operationQueue operationCount])
    {
        [self.operationManager.operationQueue cancelAllOperations];
    }
}

- (NSString *)windowNibName {
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
//    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
//    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
//    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
//    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return YES;
}

@end
