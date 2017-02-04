Plopix Konami Code Gesture
==========================

Simple implementation of the KonamiCode gesture in Swift. 

![alt text](https://raw.githubusercontent.com/Plopix/PlopixKonamiCodeGesture/master/StandoloneProject/KonamiCode/Images.xcassets/PlopixKonamiCode.imageset/Plopix_Konami_Code.png "Up, Up, Down, Down, Left, Right, Left, Right, Tap, Tap")

Including into your project
---------------------------

Just drag and drop *PlopixKonamiGesture.swift* file into your project.

Usage
-----

**Swift:**

```swift
    let recognizer = PlopixKonamiGesture(target: self, action: #selector(ViewController.launchEasterEgg))
	view.addGestureRecognizer(recognizer)        

	//——     
	
    func launchEasterEgg(recognizer: UIGestureRecognizer) {
        if ( recognizer.state == .Ended ) {
			// do what you want
        }
    }
    
```
**Objectice-c:**

```objc
	// Don’t forget to add #import "[ProjectName]-Swift.h" 
	
    PlopixKonamiGesture *recognizer = [[PlopixKonamiGesture alloc] initWithTarget:self action:@selector(launchEasterEgg:)];
    [self.view addGestureRecognizer:recognizer];

	//—— 
	
	- (void) launchEasterEgg:(UIGestureRecognizer *) recognizer {
    	if (recognizer.state == UIGestureRecognizerStateEnded ) {
        	// do what you want
    	}
	}
```


You can also look at the example projet.


Contact
-------
Author: Sébastien Morel aka Plopix

Follow [@plopix](http://twitter.com/plopix) on Twitter for the latest news.

License
------------
Available under the MIT license. See the LICENSE file for more info.
