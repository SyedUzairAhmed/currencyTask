
//
//  MainScreenVC.swift
//  CurrencyConvertor
//
//  Created by Syed Uzair Ahmed on 15/11/2017.
//  Copyright © 2017 Syed Uzair Ahmed. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper



class MainScreenVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    var currencyObj:CurrencyModel?
    var countrysCurrncyUnits : [[String:Double]] = []
    var countrysCurrncyValue: [Double] = []
    var aFilteredCountryList : [String] = []
    var filteredData: [[String:Double]]!
    var timerForRefresh:Timer?
    var searchController: UISearchController!
    @IBOutlet var tblCountries: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getRates()
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        tblCountries.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        self.tblCountries.addSubview(self.refreshControl)
        
    }
    
    // MARK: - Utility Methods
    
    private func updateUI(){
        tblCountries.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text {
            self.filteredData = searchText.isEmpty ? self.countrysCurrncyUnits : self.countrysCurrncyUnits.filter({
                return $0.keys.first!.lowercased().range(of:searchText.lowercased()) != nil
            })
            
            tblCountries.reloadData()
        }
    }
    public func showActivityIndicator() {
        customActivityIndicatory(self.view, startAnimate: true)
    }
    
    public func hideActivityIndicator() {
        customActivityIndicatory(self.view, startAnimate: false)
    }
    
    func scheduledTimerWithTimeInterval(){
        timerForRefresh = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.getRates), userInfo: nil, repeats: true)
    }

    
    
    
    // MARK: -  Pull to Refresh
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh),for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.gray
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getRates()
        refreshControl.endRefreshing()
    }
    
    
    
    // MARK: - TableView Delegate / DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.filteredData?.count{
            if count > 0 {
                return count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let aCell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTableViewCell") as? CurrencyTableViewCell {
            var dic  = self.filteredData[indexPath.row]
            for (key,value) in dic{
                aCell.lblTitle.text = key
                aCell.lblValue.text = "\(value)"
            }
            return aCell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let cell = tableView.cellForRow(at: indexPath) as! CurrencyTableViewCell
        let value:String?
        value = cell.lblTitle.text
        print(value)
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsVC
        
        secondViewController.strSymbol = cell.lblTitle.text
        secondViewController.strValue = cell.lblValue.text
        self.navigationController?.pushViewController(secondViewController, animated: true)

        

    }
    
    // MARK: - API CALL
    
    @objc private func getRates(){
        
        showActivityIndicator()
        
        Alamofire.request("https://api.fixer.io/latest?base=MYR").responseObject { (response: DataResponse<CurrencyModel>) in
            
            self.hideActivityIndicator()
            
            if response.response?.statusCode == 200 {
                self.currencyObj = response.result.value
                
                if let rates = self.currencyObj?.rates.sorted(by: { $0.0 < $1.0 }) {
                    self.countrysCurrncyUnits =  Array(rates.flatMap(){ dic in
                        var dict : [String : Double] = [dic.key:dic.value]
                        return dict
                    })
                    
                }
                
                self.filteredData = self.countrysCurrncyUnits
            }
            self.scheduledTimerWithTimeInterval()
            self.updateUI()
        }
    }
}
