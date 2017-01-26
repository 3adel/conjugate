//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class SavedVerbsViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var noVerbsLabel: UILabel!
    @IBOutlet var noVerbsImageView: UIImageView!
    
    var viewModel = SavedVerbViewModel.empty
    
    var presenter: SavedVerbPresenterType!
    
    var alertHandler: AlertHandler?
    
    var previewDelegate: SavedVerbPreviewingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupUI()
        
        previewDelegate = SavedVerbPreviewingDelegate(tableView: tableView, getVerbDetailView: { index in
            return self.presenter.getVerbDetailView(at: index) as? VerbDetailViewController
        },
                                                      openVerbDetail: presenter.openVerbDetails)
        if let previewDelegate = previewDelegate {
            registerForPreviewing(with: previewDelegate, sourceView: tableView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.getSavedVerbs()
    }
    
    func setupPresenter() {
        presenter = SavedVerbPresenter(view: self)
    }
    
    override func setupUI() {
        navigationController?.navigationBar.tintColor = Theme.mainTintColor
        tableView.tableFooterView = UIView()
        alertHandler = AlertHandler(view: view, topLayoutGuide: topLayoutGuide, bottomLayoutGuide: bottomLayoutGuide)
        
        noVerbsLabel.text = ConjugateError.noSavedVerbs.localizedDescription
    }
}


extension SavedVerbsViewController: SavedVerbView {
    func update(with viewModel: SavedVerbViewModel) {
        self.viewModel = viewModel
        tableView.reloadSections([0], with: .automatic)
        
        tableView.isHidden = !viewModel.showVerbsList
        noVerbsLabel.isHidden = !viewModel.showNoSavedVerbMessage
        noVerbsImageView.isHidden = noVerbsLabel.isHidden
    }
    
    func show(successMessage: String) {
        alertHandler?.show(succesMessage: successMessage)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.openVerbDetails(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteVerb(at: indexPath.row)
        }
    }
}


class SavedVerbPreviewingDelegate: NSObject, UIViewControllerPreviewingDelegate {
    let tableView: UITableView
    let getVerbDetailView: (_: Int) -> VerbDetailViewController?
    let openVerbDetail: (_: Int) -> ()
    
    var index = 0
    
    
    init(tableView: UITableView, getVerbDetailView: @escaping (_: Int) -> VerbDetailViewController?, openVerbDetail: @escaping (_: Int) -> ()) {
        self.tableView = tableView
        self.getVerbDetailView = getVerbDetailView
        self.openVerbDetail = openVerbDetail
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
        
        index = indexPath.row
        return getVerbDetailView(index)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        previewingContext.sourceRect = tableView.rectForRow(at: IndexPath(row: index, section: 0))
        openVerbDetail(self.index)
    }

}

class SavedVerbCell: UITableViewCell {
    static let identifier = "SavedVerbCell"
    
    func update(with viewModel: SavedVerbCellViewModel) {
        textLabel?.text = viewModel.verb
        detailTextLabel?.text = viewModel.meaning
    }
}
