//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class TenseTableViewDataSource: NSObject {
    let tableView: UITableView
    
    let speaker = TextSpeaker(locale: Locale(identifier: "de_DE"))
    
    var viewModel = TenseTabViewModel.empty {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
        
        super.init()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib.init(nibName: TenseTableViewCell.nib, bundle: Bundle.main), forCellReuseIdentifier: TenseTableViewCell.identifier)
    }
}

extension TenseTableViewDataSource: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.tenses.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tense = viewModel.tenses[section]
        
        return tense.forms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TenseTableViewCell.identifier) as? TenseTableViewCell else { return UITableViewCell() }
        
        let tense = viewModel.tenses[indexPath.section].forms[indexPath.row]
        
        cell.setup(with: tense)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.tenses[section].name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tense = viewModel.tenses[indexPath.section].forms[indexPath.row]
        
        let text = tense.pronoun + " " + tense.verb
        
        if speaker.isPlaying(text) {
            speaker.stop()
        } else {
            speaker.play(text)
        }
    }
}

class TenseTableViewCell: UITableViewCell {
    static let identifier = "tenseCell"
    static let nib = "TenseTableViewCell"
    
    @IBOutlet var pronounLabel: UILabel!
    @IBOutlet var verbLabel: UILabel!
    @IBOutlet var audioImageView: UIImageView!
    
    func setup(with viewModel: FormViewModel) {
        pronounLabel.text = viewModel.pronoun
        verbLabel.text = viewModel.verb
        
        let textColor = UIColor(red: CGFloat(viewModel.textColor.0), green: CGFloat(viewModel.textColor.1), blue: CGFloat(viewModel.textColor.2), alpha: 1.0)
        verbLabel.textColor = textColor
        pronounLabel.textColor = textColor
        
        audioImageView.isHidden = viewModel.audioImageHidden
        
        selectionStyle = .none
    }
}
