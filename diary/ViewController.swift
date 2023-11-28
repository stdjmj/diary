//
//  ViewController.swift
//  diary
//
//  Created by jmj on 2023/11/26.
//

import UIKit
import FSCalendar

class ViewController: UIViewController , FSCalendarDataSource, FSCalendarDelegate{
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedDate:Date = Date()
    var db = DBHelper()
    var totalDiary:[String:[Diary]] = [:]
    var dateFmt = DateFormatter()
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.dataSource = self
        calendar.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        totalDiary=db.readDiary()
        
        changeCurrentDateView()
        setCalendarView()
    }
    
    //날짜 선택
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        changeCurrentDateView()
        tableView.reloadData()
    }
    
    //현재 날짜 뷰 변경
    func changeCurrentDateView(){
        dateFmt.dateFormat = "MM월 dd일"
        dateLabel.text = dateFmt.string(from: selectedDate)
    }
    
    //작성 페이지로 이동(C)
    @IBAction func moveWritePage(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "WriteViewController") as? WriteViewController else{return}
        
        vc.delegate = self
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        
        self.present(vc, animated: true)
    }
    
    //캘린더 꾸미기
    func setCalendarView(){
        calendar.appearance.titleWeekendColor = UIColor.init(red: 245, green: 140, blue: 85)
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.todayColor = UIColor.init(red: 245, green: 140, blue: 85)
        calendar.appearance.selectionColor = UIColor.init(red: 120, green: 200, blue: 80)
    
        calendar.appearance.eventDefaultColor = UIColor.init(red: 90, green: 155, blue: 79)
    }
    
    
    //dot event
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        dateFmt.dateFormat = "yy.MM.dd"
        
        let currentDate = dateFmt.string(from: date)
        
        
        if totalDiary[currentDate] != nil {
            return totalDiary[currentDate]!.count
        }
        
        return 0
        
    }
    
}

extension ViewController : UITableViewDataSource, UITableViewDelegate{
    
    //테이블 뷰 샐
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! CustomCell
        
        dateFmt.dateFormat = "yy.MM.dd"
        
        cell.content.text = totalDiary[dateFmt.string(from: selectedDate)]![indexPath.row].content
        
        //삭제
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteBtnTapped(sender: )), for: .touchUpInside)
        
        //수정
        cell.updateBtn.tag = indexPath.row
        cell.updateBtn.addTarget(self, action: #selector(updateBtnTapped(sender: )), for: .touchUpInside)
        return cell;
    }
    
    @objc func deleteBtnTapped(sender:UIButton){
        let deleteDiaryId = totalDiary[dateFmt.string(from: selectedDate)]![sender.tag].id
        
        let state = db.deleteDiary(id: deleteDiaryId)
        if state {
            dateFmt.dateFormat = "yy.MM.dd"
            totalDiary[dateFmt.string(from: selectedDate)]?.remove(at: sender.tag)
            
            tableView.reloadData()
            calendar.reloadData()
        }
    }
    
    //작성페이지로 이동(U)
    @objc func updateBtnTapped(sender:UIButton){
        guard let vc = storyboard?.instantiateViewController(identifier: "WriteViewController") as? WriteViewController else{return}
        
        dateFmt.dateFormat = "yy.MM.dd"
        
        vc.delegate = self
        vc.diary = totalDiary[dateFmt.string(from: selectedDate)]![sender.tag]
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        
        self.present(vc, animated: true)
    }
    
    //개수 출력
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dateFmt.dateFormat = "yy.MM.dd"
        
        return totalDiary[dateFmt.string(from: selectedDate)]?.count ?? 0
    }
}

extension ViewController : DiaryTask{
    
    //다이어리 생성
    func createDiary(content:String){
        let id = db.insertDiary(content: content, timestampt: selectedDate.timeIntervalSince1970)
        
        if id != nil{
            dateFmt.dateFormat = "yy.MM.dd"
            let selectedDateStr = dateFmt.string(from: selectedDate)
            
            let new_diary = Diary(id: id!, content: content, date: selectedDate)
            
            if totalDiary[selectedDateStr] == nil{
                //새로 추가
                totalDiary[selectedDateStr] = [new_diary]
            }else{
                //기존거에 추가
                totalDiary[selectedDateStr]?.append(new_diary)
            }
            
            tableView.reloadData()
            calendar.reloadData()
        }
    }
    
    //다이어리 수정
    func updateDiary(id:Int,content:String){
        let state = db.updateDiary(id: id, content: content)
        
        if state {
            dateFmt.dateFormat = "yy.MM.dd"
            let selectedDateStr = dateFmt.string(from: selectedDate)
            
            if let index = totalDiary[selectedDateStr]?.firstIndex(where: {$0.id == id}){
                totalDiary[selectedDateStr]![index].content = content
            }
            
            tableView.reloadData()
        }
    }
}


protocol DiaryTask{
    func createDiary(content:String)
    func updateDiary(id:Int, content:String)
}

struct Diary{
    let id:Int
    var content:String
    let date:Date
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}
