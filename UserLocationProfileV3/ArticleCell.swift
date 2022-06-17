//
//  ArticleCellTableViewCell.swift
//  UserLocationProfileV3
//
//  Created by Jo Eun Kim on 6/15/22.
//

import UIKit

class ArticleCell: UITableViewCell {
    
    @IBOutlet weak var sourceName: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var publishDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
