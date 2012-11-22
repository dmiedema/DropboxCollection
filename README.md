# Dropbox Collection
Implementing Finder's Column View on iPad/iPhone with Dropbox. 

How to make it run - Add your own Dropbox App Key and Dropbox App Secret to `DropboxAPIKey.h`. Also modify the `DropboxCollection-Info.plist` 

find 
```
  <key>CFBundleURLTypes</key>
  <array>
		<dict>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>db-XXXXXXXX</string>
			</array>
		</dict>
	</array>
```

And replace the `<string>-db-XXXXXXXX</string>` with `db-<yourAppKey>`.

Example, if your app key is `abc123` you would put `<string>db-abc123</string>`.


<put some screen shots here>

<maybe another one here>

##Known Bugs

* Selecting items from two tables at a time will probably crash the app.
* Opening some folders, selecting an item to the left, then selecting an item to the right will crash the app too.

Created by Ryan Mullins (@RyanMullins) and Daniel Miedema (@SomeWhores) at Cocoa Camp 2012.

##Copyright and Licensing

Licensed under the MIT License.

Copyright (C) 2012 Ryan Mullins, Daniel Miedema

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.