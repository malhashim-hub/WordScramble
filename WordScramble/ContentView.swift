//
//  ContentView.swift
//  WordScramble
//
//  Created by Mohammed Alhashim on 12/10/2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord: String = ""
    @State private var newWord: String = ""
    
    @State var scoreForRoot: Int = 0
    
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    var body: some View {
        NavigationStack {
            List {
                
                Section {
                   TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                       
                }
                
                Section{
                    ForEach(usedWords, id: \.self) { word in
                        HStack{
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
                Button("Restart"){
                    startGame()
                }
            }
            .alert(errorTitle, isPresented: $showingError){
                
            } message: {
                Text(errorMessage)
            }
            
            .safeAreaInset(edge: .bottom){
                
                Text("Score: \(scoreForRoot)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .font(.title2)
                
                
            }
            
            
        }
        
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 2 else {
            wordError(title: "Word too short", message: "Words must be at least three letters long.")
            return
        }
        
        //guard answer != rootWord else { return }
        
        guard isNotRoot(word: answer) else {
            wordError(title: "Are you serious?", message: "You cannot use the root word as an answer")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        scoreForRoot += newWord.count
        newWord = ""
        
        
    }
    
    func startGame() {
        
        usedWords.removeAll()
        newWord = ""
        
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                scoreForRoot = 0

                // If we are here everything has worked, so we can exit
                return
            }
        }
        

        // If we are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
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
    
    func isNotRoot(word: String) -> Bool {
        word != rootWord
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

#Preview {
    ContentView()
}
