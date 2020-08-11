//
//  PDFHelper.swift
//  SimpleReceiptApp
//
//  Created by Shunzhe Ma on 8/11/20.
//  Copyright © 2020 Shunzhe Ma. All rights reserved.
//

import Foundation
import UIKit

func headerHTMLstring() -> String {
    //htmlヘッダーを生成します。
    //たとえば、ここに店の名前を入力できます
    return """
    <!DOCTYPE html>
    <html>
        <head>
                <title>レシート</title>
        <style>
                table, th, td {
                  border: 1px solid black;
                  border-collapse: collapse;
                }
        </style>
        <body>
            <h2>Invoice</h2>
            <table style="width:100%">
                <tr>
                    <th>名前</th>
                    <th>価格</th>
                </tr>
    """
}

func getSingleRow(itemName: String, itemPrice: Int) -> String {
    return """
    <tr>
        <td>\(itemName)</td>
        <td>\(String(itemPrice))</td>
    </tr>
    """
}

func footerHTMLstring() -> String {
    return """
        </table>

        </body>
    </html>
    """
}
