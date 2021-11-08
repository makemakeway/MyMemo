//
//  MemoListViewController.swift
//  MyMemo
//
//  Created by 박연배 on 2021/11/08.
//

import UIKit

class MemoListViewController: UIViewController {

    
    //MARK: Property
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    
    //MARK: Method
    func tableViewConfig() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: MemoTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: MemoTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func searchControllerConfig() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "검색"
        searchController.searchBar.image(for: .search, state: .normal)
        for view in searchController.searchBar.subviews {
            print(view)
        }
        
        self.navigationItem.searchController = searchController
    }
    
    func navBarConfig() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        title = "메모"
    }
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        
    }
    
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchControllerConfig()
        navBarConfig()
        tableViewConfig()
    }
    
    

}

extension MemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoTableViewCell.identifier, for: indexPath) as? MemoTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}
