//
//  AppDelegate.swift
//  PicPx
//
//  Created by im61 on 7/31/15.
//  Copyright © 2015 Fellow Plus. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let url = "http://picpx.com/uptoken"
        let params = ["image": "image.png"]
        
        post(url, params: params) { (data, response, error) -> Void in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                print("\(json)")
            } catch let error as NSError {
                print("error:\(error)")
            } catch {
                print("parse data error")
            }
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func post(url: String, params: Dictionary<String, String>, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)?) {
        var components: [(String, String)] = []
        
        for key in Array(params.keys).sort(<) {
            let value: String! = params[key]
            components += [(key, value!)]
        }

        let pair = components.map { "\($0)=\($1)" } as [String]
        let paramString = "&".join(pair)
        let data = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = data
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completionHandler!)!
        
        task.resume()
    }
    
    func application(sender: NSApplication, openFile filename: String) -> Bool {
        print("\(filename)")
        return true
    }
}

