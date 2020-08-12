//
//  ViewController.swift
//  SimpleReceiptApp
//
//  Created by Shunzhe Ma on 8/11/20.
//  Copyright © 2020 Shunzhe Ma. All rights reserved.
//

import UIKit

import QuickLook

struct Item {
    var name: String
    var price: Int
}

class ViewController: UITableViewController {
    
    var items = [Item]()
    
    var PDFpath: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /*
     レシートに項目を追加するアクション
     */
    @IBAction func actionAddItem(){
        //名前と価格を尋ねる
        let alert = UIAlertController(title: "項目を追加", message: nil, preferredStyle: .alert)
        //項目の名前を入力するテキストフィールド
        alert.addTextField { (nameTextField) in
            nameTextField.placeholder = "名前"
        }
        //項目の価格を入力するテキストフィールド
        alert.addTextField { (priceTextField) in
            priceTextField.placeholder = "価格"
        }
        //UIAlertAction
        let actionAdd = UIAlertAction(title: "追加", style: .default) { (action) in
            guard let name = alert.textFields?.first?.text else { return }
            //価格の文字列を価格の桁数に変換する
            guard let priceStr = alert.textFields?[1].text else { return }
            let price = Int(priceStr) ?? 0
            //項目を追加する
            let item = Item(name: name, price: price)
            self.items.append(item)
            //テーブルビューを再読み込みする
            self.tableView.reloadData()
        }
        alert.addAction(actionAdd)
        let actionDismiss = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionDismiss)
        present(alert, animated: true, completion: nil)
    }
    
    /*
     レシートを印刷するアクション
     */
    @IBAction func actionPrint(){
        // TODO
    }

}

/*
 テーブルビューにデータを提供する
 */
extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = String(item.price)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let rowI = indexPath.row
        items.remove(at: rowI)
        tableView.reloadData()
    }
    
}


