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
    
    var memoCount = 0 {
        didSet {
            self.title = "\(memoCount)개의 메모"
        }
    }
    
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
        tableView.register(MemoHeader.self, forHeaderFooterViewReuseIdentifier: "header")
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
        memoCount = tasks.count
    }
    

}

//MARK: TableView delegate
extension MemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoTableViewCell.identifier, for: indexPath) as? MemoTableViewCell else {
            return UITableViewCell()
        }
        
        var data = tasks.sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row]
        
        if tasks.isEmpty {
            print("비어있음")
        }
        else if tasks.filter("pinned == false").isEmpty {
            print("고정된 메모만 있음")
            data = tasks.filter("pinned == true").sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row]
        }
        else if tasks.filter("pinned == true").isEmpty {
            print("고정 안된 메모만 있음")
            data = tasks.filter("pinned == false").sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row]
        }
        else {
            print("고정된 메모, 고정 안된 메모 둘 다 있음")
            if indexPath.section == 0 {
                data = tasks.filter("pinned == true").sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row]
            } else {
                data = tasks.filter("pinned == false").sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row]
            }
        }
            
        cell.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        // 타이틀이 개행문자로 인해 비어있을 경우
        if data.title.isEmpty {
            cell.titleLabel.text = "새로운 메모"
        } else {
            cell.titleLabel.text = data.title
        }
        
        // 본문의 내용이 없거나, 개행문자로만 이루어져 있는 경우
        if data.content == nil || data.content!.components(separatedBy: "\n").filter({ $0.isEmpty == false }).isEmpty {
            cell.contentLabel.text = "추가 텍스트 없음"
        } else {
            cell.contentLabel.text = data.content
        }
        
        
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
            print("DEBUG: 고정된 메모 없음")
            return tasks.count
        }
        // 필터된 테이블이 있고, 0번 섹션인 경우(고정된 메모)
        else if tasks.filter("pinned == true").count != 0 && section == 0 {
            print("DEBUG: only pixed memo")
            return tasks.filter("pinned == true").count
        }
        // 필터된 테이블이 있고, 1번 섹션인 경우(메모)
        else if tasks.filter("pinned == true").count != 0 && section == 1 {
            print("DEBUG: only memo")
            return tasks.filter("pinned == false").count
        } else {
            print("DEBUG: 내가 생각하지 못한 경우")
            return tasks.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 필터된 값이 없을 경우
        if tasks.filter("pinned == true").count == 0 {
            print("DEBUG: 필터된 값 없음. 섹션 1개")
            return 1
        }
        // 필터된 값만 있을 경우(고정된 메모만 있는 case)
        else if tasks.filter("pinned == true").count != 0 && tasks.filter("pinned == false").count == 0 {
            print("DEBUG: 필터된 값만 있음. 섹션 1개")
            return 1
        }
        else {
            print("DEBUG: 섹션 2개")
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 고정된 메모일 경우
        if indexPath.section == 0 && !(self.tasks.filter("pinned == true").isEmpty) {
            let pin = UIContextualAction(style: .normal, title: nil) { [weak self](_, _, _) in
                print("고정")
                try! self?.localRealm.write {
                    (self?.tasks.filter("pinned == true").sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row])!.pinned.toggle()
                    tableView.reloadData()
                }
            }
            pin.backgroundColor = .orange
            pin.image = UIImage(systemName: "pin.slash.fill")
            return UISwipeActionsConfiguration(actions: [pin])
        }
        // 고정된 메모가 아닐 경우
        else {
            let pin = UIContextualAction(style: .normal, title: nil) { [weak self](_, _, _) in
                print("고정")
                try! self?.localRealm.write {
                    (self?.tasks.filter("pinned == false").sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row])!.pinned.toggle()
                    tableView.reloadData()
                }
            }
            pin.backgroundColor = .orange
            pin.image = UIImage(systemName: "pin.fill")
            return UISwipeActionsConfiguration(actions: [pin])
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if tableView.numberOfSections > 1 && indexPath.section == 0 {
            let delete = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, _) in
                print("삭제")
                try! self?.localRealm.write {
                    self?.localRealm.delete( (self?.tasks.filter("pinned == true").sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row])! )
                    self?.memoCount -= 1
                    tableView.reloadData()
                }
            }
            delete.backgroundColor = .red
            delete.image = UIImage(systemName: "trash")
            return UISwipeActionsConfiguration(actions: [delete])
        }
        else {
            let delete = UIContextualAction(style: .normal, title: nil) { [weak self] (_, _, _) in
                print("삭제")
                try! self?.localRealm.write {
                    self?.localRealm.delete( (self?.tasks.filter("pinned == false").sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row])! )
                    self?.memoCount -= 1
                    tableView.reloadData()
                }
            }
            delete.backgroundColor = .red
            delete.image = UIImage(systemName: "trash")
            return UISwipeActionsConfiguration(actions: [delete])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? MemoHeader else {
            return nil
        }
        
        // 고정된 메모일 경우
        if section == 0 && !(tasks.filter("pinned == true").isEmpty) {
            header.titleLabel.text = "고정된 메모"
            header.titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        }
        // 고정된 메모가 있고, 일반 메모일 경우
        else if tableView.numberOfSections == 2 && section == 1 {
            header.titleLabel.text = "메모"
            header.titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        }
        // 일반 메모만 있을 경우
        else {
            return nil
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 고정된 메모일 경우
        if section == 0 && !(tasks.filter("pinned == true").isEmpty) {
            return 40
        }
        // 고정된 메모가 있고, 일반 메모일 경우
        else if tableView.numberOfSections == 2 && section == 1 {
            return 40
        }
        // 일반 메모만 있을 경우
        else {
            return 0
        }
    }
}
