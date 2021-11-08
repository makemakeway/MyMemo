//
//  MemoListViewController.swift
//  MyMemo
//
//  Created by 박연배 on 2021/11/08.
//

import UIKit
import RealmSwift

class MemoListViewController: UIViewController {

    
    //MARK: Property
    
    var localRealm = try! Realm()
    
    var tasks: Results<Memo>!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    //MARK: Method
    func addButtonConfig() {
        addButton.image = UIImage(systemName: "square.and.pencil")
        addButton.tintColor = UIColor.orange
        addButton.title = nil
    }
    
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
    
    func presentUpdateMemoViewController() {
        let sb = UIStoryboard(name: "Update", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "UpdateMemoViewController")
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        presentUpdateMemoViewController()
    }
    
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tasks = localRealm.objects(Memo.self)
        searchControllerConfig()
        navBarConfig()
        tableViewConfig()
        addButtonConfig()
        
        
    }
    
    

}

//MARK: TableView delegate
extension MemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoTableViewCell.identifier, for: indexPath) as? MemoTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
