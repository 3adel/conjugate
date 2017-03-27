//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class TenseTableViewDataSource: NSObject {
    let tableView: UITableView
    
    var language: Language? {
        didSet {
            guard let language = language else { return }
            speaker = TextSpeaker(language: language)
            speaker.delegate = self
        }
    }
    
    var speaker = TextSpeaker(language: AppDependencyManager.shared.languageConfig.selectedConjugationLanguage)
    
    var viewModel = TenseTabViewModel.empty {
        didSet {
            tableView.reloadData()
        }
    }
    
    var onRowDidSelect: ((_ row: Int, _ section: Int) -> ())?
    
    var playedAudioButton: AnimatedButton?
    var edgeInsetsForCell = UIEdgeInsetsMake(0, 7, 0, 0)
    
    init(tableView: UITableView) {
        self.tableView = tableView
        
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: TenseTableViewCell.nib, bundle: Bundle.main), forCellReuseIdentifier: TenseTableViewCell.identifier)
        tableView.cellLayoutMarginsFollowReadableWidth = false
        
        speaker.delegate = self
    }
    
    
    @objc func soundButtonClicked(_ button: UIButton) {
        let location = tableView.convert(button.center, from: button.superview)
        guard let indexPath = tableView.indexPathForRow(at: location),
            let animatedButton = button as? AnimatedButton else { return }
        
        // If the clicked button is already playing don't do anything
        guard playedAudioButton !== animatedButton else { return }
        
        //Stop animating the previous played sound button
        playedAudioButton?.stopAnimating()
        
        playedAudioButton = animatedButton
        let tense = viewModel.tenses[indexPath.section].forms[indexPath.row]
        
        if speaker.isPlaying(tense.audioText) {
            speaker.stop()
            speaker.play(tense.audioText)
        } else {
            speaker.play(tense.audioText)
        }
    }
}

extension TenseTableViewDataSource: TextSpeakerDelegate {
    func speakerDidStartPlayback(for text: String) {
        playedAudioButton?.startAnimating()
    }
    
    func speakerDidFinishPlayback(for text: String) {
        playedAudioButton?.stopAnimating()
        playedAudioButton = nil
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
        guard let cell = cellFor(section: indexPath.section, row: indexPath.row) else { return UITableViewCell() }
        
        return cell
    }
    
    func cellFor(section: Int, row: Int) -> TenseTableViewCell? {
         let cell = tableView.dequeueReusableCell(withIdentifier: TenseTableViewCell.identifier) as? TenseTableViewCell
        cell?.audioButton.addTarget(self, action: #selector(soundButtonClicked(_:)), for: .touchUpInside)
        
        let tense = viewModel.tenses[section].forms[row]
        
        cell?.render(with: tense)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.tenses[section].name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onRowDidSelect?(indexPath.row, indexPath.section)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = edgeInsetsForCell
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = edgeInsetsForCell
        }
    }
}

class TenseTableViewCell: UITableViewCell {
    static let identifier = "tenseCell"
    static let nib = "TenseTableViewCell"
    
    @IBOutlet var pronounLabel: UILabel!
    @IBOutlet var verbLabel: UILabel!
    @IBOutlet var audioButton: AnimatedButton!
    
    override func awakeFromNib() {
        setupUI()
    }
    
    func setupUI() {
        audioButton.defaultImage = UIImage(named: "speaker")
        audioButton.images = [#imageLiteral(resourceName: "speaker_1"), #imageLiteral(resourceName: "speaker"), #imageLiteral(resourceName: "speaker_3")]
    }
    
    func render(with viewModel: FormViewModel) {
        pronounLabel.text = viewModel.pronoun
        verbLabel.text = viewModel.verb
        
        let textColor = UIColor(red: CGFloat(viewModel.textColor.0), green: CGFloat(viewModel.textColor.1), blue: CGFloat(viewModel.textColor.2), alpha: 1.0)
        verbLabel.textColor = textColor
        pronounLabel.textColor = textColor
        
        audioButton.isHidden = viewModel.audioImageHidden
    }
}
