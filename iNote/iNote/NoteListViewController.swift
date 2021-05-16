//
//  NoteListViewController.swift
//  iNote
//
//  Created by Mark Gonzalez on 5/15/21.
//

import UIKit

let notepad = Notepad()
let rainbow: [UIColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemIndigo, .systemPurple]

// can be called by any view controller to show an error pop up
func errorPopUp(sender: UIViewController, title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
    alertController.addAction(alertAction)
    sender.present(alertController, animated: true)
}

class NoteListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    // toggles editing of the table view
    @objc func toggleEditMode(sender: Any?) {
        if tableView.isEditing == false {
            tableView.isEditing = true
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(toggleEditMode))
            navigationItem.rightBarButtonItems![0] = done
        } else {
            tableView.isEditing = false
            let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditMode))
            navigationItem.rightBarButtonItems![0] = edit

            if !notepad.saveNotes() {
                let msg = "could not save to Documents"
                errorPopUp(sender: self, title: "ERROR", message: msg)
                print(msg)
            }
        }
    }

    // attempt to append a new note to the end of the table view
    // the note is successfully appended if the user edits it to be a valid note in the detailed view
    @objc func addNote(_ sender: Any?) {
        let index = IndexPath(row: notepad.noteList.count-1, section: 0)
        tableView(tableView, commit: .insert, forRowAt: index)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // set right nav bar items
        let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(toggleEditMode))
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        navigationItem.rightBarButtonItems = [edit, add]

        tableView.delegate = self
        tableView.dataSource = self

        navigationItem.title = "iNote"

        // attempt to load Notes.plist else create a new one
        guard notepad.loadNotes() else {
            print("creating Notes.plist")

            let features = """
            Features:
                - swipe left on any note to delete it
                - press the edit button to move or delete notes
                - press the plus symbol to create a new note
                - note titles must be unique
                - note titles cannot be empty
                - enable RTX in the settings to see the rainbow
            """
            let welcome = Note(title: "Welcome!", text: features)
            notepad.addNote(welcome)
            notepad.addNote(Note(title: "to", text: ""))
            notepad.addNote(Note(title: "my", text: ""))
            notepad.addNote(Note(title: "first", text: ""))
            notepad.addNote(Note(title: "app", text: ""))
            notepad.addNote(Note(title: "for", text: ""))
            notepad.addNote(Note(title: "notes", text: ""))

            if !notepad.saveNotes() {
                let msg = "could not save to Documents"
                errorPopUp(sender: self, title: "ERROR", message: msg)
                print("error: could not create Notes.plist")
            }
            return
        }
        print("load successful")
    }

    // segue function
    // always called automatically when segueing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let newView = segue.destination as? NoteDetailViewController else {
            print("error: segue destination failed")
            return
        }

        navigationItem.backButtonTitle = "Back" // reflected in the new view

        switch sender {
        case is IndexPath: // existing note
            let index = sender as! IndexPath
            newView.currIndex = index.row
            newView.currNote = notepad.noteList[index.row]
        case is UIBarButtonItem: // new note
            newView.currIndex = notepad.noteList.count
            newView.currNote = Note(title: "", text: "")
        default:
            print("error: unexpected sender")
        }
    }

    // reloads table view when view changes to this one
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

extension NoteListViewController: UITableViewDelegate, UITableViewDataSource {

    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notepad.noteList.count
    }

    // cell loader
    // set cell's text to a Note object's title
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "title", for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = notepad.noteList[row].title

        // rainbow mode
        if rtx {
            cell.textLabel?.textColor = .white
            cell.textLabel?.shadowColor = .black
            cell.textLabel?.shadowOffset = CGSize(width: -0.25, height: -0.25)
            cell.textLabel?.layer.shadowColor = UIColor.black.cgColor
            cell.textLabel?.layer.shadowOffset = CGSize(width: 2, height: 2)
            cell.textLabel?.layer.shadowOpacity = 1
            cell.textLabel?.layer.shadowRadius = 2
            cell.backgroundColor = rainbow[row % rainbow.count].withAlphaComponent(0.95)
        } else {
            cell.textLabel?.textColor = .black
            cell.textLabel?.shadowColor = .none
            cell.textLabel?.shadowOffset = .zero
            cell.textLabel?.layer.shadowColor = .none
            cell.textLabel?.layer.shadowOffset = .zero
            cell.textLabel?.layer.shadowOpacity = .zero
            cell.textLabel?.layer.shadowRadius = .zero
            cell.backgroundColor = .none
        }

        return cell
    }
    
    // cell tapped
    // deselects row after tapping and seuges to detailed view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "list2detail", sender: indexPath)
    }

    // manages default editing styles
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let row = indexPath.row

        switch editingStyle {
        case .delete:
            notepad.deleteNote(at: row)

            guard notepad.saveNotes() else {
                let msg = "could not save to Documents"
                errorPopUp(sender: self, title: "ERROR", message: msg)
                print(msg)
                return
            }

            tableView.deleteRows(at: [indexPath], with: .right)
        case .insert:
            performSegue(withIdentifier: "list2detail", sender: UIBarButtonItem())
        default:
            print("warning: Unexpected editing style")
        }
    }

    // when moving rows
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movNote = notepad.noteList[sourceIndexPath.row]
        notepad.deleteNote(at: sourceIndexPath.row)
        notepad.insertNote(movNote, at: destinationIndexPath.row)
    }
}
