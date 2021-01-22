//
//  ToolbarPickerView.swift
//  HeltonHeltonLyanRicardo
//
//  Created by Lyan Masterson on 21/01/21.
//

import Foundation
import UIKit

protocol ToolbarPickerViewDelegate: class {
    func didTapDone(tag: Int)
    func didTapCancel(tag: Int)
}

class ToolbarPickerView: UIPickerView {

    public private(set) var toolbar: UIToolbar?
    weak var toolbarDelegate: ToolbarPickerViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Confirmar",
                                         style: .plain, target: self, action: #selector(self.doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancelar",
                                           style: .plain, target: self, action: #selector(self.cancelTapped))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        self.toolbar = toolBar
    }

    @objc func doneTapped() {
        self.toolbarDelegate?.didTapDone(tag: self.tag)
    }

    @objc func cancelTapped() {
        self.toolbarDelegate?.didTapCancel(tag: self.tag)
    }
}
