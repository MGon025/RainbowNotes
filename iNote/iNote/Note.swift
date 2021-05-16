//
//  Note.swift
//  iNote
//
//  Created by Mark Gonzalez on 5/15/21.
//

import Foundation

class Note: Codable {
    var title: String = ""
    var text: String = ""

    init(title: String, text: String) {
        self.title = title
        self.text = text
    }
}

class Notepad {
    var noteList = [Note]()

    // appends note to list
    func addNote(_ note: Note) {
        noteList.append(note)
    }

    // inserts note at index
    func insertNote(_ note: Note, at index: Int) {
        noteList.insert(note, at: index)
    }

    // deletes note at index
    func deleteNote(at index: Int) {
        noteList.remove(at: index)
    }

    // checks if title is empty or already taken
    func titleIsValid(_ title: String) -> Bool {
        if title == "" { return false }

        // check if title already exists
        for note in noteList {
            if note.title == title { return false }
        }

        return true
    }

    // loads notesList using Notes.plist from the documents directory
    // returns true if successful, else false
    func loadNotes() -> Bool {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let URL = dir.appendingPathComponent("Notes").appendingPathExtension("plist")
        let decoder = PropertyListDecoder()
        if let data = try? Data(contentsOf: URL),
           let decoded = try? decoder.decode([Note].self, from: data)
        {
            noteList = decoded
            return true
        }
        return false
    }

    // saves notesList to Notes.plist from the documents directory
    // returns true if successful, else false
    func saveNotes() -> Bool {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let URL = dir.appendingPathComponent("Notes").appendingPathExtension("plist")
        let encoder = PropertyListEncoder()
        if let encoded = try? encoder.encode(noteList) {
            try? encoded.write(to: URL)
            return true
        }
        return false
    }
}
