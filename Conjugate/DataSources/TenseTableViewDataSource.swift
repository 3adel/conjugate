//
//  Copyright © 2016 Adel  Shehadeh. All rights reserved.
//

import UIKit

class TenseTableViewDataSource: NSObject {
    let tableView: UITableView
    
    var shouldShowPromotion = !UserDefaults.standard.didShowDerSatzPromotion {
        didSet {
            promotionSectionIndex = shouldShowPromotion ? 2 : nil
        }
    }
    lazy var promotionSectionIndex: Int? = {
        shouldShowPromotion ? 2 : nil
    }()
    
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
        tableView.register(UINib(nibName: TenseTableViewCell.Nib, bundle: Bundle.main), forCellReuseIdentifier: TenseTableViewCell.Identifier)
        tableView.register(UINib(nibName: DerSatzPromotionCell.Nib, bundle: Bundle.main), forCellReuseIdentifier: DerSatzPromotionCell.Identifier)
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
        let tense = viewModel.tenses[adjustedSection(indexPath.section)].forms[indexPath.row]
        
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
        guard viewModel.tenses.count > 3 else { return 0 }
        return promotionSectionIndex == nil ? viewModel.tenses.count : viewModel.tenses.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard promotionSectionIndex != section else { return 1 }
        
        let tense = viewModel.tenses[adjustedSection(section)]
        
        return tense.forms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = cellFor(section: indexPath.section, row: indexPath.row) else { return UITableViewCell() }
        
        return cell
    }
    
    func cellFor(section: Int, row: Int) -> UITableViewCell? {
        if let promotionSectionIndex = promotionSectionIndex,
            promotionSectionIndex == section {
            let cell = tableView.dequeueReusableCell(withIdentifier: DerSatzPromotionCell.Identifier) as? DerSatzPromotionCell
            
            cell?.onDismissButtonTap = { [weak self] in
                guard let promotionSectionIndex = self?.promotionSectionIndex else { return }
                self?.shouldShowPromotion = false
                self?.tableView.deleteSections([promotionSectionIndex], with: .automatic)
            }
            
            cell?.onInstallNowTap = {
                guard let url = URL(string: "itms-apps://itunes.apple.com/app/id1163600729") else { return }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            UserDefaults.standard.didShowDerSatzPromotion = true
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TenseTableViewCell.Identifier) as? TenseTableViewCell
            cell?.audioButton.addTarget(self, action: #selector(soundButtonClicked(_:)), for: .touchUpInside)
            
            let tense = viewModel.tenses[adjustedSection(section)].forms[row]
            
            cell?.render(with: tense)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == promotionSectionIndex ? nil : viewModel.tenses[adjustedSection(section)].name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard promotionSectionIndex != indexPath.section else { return }
            
        onRowDidSelect?(indexPath.row, adjustedSection(indexPath.section))
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return promotionSectionIndex == indexPath.section ? 195 : 44
    }
    
    private func adjustedSection(_ section: Int) -> Int {
        guard let promotionSectionIndex = promotionSectionIndex else { return section }
        return promotionSectionIndex <=  section ? section - 1 : section
    }
}

class TenseTableViewCell: UITableViewCell {
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
