# QRIO
Lightweight framework for QR scanning and generation


## 📝 Requirements 

* iOS 8.0+

## 📦 Installation

### Carthage
~~~
github "nodes-ios/QRIO"
~~~

## 💻 Usage
**Creating a QR Code:**

It's as easy as

~~~swift
let image = QRIO.QRImageFromString("Hello World!")
~~~

This will return a UIImage: 

![HelloWorldQR](https://raw.githubusercontent.com/nodes-ios/QRIO/master/HelloWorldQR.png)

You can also adjust the size of the generated image, which will give you a clearer image, and the correction level, which adds more error protection, by using the optional parameters:

~~~swift
let image = QRIO.QRImageFromString("Hello World!", 
				containingViewSize: imageView.bounds.size, 
					correctionLevel: "M")
~~~

![HelloWorldQR](https://raw.githubusercontent.com/nodes-ios/QRIO/master/HelloWorldQR2.png)


**Scanning a QR Code:**

You will need to create an instance of QRIO and maintain a strong reference to it:

~~~swift
let qrio = QRIO()

func scanForQR() {
	qrio.scanForQRImage(previewIn: previewContainer) { (string) in
		print(string) // Prints "Hello World!" when using the QR codes above
	}
}
~~~

You can optionally pass a view to display the preview video in, and also a rect of interest to focus the detection. 

~~~swift
let qrio = QRIO()

func scanForQR() {
	qrio.scanForQRImage(previewIn: previewContainer, rectOfInterest: hotspotView.frame) { (string) in
		print(string) // Prints "Hello World!" when using the QR codes above
	}
}
~~~

And that's it! If you need to end QR scanning, you can call `finish()` on your QRIO object. 


## 👥 Credits
Made with ❤️ at [Nodes](http://nodesagency.com).

## 📄 License
**QRIO** is available under the MIT license. See the [LICENSE](https://raw.githubusercontent.com/nodes-ios/QRIO/master/LICENSE) file for more info.