//
//  LoginController.swift
//  gob-swift-eval
//
//  Created by Quentin Tshaimanga on 17/05/2016.
//  Copyright © 2016 Etienne De Ladonchamps. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController{
    
    @IBOutlet var pseudo: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var mdp: UITextField!
    @IBOutlet var birthday: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground("loginBackground.png")
        let data:NSDictionary = UserSingleton.sharedInstance.getUserData();
        
        //TODO if isset if -> show other viewcontroller
        let id:Int = Int(UserSingleton.sharedInstance.getUserData()["userId"]! as! NSNumber);
        if(id != 0){
            //print(getData("http://localhost:8080/users/id=\(id)&param=all"));
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("login", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if "login" == segue.identifier {
            print("go to map");
        }
    }
    
    
    @IBAction func login(sender: AnyObject) {
        if(!pseudo.text!.isEmpty && !birthday.text!.isEmpty && !email.text!.isEmpty && !mdp.text!.isEmpty){
            let data:[String:AnyObject] = [
                "pseudo":pseudo.text!,
                "date":birthday.text!,
                "email":email.text!,
                "mdp":mdp.text!
            ]
            postData(data, url: "http://localhost:8080/user/");
        }
    }
    
    
    //set backgroundImage
    func assignbackground(background:NSString){
        let background = UIImage(named: background as String)
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    
    //post request
    func postData(dictionaryData:[String: AnyObject], url:NSString){
        let request = NSMutableURLRequest(URL: NSURL(string: url as String)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        var data = NSData()
        do{
            data = try NSJSONSerialization.dataWithJSONObject(dictionaryData, options: [])
        }catch let error as NSError {
            print(error)
        }
        
        request.HTTPBody = data
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            
            if let actuelError = error{
                print(actuelError)
            }else{
                if let httpResponse = response as? NSHTTPURLResponse {
                    if let dataResponse = httpResponse.allHeaderFields["Data"] as? String {
                        
                        //TODO add ASYNCHRONOUS
                        UserSingleton.sharedInstance.setUserData(Int(dataResponse)!, pseudo: self.pseudo.text!, date: self.birthday.text!, email: self.email.text!, mdp: self.mdp.text!)
                        print(UserSingleton.sharedInstance.getUserData());

                    }
                }
            }
        }
    }
    
    
    func getData(url:NSString)->AnyObject{
        let data = NSData(contentsOfURL: NSURL(string: url as String)!)
        var jsonResult:AnyObject = []
        if (data != nil){
            do {
                jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
            } catch let error as NSError {
                print(error)
            }
        }else{
            print("error connection database (php)")
        }
        return jsonResult
    }

    
}


//Persist Data
class UserSingleton {
    static let sharedInstance = UserSingleton()
    
    //let defaults:NSUserDefaults;
    let defaults = NSUserDefaults.standardUserDefaults();
    var data:[String:AnyObject] = [:];

    private init() {
        print(self.getUserData());
    }
    
    func getUserData() ->NSDictionary {
        self.data = [
            "userId":defaults.integerForKey("identifiant"),
            "userParent":defaults.integerForKey("parent"),
            "userPseudo":defaults.stringForKey("pseudo")!,
            "userDate": defaults.stringForKey("date")!,
            "email":defaults.stringForKey("email")!,
            "mdp":defaults.stringForKey("mdp")!
        ]
        return self.data
    }
    
    func setUserParent(parent: Int) {
        self.defaults.setObject(parent, forKey: "parent")
    }
    
    func setUserData(id: Int, pseudo: String, date:String, email:String, mdp:String) {
        self.defaults.setObject(id, forKey: "identifiant")
        self.defaults.setObject(pseudo, forKey: "pseudo")
        self.defaults.setObject(date, forKey: "date")
        self.defaults.setObject(email, forKey: "email")
        self.defaults.setObject(mdp, forKey: "mdp")
    }
    
}
