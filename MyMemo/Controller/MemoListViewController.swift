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
            self.title = "\(NumberFormatter.numberToString(num: memoCount))개의 메모"
        }
    }
    
    var searching = false
    
    var searchText = "" {
        didSet {
            print(searchText)
            if searchText.isEmpty {
                self.tasks = localRealm.objects(Memo.self)
                tableView.reloadData()
                return
            } else {
                self.tasks = localRealm.objects(Memo.self).filter("title CONTAINS[c] '\(searchText)' OR content CONTAINS[c] '\(searchText)'")
                tableView.reloadData()
            }
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
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.autocapitalizationType = .none
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        
        self.navigationItem.searchController = searchController
    }
    
    func navBarConfig() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        title = "메모"
    }
    
    func presentUpdateMemoViewController(memo: Memo?) {
        
        guard let memo = memo else {
            let sb = UIStoryboard(name: "Update", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "UpdateMemoViewController")
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        let sb = UIStoryboard(name: "Update", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "UpdateMemoViewController") as! UpdateMemoViewController
        
        vc.memo = memo
        
        if !(searchText.isEmpty) || searching {
            self.navigationItem.backButtonTitle = "검색"
        } else {
            self.navigationItem.backButtonTitle = "\(NumberFormatter.numberToString(num: memoCount))개의 메모"
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
        return
    }
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        presentUpdateMemoViewController(memo: nil)
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
        
        self.memoCount = localRealm.objects(Memo.self).count
    }
    
    override func viewDidLayoutSubviews() {
        if Core.shared.isNewUser() {
            // 첫 화면 보여주기
            let sb = UIStoryboard.init(name: "Tutorial", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.layoutIfNeeded()
    }
    
    

}

//MARK: TableView delegate
extension MemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoTableViewCell.identifier, for: indexPath) as? MemoTableViewCell else {
            return UITableViewCell()
        }
        
        var data = tasks.sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row]
        
        if !(searchText.isEmpty) {
            data = tasks.sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row]
        }
        else {
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
        }
        
        cell.titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        cell.contentLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        cell.contentLabel.textColor = .lightGray
        
        cell.dateLabel.text = DateFormatter().dateToString(date: data.writtenDate)
        cell.dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        cell.dateLabel.textColor = .lightGray
        
        
        // 타이틀이 개행문자로 인해 비어있을 경우
        if data.title.isEmpty {
            cell.titleLabel.text = "새로운 메모"
        } else {
            // 검색하고 있는 경우
            if !(searchText.isEmpty) {
                let title = data.title.components(separatedBy: "\n").filter({ $0.isEmpty == false }).first!
                
                let attStr = NSMutableAttributedString(string: title)
                
                attStr.addAttribute(.foregroundColor, value: UIColor.orange, range: (title as NSString).range(of: searchText))
                
                cell.titleLabel.attributedText = attStr
                
                print("debug: \(attStr)")
            }
            else {
                cell.titleLabel.text = data.title.components(separatedBy: "\n").filter({ $0.isEmpty == false }).first!
            }
            
        }
        
        // 본문의 내용이 없거나, 개행문자로만 이루어져 있는 경우
        if data.content == nil || data.content!.components(separatedBy: "\n").filter({ $0.isEmpty == false }).isEmpty {
            cell.contentLabel.text = "추가 텍스트 없음"
        } else {
            if !(searchText.isEmpty) {
                let text = data.content!.components(separatedBy: "\n").filter({ $0.isEmpty == false }).joined(separator: "\n")
                
                let attStr = NSMutableAttributedString(string: text)
                
                attStr.addAttribute(.foregroundColor, value: UIColor.orange, range: (text as NSString).range(of: searchText))
                
                cell.contentLabel.attributedText = attStr
            }
            else {
                let text = data.content!.components(separatedBy: "\n").filter({ $0.isEmpty == false }).first!
                cell.contentLabel.text = text
            }
            
        }
        

        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !(searchText.isEmpty) {
            return tasks.count
        }
        else {
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
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // 필터된 값이 없을 경우
        if tasks.filter("pinned == true").count == 0 || !(searchText.isEmpty) {
            return 1
        }
        // 필터된 값만 있을 경우(고정된 메모만 있는 case)
        else if tasks.filter("pinned == true").count != 0 && tasks.filter("pinned == false").count == 0 {
            return 1
        }
        else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !(searchText.isEmpty) {
            let data = tasks.sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row]
            presentUpdateMemoViewController(memo: data)
        }
        else {
            if indexPath.section == 0 && !(self.tasks.filter("pinned == true").isEmpty) {
                let data = tasks.filter("pinned == true").sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row]
                presentUpdateMemoViewController(memo: data)
            }
            else {
                let data = tasks.filter("pinned == false").sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row]
                presentUpdateMemoViewController(memo: data)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 고정된 메모일 경우
        if indexPath.section == 0 && !(self.tasks.filter("pinned == true").isEmpty) {
            let pin = UIContextualAction(style: .normal, title: nil) { [weak self](_, _, _) in
                print("고정해제")

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
                if (self?.tasks.filter("pinned == true").count)! >= 5 {
                    let alert = UIAlertController(title: nil, message: "메모는 5개까지만 고정할 수 있습니다.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(ok)
                    self?.present(alert, animated: true, completion: nil)
                    return
                }
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
    
    func isPinned(indexPath: IndexPath) -> Bool {
        
        if !(self.tasks.filter("pinned == true").isEmpty) && indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    func deleteMemoData(state: String, indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "메모를 삭제하시겠습니까?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "예", style: .default) { _ in
            try! self.localRealm.write {
                self.localRealm.delete( (self.tasks.filter("pinned == \(state)").sorted(byKeyPath: "writtenDate", ascending: false)[indexPath.row]) )
                self.memoCount -= 1
                self.tableView.reloadData()
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 고정된 메모
        if isPinned(indexPath: indexPath) {
            let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
                
                self?.deleteMemoData(state: "true", indexPath: indexPath)
                completion(true)
            }
            delete.image = UIImage(systemName: "trash")
            return UISwipeActionsConfiguration(actions: [delete])
        }
        // 일반 메모
        else {
            let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
                
                self?.deleteMemoData(state: "false", indexPath: indexPath)
                completion(true)
            }
            delete.image = UIImage(systemName: "trash")
            return UISwipeActionsConfiguration(actions: [delete])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? MemoHeader else {
            return nil
        }
        
        if !(searchText.isEmpty) {
            if self.tasks.count != 0 {
                header.titleLabel.text = "\(self.tasks.count)개 찾음"
            }
            else {
                header.titleLabel.text = "일치하는 항목이 없습니다."
            }
        }
        else {
            // 고정된 메모일 경우
            if section == 0 && !(tasks.filter("pinned == true").isEmpty) {
                header.titleLabel.text = "고정된 메모"
            }
            // 고정된 메모가 있고, 일반 메모일 경우
            else if tableView.numberOfSections == 2 && section == 1 {
                header.titleLabel.text = "메모"
            }
            // 일반 메모만 있을 경우
            else {
                return nil
            }
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if !(searchText.isEmpty) {
            return 40
        }
        else {
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("스크롤")
        
        if self.navigationItem.searchController!.searchBar.text!.isEmpty {
            searching = false
        }
        self.navigationItem.searchController?.searchBar.resignFirstResponder()
    }
    
}


//MARK: SearchController extension

extension MemoListViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else {
            return
        }
        
        self.searchText = text
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text!.isEmpty {
            searching = false
        }
        searchBar.resignFirstResponder()
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searching = true
        return true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
    }
    
    
}
