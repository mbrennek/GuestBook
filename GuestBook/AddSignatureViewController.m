//
//  AddSignatureViewController.m
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import "AddSignatureViewController.h"
#import "GuestBookAppDelegate.h"
#import "Signature.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <UIKit/UIImagePickerController.h>
#import <MediaPlayer/MPMoviePlayerController.h>

@implementation AddSignatureViewController

@synthesize managedObjectContext=__managedObjectContext;
@synthesize mediaPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        mediaPath = nil;
    }
    return self;
}

-(IBAction)submitSig:(id)sender
{
    // TODO: check for valid data before added to database
    

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Signature" inManagedObjectContext:self.managedObjectContext];
    Signature *signature = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.managedObjectContext];
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    signature.timeStamp = [NSDate date];
    signature.name = name.text;
    signature.message = message.text;
    if(imageButton.imageView.image != nil)
    {
        signature.thumbnail = UIImageJPEGRepresentation(imageButton.imageView.image, 0.5);
    }
    signature.uuid = [appDelegate generateUuidString];
    signature.event = [appDelegate currentEvent];
    signature.mediaPath = mediaPath;

    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    // dismiss popup, change to selected event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"signaturePopoverShouldDismiss" object:nil];
    
    [self clearFormState];
}

-(void)clearFormState
{
    [name setText:@""];
    [message setText:@""];
    [imageButton setImage:nil forState:UIControlStateNormal];
    [imageButton setTitle:@"Press to add image/video"  forState:UIControlStateNormal];
    mediaPath = nil;
    
}

- (IBAction)addMultimedia:(id)sender
{
    // bring up camera view, capture image/video, set thumbnail to button image
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // Displays a control that allows the user to choose picture or
        // movie capture, if both are available:
        cameraUI.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypeCamera];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        cameraUI.allowsEditing = NO;
        
        cameraUI.delegate = self;
        cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        [self presentModalViewController: cameraUI animated: YES];
        [cameraUI release];
    }
    else
    {
        UIButton *button = sender;
        [button setTitle:@"Sorry, no camera found" forState:UIControlStateNormal];
    }
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
    [picker release];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {

    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // handle re-picking
    if(mediaPath)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:mediaPath error:&error];
        mediaPath = nil;
    }
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        // save image to directory, save thumbnail and path to coreData store.
        CGSize buttonSize = CGSizeMake(245, 180);
        UIImage *thumbnailImage = [imageToSave resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:buttonSize interpolationQuality:kCGInterpolationDefault];
        
        [[imageButton imageView] setContentMode:UIViewContentModeScaleToFill];
        [imageButton setTitle:@"" forState:UIControlStateNormal];
        [imageButton setImage:thumbnailImage forState:UIControlStateNormal];
        imageButton.layer.cornerRadius = 15;
        imageButton.layer.masksToBounds = YES;
        mediaPath = [[NSString alloc] initWithFormat:@"%@.jpg", [[[appDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:[appDelegate generateUuidString]] path]];
        [UIImageJPEGRepresentation(imageToSave, 1.0) writeToFile:mediaPath atomically:YES];        
    }
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        NSString *moviePath = [[info objectForKey:
                                UIImagePickerControllerMediaURL] path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            // handle movie
            mediaPath = [[NSString alloc] initWithFormat:@"%@.mp4", [[[appDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:[appDelegate generateUuidString]] path]];
            NSError *error = nil;
            [[NSFileManager defaultManager] copyItemAtPath:moviePath toPath:mediaPath error:&error];
            if(error)
            {
                NSLog(@"%@", [error localizedDescription]);
            }

            // use movie player to generate a thumbnail
            NSURL *videoURL = [NSURL fileURLWithPath:mediaPath];
            MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
            UIImage *thumb = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
            CGSize buttonSize = CGSizeMake(245, 180);
            UIImage *thumbnailImage = [thumb resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:buttonSize interpolationQuality:kCGInterpolationDefault];
            [imageButton setImage:thumbnailImage forState:UIControlStateNormal];
            [player stop];
            [player release];
        }
    }
    
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.contentSizeForViewInPopover = CGSizeMake(650.0, 250.0);
    [self clearFormState];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self clearFormState];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
