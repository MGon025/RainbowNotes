//
//  NoteDetailViewController.swift
//  iNote
//
//  Created by Mark Gonzalez on 5/15/21.
//

import UIKit

class NoteDetailViewController: UIViewController {
    @IBOutlet var noteTitle: UITextField!
    @IBOutlet var noteText: UITextView!
    var currNote: Note!
    var currIndex: Int!

    // toggles editing of the note's contents
    @objc func toggleEditMode(sender: Any?) {
        if noteTitle.isEnabled == false {
            noteTitle.isEnabled = true
            noteText.isEditable = true

            // set right nav bar item to Done
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toggleEditMode))
            return
        }
        // else save new data & disable editing

        // check if data is available
        guard let newTitle = noteTitle.text,
              let newText = noteText.text
        else {
            let msg = "nil values"
            errorPopUp(sender: self, title: "ERROR", message: msg)
            print(msg)
            return
        }

        guard newTitle != "" else {
            let msg = "Please enter a title"
            errorPopUp(sender: self, title: "ERROR", message: msg)
            print(msg)
            return
        }

        // if new title is different from old, check if it's valid
        if newTitle != currNote.title {
            guard notepad.titleIsValid(newTitle) else {
                let msg = "Title already exists"
                errorPopUp(sender: self, title: "ERROR", message: msg)
                print(msg)
                return
            }
        }

        // add note to notepad if it's new
        if currNote.title == "" {
            notepad.addNote(currNote)
        }

        currNote.title = newTitle
        currNote.text = newText

        // attempt to save notepad data
        if !notepad.saveNotes() {
            let msg = "could not save to Documents"
            errorPopUp(sender: self, title: "Error", message: msg)
            print(msg)
        }

        noteTitle.isEnabled = false
        noteText.isEditable = false

        // set right nav bar item to Edit
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditMode))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditMode))

        noteTitle.text = currNote.title
        noteText.text = currNote.text

        // rainbow mode
        if rtx {
            noteTitle.backgroundColor = rainbow[currIndex % rainbow.count].withAlphaComponent(0.5)
            noteText.backgroundColor = rainbow[currIndex % rainbow.count].withAlphaComponent(0.25)
        }

        // immediately toggle edit mode if new note
        if currNote.title == "" {
            toggleEditMode(sender: nil)
        }
    }
}
