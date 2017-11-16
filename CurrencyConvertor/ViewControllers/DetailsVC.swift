//
//  DetailsVC.swift
//  CurrencyConvertor
//
//  Created by Syed Uzair Ahmed on 16/11/2017.
//  Copyright © 2017 Syed Uzair Ahmed. All rights reserved.
//

import UIKit
import Charts
import Alamofire
import AlamofireObjectMapper

class DetailsVC: UIViewController , ChartViewDelegate {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblValue: UILabel!
    @IBOutlet var viewCharts: BarChartView!
    var currencyObj:CurrencyModel?
    var countrysCurrncyValue: [Double] = []
    var arrValues = [Any]()
    var arrDoubles : [Double]?
    var strSymbol:String?
    var strValue:String?
    
    var months: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = strSymbol
        lblValue.text = strValue
        self.getRates()
        
       // self.setupGraph()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions Methods

    @IBAction func backPressed(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
    // MARK: - Setting Up Graph

    private func setupGraph() {
       
        months = ["1", "2", "3", "4", "5", "6", "7"]
       
        viewCharts.delegate = self;
        viewCharts.chartDescription?.enabled = false;

        viewCharts.pinchZoomEnabled = false;
        viewCharts.drawBarShadowEnabled = false;
        viewCharts.drawGridBackgroundEnabled = false;

        // Disable User Touch Events on Garph
        viewCharts.isUserInteractionEnabled = false

        // lines disable
        viewCharts.leftAxis.drawGridLinesEnabled = false
        viewCharts.rightAxis.drawGridLinesEnabled = false

        // xAxis Gridlines disable and Position bottom
        viewCharts.xAxis.labelPosition = .bottom
        viewCharts.xAxis.drawGridLinesEnabled = false

        // right and left values disable
        viewCharts.rightAxis.enabled = false
        viewCharts.leftAxis.enabled = false

        // X axis Values
        viewCharts.xAxis.granularity = 1
        
        self.setChartData()

    }
        private func setChartData() {
            
            let unitsSold = self.arrValues
            
            let test = [1, 2, 3, 4, 5, 6, 7]
            
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 0..<months.count
            {
                let dataEntry = BarChartDataEntry(x: Double(test[i]), y: Double(unitsSold[i] as! Double))
                
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Visitor count")
            let chartData = BarChartData(dataSet: chartDataSet)
            
            viewCharts.data = chartData
    }
    
    // MARK: - Utility Methods
    
    public func showActivityIndicator() {
        customActivityIndicatory(self.view, startAnimate: true)
    }
    
    public func hideActivityIndicator() {
        customActivityIndicatory(self.view, startAnimate: false)
    }
    
    // MARK: - API CALL
    
    @objc private func getRates(){
        
        showActivityIndicator()
        
        var requestCallNumber = 0
        
        for i in 0...7{
            
            print(i)
            
            let yesterday = Calendar.current.date(byAdding: .day, value: -i, to: Date())
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let result = formatter.string(from: yesterday!)

            print(result)
            
            Alamofire.request("https://api.fixer.io/\(result)?symbols=\(strSymbol!)&base=MYR").responseObject { (response: DataResponse<CurrencyModel>) in
//                 Alamofire.request("https://api.fixer.io/\(result)?symbols=USD&base=MYR").responseObject { (response: DataResponse<CurrencyModel>) in
                self.hideActivityIndicator()

                if response.response?.statusCode == 200 {
                    self.currencyObj = response.result.value
                    requestCallNumber += 1
                    if let rates = self.currencyObj?.rates {
                        self.countrysCurrncyValue = Array(rates.flatMap(){ $0.1 })
                        let value = self.countrysCurrncyValue
                        self.arrValues.append(value[0])
                        if requestCallNumber == 7 {
                            self.setupGraph()
                        }
                    }
                }
        }
            }
        }
}
