#Performing common API functions

Let's recap. We've set up our environment and we've learned how to set up a session. Now we are going to see how to use the API to list, upload and download files in your Dropbox folder.

The `DBRestClient` class is the way to access Dropbox from your app once the user has linked his account. The simplest way to use `DBRestClient` from an object is to add an instance variable in the .h file of your class:

	DBRestClient *restClient;
Next, let's create a getter method to allocate and initialize the instance variable in the .m file:

	#import <DropboxSDK/DropboxSDK.h>
	
	...
	
	- (DBRestClient *)restClient {
	   if (!restClient) {
	      restClient =
	         [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
	      restClient.delegate = self;
	   }
	   return restClient;
	}


##Upload a file
Now that you've created a `DBRestClient` object, you're ready to make requests. First, let's upload a file:

	NSString *localPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
	NSString *filename = @"Info.plist";
	NSString *destDir = @"/";
	[[self restClient] uploadFile:filename toPath:destDir
	                   withParentRev:nil fromPath:localPath];
When calling this method, `filename` is the name of the file and `toPath` is the folder where this file will be placed in the user's Dropbox. If you are uploading a new file, set the `parentRev` to `nil`, which will prevent uploads from overwriting existing files. `fromPath` is the full path of the file you are uploading on the device.

All the methods on `DBRestClient` are asynchronous, meaning they don't immediately return the data they are meant to load. Each method has at least two corresponding `DBRestClientDelegate` methods that get called when a request either succeeds or fails. The success callback will give you the data you requested and the failure callback will contain an `NSError` object that has more details on why the request failed. Here are the delegate methods that you should implement to get the results of the upload call:

	- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
	    from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
	
	    NSLog(@"File uploaded successfully to path: %@", metadata.path);
	}
	
	- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
	    NSLog(@"File upload failed with error - %@", error);
	}
Make sure you call DBRestClient methods from the main thread or a thread that has a run loop. Otherwise the delegate methods will not be called.

##List files in a folder
You can list the files in folder you just uploaded to with the following call:

	[[self restClient] loadMetadata:@"/"];
The rest client will call your delegate with one of the following callbacks:

	- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
	    if (metadata.isDirectory) {
	        NSLog(@"Folder '%@' contains:", metadata.path);
		for (DBMetadata *file in metadata.contents) {
		    NSLog(@"\t%@", file.filename);
		}
	    }
	}
	
	- (void)restClient:(DBRestClient *)client
	    loadMetadataFailedWithError:(NSError *)error {
	
	    NSLog(@"Error loading metadata: %@", error);
	}
Metadata objects are how you get information on files and folders in a user's Dropbox. Calling `loadMetadata:` on / will load the metadata for the root folder, and since it's a folder the contents property will contain a list of files and folders contained in that folder. It's advisable to keep this data around so that the next time you want to do something with a file, you can compare its current metadata to what you have stored to discern whether the file has been changed. Check out `DBMetadata.h` to see all the information metadata objects have.

##Download a file
Once you have a list of files in a folder, it's time to download one. To do this, you need to call the following:

	[[self restClient] loadFile:dropboxPath intoPath:localPath]
Here, `srcPath` is the path in the user's Dropbox (you probably got this from a metadata object), and `destPath` is the location on the local device you want the file to be put after it has been downloaded. To find out when the file download either succeeds or fails implement the following `DBRestClientDelegate` methods:

	- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
	    NSLog(@"File loaded into path: %@", localPath);
	}
	
	- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
	    NSLog(@"There was an error loading the file - %@", error);
	}
##In conclusion
Now that you've seen how to perform all the basic operations, you're ready to start building your app. To see all the operations that are available and their respective callback methods look at `DBRestClient.h` in the SDK. To see a more complete example of how to use `DBRestClient` you can look at `PhotoViewController.m` in the `DBRoulette` example project. If you're still not sure about something, the Developers forum is a great place to find information and get help from fellow developers.