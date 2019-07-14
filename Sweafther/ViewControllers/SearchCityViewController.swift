//
//  SearchCityViewController.swift
//  Sweafther
//
//  Created by Agnieszka Niewiadomski on 10/07/2019.
//  Copyright © 2019 niewia_a. All rights reserved.
//

import UIKit
import os.log

protocol SearchCityTableViewDelegate: AnyObject {
    func didSelectedNewCity(_ newCity: String)
}

class SearchCityViewController: UIViewController {

    let cityService = CityService()
    
    var cityNameArr = [String]()
    var searchedCity = [String]()
    var searching = false
    
    weak var delegate: SearchCityTableViewDelegate?

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cityTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        cityService.getCities { (cities) in
            self.cityNameArr = cities
            self.cityTableView.reloadData()
        }
    }
}

extension SearchCityViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedCity.count
        } else {
            return cityNameArr.count

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell Result")
        if searching {
            cell?.textLabel?.text = searchedCity[indexPath.row]
        } else {
            cell?.textLabel?.text = cityNameArr[indexPath.row]
        }

        return cell!
    }
}

extension SearchCityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("cell clicked \(indexPath.row)")
        
        if searching {
            delegate?.didSelectedNewCity(searchedCity[indexPath.row])
        } else {
            delegate?.didSelectedNewCity(cityNameArr[indexPath.row])
        }
    }
}

extension SearchCityViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedCity = cityNameArr.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        cityTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        cityTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
