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
    
    @objc func soundButtonClicked(_ button: UIButton) {
        let location = tableView.convert(button.center, from: button.superview)
        guard let indexPath = tableView.indexPathForRow(at: location) else { return }
        
        let tense = viewModel.tenses[indexPath.section].forms[indexPath.row]
        
        if speaker.isPlaying(tense.audioText) {
            speaker.stop()
        } else {
            speaker.play(tense.audioText)
        }

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
        
        cell.audioButton.addTarget(self, action: #selector(soundButtonClicked(_:)), for: .touchUpInside)
        
        let tense = viewModel.tenses[indexPath.section].forms[indexPath.row]
        
        cell.setup(with: tense)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.tenses[section].name
    }
}

class TenseTableViewCell: UITableViewCell {
    static let identifier = "tenseCell"
    static let nib = "TenseTableViewCell"
    
    @IBOutlet var pronounLabel: UILabel!
    @IBOutlet var verbLabel: UILabel!
    @IBOutlet var audioButton: UIButton!
    
    func setup(with viewModel: FormViewModel) {
        pronounLabel.text = viewModel.pronoun
        verbLabel.text = viewModel.verb
        
        let textColor = UIColor(red: CGFloat(viewModel.textColor.0), green: CGFloat(viewModel.textColor.1), blue: CGFloat(viewModel.textColor.2), alpha: 1.0)
        verbLabel.textColor = textColor
        pronounLabel.textColor = textColor
        
        audioButton.isHidden = viewModel.audioImageHidden
        
        selectionStyle = .none
    }
}
