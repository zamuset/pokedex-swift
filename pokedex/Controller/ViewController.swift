//
//  ViewController.swift
//  Pokedex
//
//  Created by Samuel Chavez on 01/02/18.
//  Copyright © 2018 Samuel Chavez. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collection: UICollectionView!
    var pokemonArr = [Pokemon]()
    var filteredPokemonArr = [Pokemon]()
    var musicPlayer : AVAudioPlayer!
    
    var inSearchMode = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collection.delegate = self
        collection.dataSource = self
        
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        parsePokemonCSV()
        initAudio()
    }
    
    func initAudio() {
        guard let path = Bundle.main.path(forResource: "music", ofType: "mp3") else {
            print("no audio file found")
            return
        }
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
            
        } catch let err {
            print(err.localizedDescription)
        }
        
    }
    
    func parsePokemonCSV() {
        let path = Bundle.main.path(forResource: "pokemon", ofType: "csv")
        
        do {
            let csv = try CSV(contentsOfURL: path!)
            let rows = csv.rows
            
            for row in rows {
                let id = Int(row["id"]!)!
                var name = row["identifier"]!
                name = String(id) + " " + name
                
                pokemonArr.append(Pokemon(name: name, pokedexId: id))
            }
            
            collection.reloadData()
        
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    //MARK:- SearchBar delegates
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || (searchBar.text?.isEmpty)! {
            inSearchMode = false
            collection.reloadData()
            self.view.endEditing(true)
        } else {
            inSearchMode = true
            
            let lower = searchBar.text!.lowercased()
            filteredPokemonArr = pokemonArr.filter({$0.name.range(of: lower) != nil})
            collection.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    //MARK:- UICollectionView delegates
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell {
            
            let arr = inSearchMode ? filteredPokemonArr : pokemonArr
            
            cell.configureCell(pokemon: arr[indexPath.row])
            return cell
            
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let arr = inSearchMode ? filteredPokemonArr : pokemonArr
        let poke = arr[indexPath.row]
        
        performSegue(withIdentifier: "PokeDetail", sender: poke)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredPokemonArr.count
        }
        return pokemonArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 105, height: 105)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PokeDetail" {
            let vc = segue.destination as? PokemonDetailViewController
            if let poke = sender as? Pokemon {
                vc?.pokemon = poke
            }
        }
    }
    
    @IBAction func musicBtnPressed(_ sender: UIButton) {
        if musicPlayer.isPlaying {
            musicPlayer.pause()
            sender.alpha = 0.2
        } else {
            musicPlayer.play()
            sender.alpha = 1.0
        }
    }
}
