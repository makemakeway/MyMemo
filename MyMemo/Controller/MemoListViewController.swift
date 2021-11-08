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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    

}

//MARK: TableView delegate
extension MemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoTableViewCell.identifier, for: indexPath) as? MemoTableViewCell else {
            return UITableViewCell()
        }
        
        var data = tasks.filter("pinned == false")[indexPath.row]
        
        if tableView.numberOfSections > 1 && indexPath.section == 0 {
            data = tasks.filter("pinned == true")[indexPath.row]
        }
        
        cell.titleLabel.text = data.title
        cell.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        cell.contentLabel.text = data.content
        cell.contentLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        cell.contentLabel.textColor = .lightGray
        
        cell.dateLabel.text = DateFormatter().dateToString(date: data.writtenDate)
        cell.dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        cell.dateLabel.textColor = .lightGray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 필터된 테이블이 없는 경우
        if tasks.filter("pinned == true").count == 0 {
            return tasks.count
        }
        // 필터된 테이블이 있고, 0번 섹션인 경우(고정된 메모)
        else if section == 0 {
            return tasks.filter("pinned == true").count
        }
        // 필터된 테이블이 있고, 1번 섹션인 경우(메모)
        else {
            return tasks.filter("pinned == false").count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.filter("pinned == true").count == 0 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let pin = UIContextualAction(style: .normal, title: nil) { [weak self](_, _, _) in
            print("고정")
            try! self?.localRealm.write {
                (self?.tasks[indexPath.row])!.pinned.toggle()
                tableView.reloadData()
            }
        }
        pin.backgroundColor = .orange

        if tableView.numberOfSections > 1 && indexPath.section == 0 {
            pin.image = UIImage(systemName: "pin.slash.fill")
        } else {
            pin.image = UIImage(systemName: "pin.fill")
        }
        
        return UISwipeActionsConfiguration(actions: [pin])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, _) in
            print("삭제")
            try! self?.localRealm.write {
                self?.localRealm.delete( (self?.tasks[indexPath.row])! )
                tableView.reloadData()
            }
        }
        delete.backgroundColor = .red
        delete.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
