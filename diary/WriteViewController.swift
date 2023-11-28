//
//  WriteViewController.swift
//  diary
//
//  Created by jmj on 2023/11/26.
//

import UIKit

class WriteViewController:UIViewController{
    
    var diary:Diary?
    var isUpdate = false
    
    var delegate:DiaryTask? = nil
    @IBOutlet weak var content: UITextView!
    
    override func viewDidLoad() {
        if diary != nil {
            content.text = diary?.content
            isUpdate = true
        }
        
        content.layer.cornerRadius = 10
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    
    @IBAction func save(_ sender: Any) {
        if content.text == "" { return }
            
        if isUpdate {
            //update
            delegate?.updateDiary(id: diary!.id, content: content.text)
        }else{
            //create
            delegate?.createDiary(content: content.text)
        }
        
        self.dismiss(animated: false) 
    }
}
