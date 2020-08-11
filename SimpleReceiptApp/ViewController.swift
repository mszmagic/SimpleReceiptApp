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
        var htmlString = ""
        // HTMLのヘッダーを取得する
        let htmlHeader = headerHTMLstring()
        htmlString.append(htmlHeader)
        // 行を取得する
        var totalPrice = 0
        for item in items {
            let name = item.name
            let price = item.price
            let rowString = getSingleRow(itemName: name, itemPrice: price)
            htmlString.append(rowString)
            totalPrice += price
        }
        // 合計金額を追加する
        htmlString.append("\n 合計金額: \(totalPrice) yen \n")
        // フッターを取得する
        let footerString = footerHTMLstring()
        htmlString.append(footerString)
        //HTML -> PDF
        let pdfData = getPDF(fromHTML: htmlString)
        //PDFデータを一時ディレクトリに保存する
        if let savedPath = saveToTempDirectory(data: pdfData) {
            //PDFファイルを表示する
            self.PDFpath = savedPath
            let previewController = QLPreviewController()
            previewController.dataSource = self
            present(previewController, animated: true, completion: nil)
        }
    }
    
    /*
     この関数はHTML文字列を受け取り、PDFファイルを表す `NSData` オブジェクトを返します。
     */
    func getPDF(fromHTML: String) -> NSData {
        let renderer = UIPrintPageRenderer()
        let paperSize = CGSize(width: 595.2, height: 841.8) //B6
        let paperFrame = CGRect(origin: .zero, size: paperSize)
        renderer.setValue(paperFrame, forKey: "paperRect")
        renderer.setValue(paperFrame, forKey: "printableRect")
        let formatter = UIMarkupTextPrintFormatter(markupText: fromHTML)
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, [:])
        for pageI in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: pageI, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        return pdfData
    }
    
    /*
     この関数は、特定の `data` をアプリの一時ストレージに保存します。さらに、そのファイルが存在する場所のパスを返します。
     */
    func saveToTempDirectory(data: NSData) -> URL? {
        let tempDirectory = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let filePath = tempDirectory.appendingPathComponent("receipt-" + UUID().uuidString + ".pdf")
        do {
            try data.write(to: filePath)
            return filePath
        } catch {
            print(error.localizedDescription)
            return nil
        }
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

/*
 `QLPreviewController` にPDFデータを提供する
 */

extension ViewController: QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        if self.PDFpath != nil {
            return 1
        } else {
            return 0
        }
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let pdfFilePath = self.PDFpath else {
            return "" as! QLPreviewItem
        }
        return pdfFilePath as QLPreviewItem
    }
    
}


