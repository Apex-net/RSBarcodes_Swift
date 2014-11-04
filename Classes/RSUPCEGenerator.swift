//
//  RSUPCEGenerator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/11/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit

// http://www.sly.com.tw/skill/know/new_page_6.htm
// http://mdn.morovia.com/kb/UPCE-Specification-10634.html
// http://mdn.morovia.com/kb/UPCA-Specification-10632.html
// http://www.barcodeisland.com/upce.phtml
class RSUPCEGenerator: RSAbstractCodeGenerator, RSCheckDigitGenerator {
    let UPCE_ODD_ENCODINGS = [
        "0001101",
        "0011001",
        "0010011",
        "0111101",
        "0100011",
        "0110001",
        "0101111",
        "0111011",
        "0110111",
        "0001011"
    ]
    
    let UPCE_EVEN_ENCODINGS = [
        "0100111",
        "0110011",
        "0011011",
        "0100001",
        "0011101",
        "0111001",
        "0000101",
        "0010001",
        "0001001",
        "0010111"
    ]
    
    let UPCE_SEQUENCES = [
        "000111",
        "001011",
        "001101",
        "001110",
        "010011",
        "011001",
        "011100",
        "010101",
        "010110",
        "011010"
    ]
    
    func convert2UPC_A(contents:String) -> String {
        let code = contents.substring(1, length: contents.length() - 2)
        let lastDigit = code[code.length() - 1].toInt()!
        var insertDigits = "0000"
        var upc_a = ""
        switch lastDigit {
        case 0...2:
            upc_a += code.substring(0, length: 2) + String(lastDigit) + insertDigits + code.substring(2, length: 3)
        case 3:lastDigit
        insertDigits = "00000"
        upc_a += code.substring(0, length: 3) + insertDigits + code.substring(3, length: 2)
        case 4:lastDigit
        insertDigits = "00000"
        upc_a += code.substring(0, length: 4) + insertDigits + code.substring(4, length: 1)
        default:
            upc_a += code.substring(0, length: 5) + insertDigits + String(lastDigit)
        }
        return "00" + upc_a
    }
    
    override func isValid(contents: String) -> Bool {
        return super.isValid(contents)
            && contents.length() == 8
            && contents[0].toInt()! == 0
            && contents[contents.length() - 1] == self.checkDigit(contents)
    }
    
    override func initiator() -> String {
        return "101"
    }
    
    override func terminator() -> String {
        return "010101"
    }
    
    override func barcode(contents: String) -> String {
        let checkValue = contents[contents.length() - 1].toInt()!
        let sequence = UPCE_SEQUENCES[checkValue]
        var barcode = ""
        for i in 1..<contents.length() - 1 {
            let digit = contents[i].toInt()!
            if sequence[i - 1].toInt()! % 2 == 0 {
                barcode += UPCE_EVEN_ENCODINGS[digit]
            } else {
                barcode += UPCE_ODD_ENCODINGS[digit]
            }
        }
        return barcode
    }
    
    // MARK: RSCheckDigitGenerator
    
    func checkDigit(contents: String) -> String {
        /*
        UPC-A check digit is calculated using standard Mod10 method. Here outlines the steps to calculate UPC-A check digit:
        
        From the right to left, start with odd position, assign the odd/even position to each digit.
        Sum all digits in odd position and multiply the result by 3.
        Sum all digits in even position.
        Sum the results of step 3 and step 4.
        divide the result of step 4 by 10. The check digit is the number which adds the remainder to 10.
        */
        let upc_a = self.convert2UPC_A(contents)
        var sum_odd = 0
        var sum_even = 0
        for i in 0..<upc_a.length() {
            let digit = upc_a[i].toInt()!
            if i % 2 == 0 {
                sum_even += digit
            } else {
                sum_odd += digit
            }
        }
        return String(10 - (sum_even + sum_odd * 3) % 10)
    }
}
