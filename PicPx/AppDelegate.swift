//
//  AppDelegate.swift
//  PicPx
//
//  Created by im61 on 7/31/15.
//  Copyright © 2015 Fellow Plus. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func application(sender: NSApplication, openFile filename: String) -> Bool {
        let name = filename.lastPathComponent;
        
        getPolicyAndSignature(name) { (params) -> Void in
            self.upload(filename, params: params, completionHandler: { (data, response, error) -> Void in
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? Dictionary<String, AnyObject> {
                        let url: String = json["url"] as! String
                        let fullURL: String = "http://deeppic.b0.upaiyun.com" + url
                        self.writeToPasteBoard(fullURL)
                        
                        let notification: NSUserNotification = NSUserNotification();
                        notification.title = "图片链接已复制到剪贴板"
                        notification.informativeText = fullURL
                        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
                        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
                    }
                } catch let error as NSError {
                    print("error:\(error)")
                } catch {
                    print("parse data error")
                }
            })
        }
        
        return true
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true;
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        let url = notification.informativeText
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: url!)!)
    }
    
    func writeToPasteBoard(content: String) {
        NSPasteboard.generalPasteboard().declareTypes([NSStringPboardType], owner: nil)
        NSPasteboard.generalPasteboard().setString(content, forType: NSStringPboardType)
    }
    
    func getPolicyAndSignature(fileName: String, completionHandler: ((Dictionary<String, String>) -> Void)) {
        let url = "http://picpx.com/uptoken"
        let params = ["image": fileName]
        
        post(url, params: params) { (data, response, error) -> Void in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? Dictionary<String, String>
                completionHandler(json!)
            } catch let error as NSError {
                print("error:\(error)")
            } catch {
                print("parse data error")
            }
        }
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
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completionHandler!)
        
        task.resume()
    }
    
    func upload(filePath: String, params: Dictionary<String, String>, completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void)?) {
        let url = "http://v0.api.upyun.com/deeppic"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary=" + boundaryConstant
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let imageData = NSFileManager.defaultManager().contentsAtPath(filePath)!
        let uploadData = NSMutableData()
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"\(filePath.lastPathComponent)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        for (key, value) in params {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = uploadData
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: completionHandler!)
        
        task.resume()
    }
}

