//
//  ContentView.swift
//  WordScramble
//
//  Created by Tuğran on 28.03.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self ) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .toolbar {
                Button("New Word", action: startGame)
            }
        }
        .alert("\(errorTitle)", isPresented: $showingError) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .safeAreaInset(edge: .bottom) {
            Text("Score: \(score)")
                .frame(maxWidth: .infinity)
                .padding()
                .background(.green)
                .font(.title)
                .foregroundColor(.white)
        }
        

    }
    func startGame() {
        usedWords.removeAll()
        score = 0
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "Default"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle!")
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't speel that word from \(rootWord)!")
            return
        }
                
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't make them up, you know!")
            return
        }
        
        guard letterCount(word: answer) else {
            wordError(title: "Word not possible", message: "Your word must have at least three letters!")
            return
        }
        
        guard sameWord(word: answer, root: rootWord) else {
            wordError(title: "This is same word", message: "Your word must be different from the \(rootWord)!")
            return
        }
              
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
        score += answer.count
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func letterCount(word: String) -> Bool {
        if word.count >= 3 {
            return true
        } else {
            return false
        }
    }
    
    func sameWord(word: String, root: String) -> Bool {
        if word == root {
            return false
        } else {
            return true
        }
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
