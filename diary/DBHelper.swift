//
//  DBHelper.swift
//  diary
//
//  Created by jmj on 2023/11/27.
//

import Foundation
import SQLite3

class DBHelper{
    var db:OpaquePointer?
    
    init(){
        db = openDB()
        createTable()
    }
    
    func openDB() -> OpaquePointer?{
        do{
            let dbPath = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil , create: false).appendingPathExtension("mydb.sqlite").path
            
            if sqlite3_open(dbPath, &db) == SQLITE_OK{
                return db
            }
        }catch{
            print("error")
        }
        
        return nil
    }
    
    func createTable(){
        let query = """
            create table if not exists diary(
                id integer primary key autoincrement,
                content text,
                date real not null
            )
        """
        
        var statement:OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE{
                print("테이블 생성 완료")
            }else{
                print("테이블 생성 실패")
            }
        }
        
        sqlite3_finalize(statement)
    }
    
    /*
    func readDiary() -> [Diary]{
        let query = "select * from diary"
        var statement:OpaquePointer? = nil
        var list:[Diary] = []
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW{
                let id = sqlite3_column_int(statement, 0)
                let content = String(cString: sqlite3_column_text(statement, 1))
                let date = sqlite3_column_double(statement, 2)
                
                list.append(Diary(id: Int(id), content: content, date: Date(timeIntervalSince1970: date)))
                
            }
        }
        
        sqlite3_finalize(statement)
        
        return list
    }
     */
    
    
    func readDiary() -> [String:[Diary]]{
        let query = "select * from diary"
        var statement:OpaquePointer? = nil
        var list:[String:[Diary]] = [:]
        
        if sqlite3_prepare_v2(db, query,-1, &statement, nil) == SQLITE_OK{
            let dateFmt = DateFormatter()
            dateFmt.dateFormat = "yy.MM.dd"
            
            while sqlite3_step(statement) == SQLITE_ROW{
                let id = sqlite3_column_int(statement, 0)
                let content = String(cString: sqlite3_column_text(statement, 1))
                let timestamp = sqlite3_column_double(statement, 2)
                
                let currentDiary = Diary(id: Int(id), content: content, date: Date(timeIntervalSince1970: timestamp))
                
                let date = dateFmt.string(from: currentDiary.date)
                
                if list[date] == nil{
                    list[date] = [currentDiary]
                }else{
                    list[date]!.append(currentDiary)
                }
            }
        }
        
        sqlite3_finalize(statement)
        return list
    }
    
    func insertDiary(content:String, timestampt: Double)->Int?{
        let query = "insert into diary(content, date) values(?,?)"
        var statement:OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query,-1, &statement, nil) == SQLITE_OK{
            
            sqlite3_bind_text(statement, 1, (content as NSString).utf8String,-1,nil)
            
            sqlite3_bind_double(statement, 2, timestampt)
            
            
            if sqlite3_step(statement) == SQLITE_DONE{
                let lastId = Int(sqlite3_last_insert_rowid(self.db))
                
                return lastId
            }
        }
        
        sqlite3_finalize(statement)
        
        return nil
        
    }
    
    
    func updateDiary(id:Int, content:String) -> Bool{
        let query = "update diary set content = ? where id = ?"
        var statement:OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query,-1, &statement, nil) == SQLITE_OK{
            
            sqlite3_bind_text(statement, 1, (content as NSString).utf8String,-1,nil)
            sqlite3_bind_int(statement, 2, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE{
                return true
            }
        }
        
        sqlite3_finalize(statement)
        
        return false
    }
    
    func deleteDiary(id:Int) -> Bool{
        let query = "delete from diary where id = ?"
        var statement:OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE{
                sqlite3_finalize(statement)
                return true
            }
        }
        
        sqlite3_finalize(statement)
        return false;
    }
    
}
