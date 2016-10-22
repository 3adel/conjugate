//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class SavedVerbsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    
    var viewModel = SavedVerbViewModel.empty
    
    var presenter: SavedVerbPresenterType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.getSavedVerbs()
    }
    
    func setupPresenter() {
        presenter = SavedVerbPresenter(view: self)
    }
    
    override func setupUI() {
        title = TabBarController.Tab.saved.name
        
        navigationController?.navigationBar.tintColor = Theme.mainTintColor
    }
}


extension SavedVerbsViewController: SavedVerbView {
    func update(with viewModel: SavedVerbViewModel) {
        self.viewModel = viewModel
        tableView.reloadData()
    }
}


extension SavedVerbsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.verbs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SavedVerbCell") as? SavedVerbCell else { return UITableViewCell() }
        
        let cellViewModel = viewModel.verbs[indexPath.row]
        cell.update(with: cellViewModel)
        
        return cell
    }
}


class SavedVerbCell: UITableViewCell {
    static let identifier = "SavedVerbCell"
    
    func update(with viewModel: SavedVerbCellViewModel) {
        textLabel?.text = viewModel.verb
        detailTextLabel?.text = viewModel.meaning
    }
}